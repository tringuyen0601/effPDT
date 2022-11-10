#include "gpu_fst_engine.h"

void FSTGPU::partition (TP * cpu_transducer, int test){
std::cout <<"=======================================" << std::endl;
  std::string destination  = "./testcases/";
  switch(test){
    case RLE_ENCODE:
      std::cout << " RLE_ENCODE" << std::endl;
      destination = destination +  "rle_encode/gpu_thread_config";
      RLE_ENCODING( cpu_transducer);

      break;
    case RLE_ENCODE_OPT:
      std::cout << " RLE_ENCODE_OPT" << std::endl;
      destination = destination +  "rle_encode_opt/gpu_thread_config";
      RLE_ENCODING( cpu_transducer);

      break;
    case RLE_DECODE:
      std::cout << " RLE_DECODE" << std::endl;
      destination = destination +  "rle_decode/gpu_thread_config";
      RLE_DECODING( cpu_transducer);

      break;
    case RLE_DECODE_OPT:
      std::cout << " RLE_DECODE_OPT" << std::endl;
      destination = destination +  "rle_decode_opt/gpu_thread_config";
      RLE_DECODING( cpu_transducer);
      break;
    case BP_ENCODE:
      std::cout << " BP_ENCODE" << std::endl;
      destination = destination +  "bp_encode/gpu_thread_config";
      BP_ENCODING( cpu_transducer);
      break;
    case BP_DECODE:
      std::cout << " BP_DECODE" << std::endl;
      destination = destination +  "bp_decode/gpu_thread_config";
      RLE_ENCODING( cpu_transducer);
      break;
    case GV_ENCODE:
      std::cout << " GV_ENCODE" << std::endl;
      destination = destination +  "gv_encode/gpu_thread_config";
      RLE_ENCODING( cpu_transducer);
      break;
    case GV_DECODE:
      std::cout << " GV_DECODE" << std::endl;
      destination = destination +  "gv_decode/gpu_thread_config";
      RLE_ENCODING( cpu_transducer);

      break;
    case DENSE_DOK:
      std::cout << " DENSE_DOK" << std::endl;

      break;

    case DOK_LIL:
      std::cout << " DOK_LIL" << std::endl;

      break;
    case LIL_COO:
      std::cout << " LIL_COO" << std::endl;

      break;
    case COO_CSR:
      std::cout << " COO_CSR" << std::endl;
      destination = destination +  "coo_csr/gpu_thread_config";
      COOCSR( cpu_transducer);

      break;
    case CSR_DENSE:
      std::cout << " CSR_DENSE" << std::endl;

      break;
    case DENSE_CSR_PTR:
      std::cout << " DENSE_CSR_PTR" << std::endl;
      destination = destination +  "dense_csr_ptr/gpu_thread_config";
      COOCSR( cpu_transducer);
      break;
    case CSV_ENC_DET:
      std::cout << " CSV_ENC_DET" << std::endl;
      destination = destination +  "csv_parsing/gpu_thread_config";
      CSV_PARSING(  cpu_transducer);
      break;
  }
  //save_thread_config(cpu_transducer, destination);
}
void FSTGPU::save_thread_config( TP * cpu_transducer, std::string destination){
  std::cout << "==================================== "<< std::endl;
  std::cout << "Saving thread config "<< std::endl;
  std::ofstream pconf  (destination, std::ofstream::out);
  pconf << number_of_block <<" Block | " << number_of_thread <<  " thread per block"<< std::endl;
  for ( uint32_t i = 0; i < total_threads; i++){
    pconf << "Thread " << i << std::endl;
    for (uint32_t j = 0; j < cpu_transducer->inputCount; j++){
      pconf<< "Input: " << j<< "| " ;
      pconf<< partition_input_base_cpu[i][j] << " - " << partition_input_length_cpu[i][j] << std::endl;
      pconf <<"\t" ;
      /*
      for ( uint32_t k = partition_input_base_cpu[i][j] ; k < partition_input_base_cpu[i][j] + partition_input_length_cpu[i][j] ; k++)
        pconf << cpu_transducer->inStream[j][k] << " ";
      pconf << std::endl;
      */
      pconf << "--------------------" << std::endl;
    }
    for (uint32_t j = 0; j < cpu_transducer->outputCount; j++){
      pconf<< "output: " << j<< "| " ;
      pconf<< partition_output_base_cpu[i][j] << " - " << partition_output_current_cpu[i][j] << std::endl;
      pconf <<"\t" ;
      pconf << "--------------------" << std::endl;
    }
  }
  pconf.close();
  std::cout << "==================================== "<< std::endl;
}


// RLE ENCODING
void FSTGPU::RLE_ENCODING( TP * cpu_transducer){
  std::cout << "==================================== "<< std::endl;
  std::cout << " START PARTITION INPUT FOR RLE, BPE "<< std::endl;
  uint32_t thread_length = cpu_transducer->input_length[0] / total_threads;

  if ( thread_length < MIN_LENGTH) thread_length = MIN_LENGTH;
  if ( cpu_transducer->input_length[0]  < MIN_LENGTH) thread_length = cpu_transducer->input_length[0];

  uint32_t max_thread = cpu_transducer->input_length[0]/thread_length;
  uint32_t left_over = cpu_transducer->input_length[0] % thread_length; 
  std::cout << " each thread process " << thread_length <<" symbols"<< std::endl;
  std::cout << " max thread " << max_thread <<" threads"<< std::endl;
  std::cout << " left over " << left_over <<" symbols"<< std::endl;

  for ( uint32_t i = 0; i < total_threads; i++){
    for (uint32_t j = 0; j < cpu_transducer->inputCount; j++){
      //std::cout << "thread : " << i << ", input: " << j << std::endl;
      if ( i < max_thread){
        partition_input_length_cpu[i][j] = thread_length; 
      }
      else if ( i == max_thread){ 
        partition_input_length_cpu[i][j] = left_over; 
      }
      else {
        partition_input_length_cpu[i][j] =0; 
      }
#ifdef SAME_START
      partition_input_base_cpu[i][j] = 0;  
#else
      partition_input_base_cpu[i][j] = i * thread_length;  
#endif
      partition_input_current_cpu[i][j] = 0;  
    }
    for (uint32_t j = 0; j < cpu_transducer->outputCount; j++){
      partition_output_base_cpu[i][j] = i * thread_length ;  
      partition_output_current_cpu[i][j] =0 ;  
    }
  }
  std::cout << "==================================== "<< std::endl;
}

// RLE DECODING
void FSTGPU::RLE_DECODING( TP * cpu_transducer){
  std::cout << "==================================== "<< std::endl;
  std::cout << " START PARTITION INPUT FOR RLD "<< std::endl;
  uint32_t thread_length = cpu_transducer->input_length[0] / total_threads;

  if ( thread_length < MIN_LENGTH) thread_length = MIN_LENGTH;
  if (( thread_length %2) != 0) thread_length++;
  if ( cpu_transducer->input_length[0]  < MIN_LENGTH) thread_length = cpu_transducer->input_length[0];

  uint32_t max_thread = cpu_transducer->input_length[0]/thread_length;
  uint32_t left_over = cpu_transducer->input_length[0] % thread_length; 
  if (( left_over %2) != 0) left_over= left_over-1;
  left_over= 0;
  std::cout << " each thread process " << thread_length <<" symbols"<< std::endl;
  std::cout << " max thread " << max_thread <<" threads"<< std::endl;
  std::cout << " left over " << left_over <<" symbols"<< std::endl;

  for ( uint32_t i = 0; i < total_threads; i++){
    for (uint32_t j = 0; j < cpu_transducer->inputCount; j++){
      //std::cout << "thread : " << i << ", input: " << j << std::endl;
      if ( i < max_thread){
        partition_input_length_cpu[i][j] = thread_length; 
      }
      else if ( i == max_thread){ 
        partition_input_length_cpu[i][j] = left_over; 
      }
      else {
        partition_input_length_cpu[i][j] =0; 
      }
#ifdef SAME_START
      partition_input_base_cpu[i][j] = 0;  
#else
      partition_input_base_cpu[i][j] = i * thread_length;  
#endif
      partition_input_current_cpu[i][j] = 0;  
    }
    for (uint32_t j = 0; j < cpu_transducer->outputCount; j++){
      partition_output_base_cpu[i][j] = i * thread_length ;  
      partition_output_current_cpu[i][j] =0 ;  
    }
  }
  std::cout << "==================================== "<< std::endl;
}

// BP_ENCODING
void FSTGPU::BP_ENCODING( TP * cpu_transducer){
  std::cout << "==================================== "<< std::endl;
  std::cout << " START PARTITION INPUT FOR RLD "<< std::endl;
  uint32_t thread_length = cpu_transducer->input_length[0] / total_threads;

  if ( thread_length < MIN_LENGTH) thread_length = MIN_LENGTH;
  if (( thread_length %4) != 0) thread_length = thread_length + ( 4- (thread_length%4));
  if ( cpu_transducer->input_length[0]  < MIN_LENGTH) thread_length = cpu_transducer->input_length[0];

  uint32_t max_thread = cpu_transducer->input_length[0]/thread_length;
  uint32_t left_over = cpu_transducer->input_length[0] % thread_length; 
  if (( left_over %4) != 0) left_over= left_over-1;
  left_over= 0;
  std::cout << " each thread process " << thread_length <<" symbols"<< std::endl;
  std::cout << " max thread " << max_thread <<" threads"<< std::endl;
  std::cout << " left over " << left_over <<" symbols"<< std::endl;

  for ( uint32_t i = 0; i < total_threads; i++){
    for (uint32_t j = 0; j < cpu_transducer->inputCount; j++){
      //std::cout << "thread : " << i << ", input: " << j << std::endl;
      if ( i < max_thread){
        partition_input_length_cpu[i][j] = thread_length; 
      }
      else if ( i == max_thread){ 
        partition_input_length_cpu[i][j] = left_over; 
      }
      else {
        partition_input_length_cpu[i][j] =0; 
      }
#ifdef SAME_START
      partition_input_base_cpu[i][j] = 0;  
#else
      partition_input_base_cpu[i][j] = i * thread_length;  
#endif
      partition_input_current_cpu[i][j] = 0;  
    }
    for (uint32_t j = 0; j < cpu_transducer->outputCount; j++){
      partition_output_base_cpu[i][j] = i * thread_length ;  
      partition_output_current_cpu[i][j] =0 ;  
    }
  }
  std::cout << "==================================== "<< std::endl;
}

// BP_ENCODING
void FSTGPU::COOCSR( TP * cpu_transducer){
  std::cout << "==================================== "<< std::endl;
  std::cout << " START PARTITION INPUT FOR COO-CSR  "<< std::endl;
  
  uint32_t number_of_data = cpu_transducer->inStream[0][2]; 
  uint32_t number_of_row = cpu_transducer->inStream[0][0]; 
  uint32_t number_of_col = cpu_transducer->inStream[0][1]; 
  std::cout << " Number of data: " << number_of_data <<std::endl; 
  std::cout << " Number of row: " << number_of_row <<std::endl; 
  std::cout << " Number of col: " << number_of_col <<std::endl; 
  /*
  uint32_t number_of_matrix = cpu_transducer->input_length[1] / number_of_data;
  uint32_t thread_length = number_of_matrix/ total_threads;
  uint32_t max_thread = cpu_transducer->input_length[1]/( thread_length* number_of_data);
  if ( max_thread <1) max_thread =1;
  uint32_t left_over = cpu_transducer->input_length[1] % (thread_length * number_of_data); 
  left_over= 0;
*/
  uint32_t thread_length  = cpu_transducer->input_length[1] / total_threads;
  if ( thread_length < 100) thread_length = 100;

  uint32_t max_thread = cpu_transducer->input_length[1]/( thread_length);
  if ( max_thread <1) max_thread =1;
  uint32_t left_over = cpu_transducer->input_length[1] % (thread_length); 
  left_over= 0;
  std::cout << " Input has  " << cpu_transducer->input_length[1] <<" symbol or  ";;
  //std::cout << number_of_matrix  <<" matrixes "<< std::endl;
  std::cout << " each thread process " << thread_length <<" matrix "<< std::endl;
  std::cout << " max thread " << max_thread <<" threads"<< std::endl;
  std::cout << " left over " << left_over <<" symbols"<< std::endl;

  for ( uint32_t i = 0; i < total_threads; i++){
    for (uint32_t j = 0; j < cpu_transducer->inputCount; j++){
      if ( j == 0){
        partition_input_length_cpu[i][j] =3; 
        partition_input_base_cpu[i][j] = 0;  
        partition_input_current_cpu[i][j] = 0;  
      }
      else{ 
        if ( i < max_thread){
          //partition_input_length_cpu[i][j] = thread_length * number_of_data; 
          partition_input_length_cpu[i][j] = thread_length ; 
        }
        else if ( i == max_thread){ 
          partition_input_length_cpu[i][j] = left_over; 
        }
        else {
          partition_input_length_cpu[i][j] =0; 
        }
        partition_input_base_cpu[i][j] = 0;  
        partition_input_current_cpu[i][j] = 0;  
      }
    }
    for (uint32_t j = 0; j < cpu_transducer->outputCount; j++){
      if ( j == 0) {
        partition_output_base_cpu[i][j] = i *3;  
        partition_output_current_cpu[i][j] =0 ;  
      }
      else{
        partition_output_base_cpu[i][j] = i * thread_length * number_of_data;  
        partition_output_current_cpu[i][j] =0 ;  
      }
    }
  }
  std::cout << "==================================== "<< std::endl;
}

// CSV PARSING
void FSTGPU::CSV_PARSING( TP * cpu_transducer){
  std::cout << "==================================== "<< std::endl;
  std::cout << " START PARTITION INPUT FOR RLE, BPE "<< std::endl;
  uint32_t thread_length = cpu_transducer->input_length[0] / total_threads;

  if ( thread_length < MIN_LENGTH) thread_length = MIN_LENGTH;
  if ( cpu_transducer->input_length[0]  < MIN_LENGTH) thread_length = cpu_transducer->input_length[0];

  uint32_t max_thread = cpu_transducer->input_length[0]/thread_length;
  uint32_t left_over = cpu_transducer->input_length[0] % thread_length; 
  std::cout << " each thread process " << thread_length <<" symbols"<< std::endl;
  std::cout << " max thread " << max_thread <<" threads"<< std::endl;
  std::cout << " left over " << left_over <<" symbols"<< std::endl;

  for ( uint32_t i = 0; i < total_threads; i++){
    for (uint32_t j = 0; j < cpu_transducer->inputCount; j++){
      //std::cout << "thread : " << i << ", input: " << j << std::endl;
      if ( i < max_thread){
        partition_input_length_cpu[i][j] = thread_length; 
      }
      else if ( i == max_thread){ 
        partition_input_length_cpu[i][j] = left_over; 
      }
      else {
        partition_input_length_cpu[i][j] =0; 
      }
#ifdef SAME_START
      partition_input_base_cpu[i][j] = 0;  
#else
      //partition_input_base_cpu[i][j] = i * thread_length;  
      partition_input_base_cpu[i][j] = 0;  
#endif
      partition_input_current_cpu[i][j] = 0;  
    }
    for (uint32_t j = 0; j < cpu_transducer->outputCount; j++){
      partition_output_base_cpu[i][j] = i * thread_length ;  
      partition_output_current_cpu[i][j] =0 ;  
    }
  }
  std::cout << "==================================== "<< std::endl;
}
