#include "processor.h"

void TP::loadFST_GPU( TPGPU * h_processor, uint32_t blocks, uint32_t threads){
  /* stack and memory info  */
  cudaError_t error; 
  printf( "START LOADING \n");
  bool * temp_bool; 
  uint32_t * temp ;
  NPDT * temp_npdt;
  Transition * temp_trans;

  error = cudaMalloc(&(temp) ,varCount  * blocks * threads * sizeof(uint32_t));
  error = cudaMemcpy(&h_processor->var, &temp, sizeof(uint32_t*), cudaMemcpyHostToDevice);
  cudaMemset(temp, 0, varCount * blocks * threads * sizeof( uint32_t));

  error = cudaMalloc(&(temp_npdt) ,stateCount * sizeof(NPDT));
  error = cudaMemcpy(&h_processor->stateList, &temp_npdt, sizeof(NPDT*), cudaMemcpyHostToDevice);


  error = cudaMalloc(&(temp_trans) ,transitionCount * sizeof(Transition));
  error = cudaMemcpy(&h_processor->transitionList, &temp_trans, sizeof(Transition*), cudaMemcpyHostToDevice);
  error = cudaMalloc(&(temp_bool) ,transitionCount * sizeof(bool));
  error = cudaMemcpy(&h_processor->pendingTransition, &temp_bool, sizeof(bool*), cudaMemcpyHostToDevice);



  printf( "START COPY counter \n");
  error = cudaMemcpy(&h_processor->stateCount, &stateCount, sizeof(uint32_t), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "GPU assert%s \n", cudaGetErrorString(error));
  }
  error = cudaMemcpy(&h_processor->transitionCount, &transitionCount, sizeof(uint32_t), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "GPU assert%s \n", cudaGetErrorString(error));
  }
  error = cudaMemcpy(&h_processor->varCount, &varCount, sizeof(uint32_t), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "GPU assert%s \n", cudaGetErrorString(error));
  }
  error = cudaMemcpy(&h_processor->inputCount, &inputCount, sizeof(uint32_t), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "GPU assert%s \n", cudaGetErrorString(error));
  }
  error = cudaMemcpy(&h_processor->outputCount,  & outputCount, sizeof(uint32_t), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "GPU assert%s \n", cudaGetErrorString(error));
  }


  printf( "START COPY Topology \n");
  /*
  for ( int i = 0; i < varCount; i ++)
    printf( "var[%d] = %d\n", var[i], i);
  */
  if ( error != cudaSuccess){
    printf( "var GPU assert %s \n", cudaGetErrorString(error));
  }
  error = cudaMemcpy(temp_npdt, stateList, stateCount * sizeof(NPDT), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "state GPU assert %s \n", cudaGetErrorString(error));
  }
  error = cudaMemcpy(temp_trans,transitionList,  transitionCount * sizeof(Transition), cudaMemcpyHostToDevice);
  if ( error != cudaSuccess){
    printf( "transition GPU assert %s \n", cudaGetErrorString(error));
  }
}
