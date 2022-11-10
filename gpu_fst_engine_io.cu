#include "gpu_fst_engine.h"
#include "processor.h"
#include "processor_gpu.h"

__global__ 
void printTape_D( uint32_t ** tape, uint32_t * size, uint32_t numberoftapes){
  for ( int i = 0; i < numberoftapes; i++){
    printf("Tape: %d : element: %d:\n", i, size[i]);
    for( int j = 0; j < size[i]; j++){
      printf("%d; ", tape[i][j]);
    }
    printf("\n");
  }
}

void printTape( uint32_t ** tape, uint32_t * size, uint32_t numberoftapes){
  for ( int i = 0; i < numberoftapes; i++){
    printf("Tape: %d : element: %d:\n", i, size[i]);
    for( int j = 0; j < size[i]; j++){
      printf("%d; ", tape[i][j]);
    }
    printf("\n");
  }
}
void FSTGPU::IO_setup( TP* cpu_transducer, uint32_t blocks, uint32_t threads){
  printf (" =====================================================\n");
  printf(" Start setting up input, output\n");
  number_of_thread = threads;
  number_of_block = blocks;
  total_threads = number_of_thread * number_of_block;
  printf("%d Input\n", cpu_transducer->inputCount);
  printf("%d Output\n", cpu_transducer->outputCount);
  inputCount = cpu_transducer->inputCount;
  outputCount = cpu_transducer->outputCount;
  printf("CPU INPUT\n");
  //printTape (&(cpu_transducer->inStream[0]), &(cpu_transducer->input_length[0]), inputCount); 

  cudaError_t error;
  // copy input length array
  cudaMalloc( &input_length , inputCount * sizeof (uint32_t));
  cudaMemcpy ( input_length,cpu_transducer->input_length, inputCount * sizeof( uint32_t), cudaMemcpyHostToDevice); 
 
  // allocate each input and copy them to device
  uint32_t ** temp_input = (uint32_t**) malloc ( inputCount *sizeof( uint32_t*));
  for ( uint32_t i = 0; i < inputCount; i++){
    error = cudaMalloc ( &temp_input[i], cpu_transducer->input_length[i] * sizeof(uint32_t));
    //printf( "GPU MAlloc assert %s \n", cudaGetErrorString(error));                                       
    error = cudaMemcpy ( (temp_input[i]), (cpu_transducer->inStream[i]),cpu_transducer->input_length[i] * sizeof(uint32_t),  cudaMemcpyHostToDevice);
    //printf( "GPU Copy assert %s \n", cudaGetErrorString(error));                               
  }
  // copy input pointer to device
  cudaMalloc( & (input), inputCount* sizeof( uint32_t*)); 
  cudaMemcpy ((input), (temp_input), inputCount * sizeof( uint32_t*), cudaMemcpyHostToDevice);

  //printf("GPU INPUT\n");
  //printTape_D<<< 1,1>>> (input, input_length, inputCount); 
  cudaDeviceSynchronize();
  // allocate Output
#ifdef DEBUG_GPU
  printf(" ALLOCATE OUTPUT FOR DEBUG\n");
  uint32_t ** temp_output = (uint32_t**) malloc ( outputCount *sizeof( uint32_t*));
  // allocate each input and copy them to device
  for ( uint32_t i = 0; i < outputCount; i++){
    //cudaMalloc ( &(temp_output[i]), OUTPUT_LENGTH * sizeof(uint32_t));
    cudaMalloc ( &(temp_output[i]), cpu_transducer->output_length[i] * sizeof(uint32_t));
  }
  // copy input pointer to device
  cudaMalloc( & (output), outputCount* sizeof( uint32_t*)); 
  cudaMemcpy ((output), (temp_output), outputCount * sizeof( uint32_t*), cudaMemcpyHostToDevice);
#endif
  printf (" =====================================================\n");
}


void FSTGPU::IO_partition(  TP * cpu_transducer, int test){

  printf (" =====================================================\n");
  printf(" START PARTITIONING IO\n");
// initialize partition data on CPU
  printf(" Allocating cpu for %d threads, %d input, %d output\n", total_threads, inputCount, outputCount);
  partition_input_length_cpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  partition_input_base_cpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  partition_input_current_cpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  partition_output_base_cpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  partition_output_current_cpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  for ( int i = 0; i < total_threads; i++){
    partition_input_length_cpu[i] = ( uint32_t *) malloc ( inputCount * sizeof(uint32_t));
    partition_input_base_cpu[i] = ( uint32_t *) malloc ( inputCount  * sizeof(uint32_t));
    partition_input_current_cpu[i] = ( uint32_t *) malloc ( inputCount  * sizeof(uint32_t));
    partition_output_base_cpu[i] = ( uint32_t *) malloc ( outputCount  * sizeof(uint32_t));
    partition_output_current_cpu[i] = ( uint32_t *) malloc ( outputCount  * sizeof(uint32_t));
  }
// parition according to the benchmark
  uint32_t * dummy_length = (uint32_t*) malloc ( inputCount * sizeof( uint32_t));
  cudaMemcpy ( dummy_length, input_length, inputCount * sizeof(uint32_t), cudaMemcpyDeviceToHost);
  //testing functionality
  printf(" Initializing cpu\n");
  partition(cpu_transducer,  test); 

  // allocate and copy partition data to GPU

  printf(" Allocating %d gpu  pointer \n", inputCount);
  uint32_t ** partition_input_length_gpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  uint32_t ** partition_input_base_gpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  uint32_t ** partition_input_current_gpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  uint32_t ** partition_output_base_gpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  uint32_t ** partition_output_current_gpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));
  uint32_t ** simulated_output_gpu  = (uint32_t **) malloc ( total_threads * sizeof( uint32_t *));


  printf(" Allocating gpu  \n");
  for ( uint32_t i = 0 ; i < total_threads ; i++){
    cudaMalloc (&( partition_input_length_gpu[i]), inputCount * sizeof(uint32_t));
    cudaMemcpy (partition_input_length_gpu[i], partition_input_length_cpu[i], inputCount * sizeof(uint32_t), cudaMemcpyHostToDevice);

    cudaMalloc (&( partition_input_base_gpu[i]), inputCount * sizeof(uint32_t));
    cudaMemcpy (partition_input_base_gpu[i], partition_input_base_cpu[i], inputCount *sizeof(uint32_t), cudaMemcpyHostToDevice);

    cudaMalloc (&( partition_input_current_gpu[i]), inputCount * sizeof(uint32_t));
    cudaMemcpy (partition_input_current_gpu[i], partition_input_current_cpu[i], inputCount *sizeof(uint32_t), cudaMemcpyHostToDevice);
 
    cudaMalloc (&( partition_output_base_gpu[i]), outputCount * sizeof(uint32_t));
    cudaMemcpy (partition_output_base_gpu[i], partition_output_base_cpu[i], outputCount *sizeof(uint32_t), cudaMemcpyHostToDevice);

    cudaMalloc (&( partition_output_current_gpu[i]), outputCount * sizeof(uint32_t));
    cudaMemcpy (partition_output_current_gpu[i], partition_output_current_cpu[i], outputCount *sizeof(uint32_t), cudaMemcpyHostToDevice);

    cudaMalloc (&( simulated_output_gpu[i]), outputCount * sizeof(uint32_t));
  }

  printf(" Copy GPU pointer \n");

  cudaMalloc (&( partition_input_length),  total_threads * sizeof(uint32_t*));
  cudaMemcpy (partition_input_length, partition_input_length_gpu, total_threads * sizeof(uint32_t*), cudaMemcpyHostToDevice);

  cudaMalloc (&( partition_input_base),  total_threads * sizeof(uint32_t*));
  cudaMemcpy (partition_input_base, partition_input_base_gpu,  total_threads * sizeof(uint32_t*), cudaMemcpyHostToDevice);

  cudaMalloc (&( partition_input_current),  total_threads * sizeof(uint32_t*));
  cudaMemcpy (partition_input_current, partition_input_current_gpu,  total_threads * sizeof(uint32_t*), cudaMemcpyHostToDevice);

  cudaMalloc (&( partition_output_base),  total_threads * sizeof(uint32_t*));
  cudaMemcpy (partition_output_base, partition_output_base_gpu,  total_threads * sizeof(uint32_t*), cudaMemcpyHostToDevice);

  cudaMalloc (&( partition_output_current),  total_threads * sizeof(uint32_t*));
  cudaMemcpy (partition_output_current, partition_output_current_gpu,  total_threads * sizeof(uint32_t*), cudaMemcpyHostToDevice);

  cudaMalloc (&( simulated_output), total_threads * sizeof(uint32_t*));
  cudaMemcpy (simulated_output, simulated_output_gpu,  total_threads * sizeof(uint32_t*), cudaMemcpyHostToDevice);
}


void FSTGPU::copyBack( TP * transducer){
  uint32_t ** tmp = (uint32_t **) malloc( outputCount * sizeof( uint32_t*));
  cudaMemcpy ( tmp, output, outputCount * sizeof( uint32_t*), cudaMemcpyDeviceToHost);
  for  (int i = 0; i <transducer-> outputCount; i++){
    cudaMemcpy( transducer->outStream[i], tmp[i], OUTPUT_LENGTH * sizeof( uint32_t), cudaMemcpyDeviceToHost);
    
  }
  #ifdef DEBUG_GPU
  for ( int i = 0; i < transducer->outputCount; i ++){
    printf("Output %d: \n", i);
    //for( int j =0; j < OUTPUT_LENGTH; j++){
    for( int j =0; j < 10; j++){
      printf( "%u; ", transducer->outStream[i][j]);
    }
    printf("\n");
  }
  #endif
}
