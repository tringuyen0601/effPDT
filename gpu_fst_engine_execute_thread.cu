#include "processor_gpu.h"
#include "gpu_fst_engine.h"

__device__
void ExecuteAction_d_thread ( uint32_t * var, uint32_t src1, uint32_t src2, uint32_t dst, uint32_t opt, uint32_t startVar){
  uint32_t src1Value, src2Value;
  switch (opt){
    case ADD:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value + src2Value;
      break;
    case ADDI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value + src2Value;
      break;
    case SUB:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value - src2Value;
      break;
    case SUBI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value - src2Value;
      break;
    case MUL:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value * src2Value;
      break;
    case MULI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value * src2Value;
      break;
    case DIV:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value / src2Value;
      break;
    case DIVI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value / src2Value;
      break;
    case LSHIFT:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value << src2Value;
      break;
    case LSHIFTI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value << src2Value;
      break;
    case RSHIFT:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value >> src2Value;
      break;
    case RSHIFTI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value >> src2Value;
      break;
    case OR:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value | src2Value;
      break;
    case ORI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value | src2Value;
      break;
    case AND:
      src1Value = (var[src1 + startVar]);
      src2Value = (var[src2+ startVar]);
      var[dst + startVar] = src1Value & src2Value;
      break;
    case ANDI:
      src1Value = (var[src1 + startVar]);
      src2Value = src2;
      var[dst + startVar] = src1Value & src2Value;
      break;
    case EPSILON:
    default:
      break;
  }
}

__device__
void state_action_d_thread ( uint32_t * var, uint32_t  currentState, uint32_t startVar){
  uint32_t src1 = stateList[currentState].src1 ;
  uint32_t src2 = stateList[currentState].src2 ;
  uint32_t dst = stateList[currentState].dst ;
  uint32_t opt = stateList[currentState].opt;
  ExecuteAction_d_thread ( var, src1, src2, dst, opt, startVar);
}


__device__
uint32_t getInput_d_thread ( uint32_t *  input, uint32_t * processed_symbol, uint32_t * input_base, uint32_t inputID ){
  uint32_t base = input_base[inputID];
  uint32_t current =  processed_symbol[inputID];
  return input[base+  current];

}


__device__
bool compareSwitch_d_thread( uint32_t * var, uint32_t lhs, uint32_t rhs, uint32_t ** input, uint32_t * shared_input_base,  uint32_t *shared_processed_symbol,  uint32_t startVar){
  int condition = ILL;
  // alphabet match:  0-256
  if ( rhs < ALPHABETSIZE) {
    //printf(" alphabet match\n");
    condition = ALPHABET;
  }
  // negation alphabet  match: 256-511
  else if ( (rhs >= ALPHABETSIZE) && ( rhs < (2 * ALPHABETSIZE)) ) {
    condition = NEGALPHABET;
  }
  // EPSILON match: 512
  else if ( rhs == (2 * ALPHABETSIZE)) {
    condition = EPS;
  }
  // Variable match: 513-576
  else if (( rhs >  (2 * ALPHABETSIZE)) && ( rhs <= (2 * (ALPHABETSIZE) + MAXVAR))) {
    condition = VAR;
  }
  //  Input Match:  577-640
  else if( ( rhs >= INPUT_MATCH) && ( rhs <( INPUT_MATCH + MAXVAR))) {
    condition = INPT;
  }
  //  Passthrough Match:  641
  else if ( rhs == ANY_MATCH) {
    condition = PASSTHROUGH;
  }
  // negation variable match:  769-832
  else if (( rhs >  (3 * ALPHABETSIZE)) && ( rhs <= (3 * ALPHABETSIZE + MAXVAR))) {
    condition =NEGVAR;
  }
  // Negation Input Match:  833-896
  else if( ( rhs >=( INPUT_MATCH + ALPHABETSIZE)) && ( rhs <( INPUT_MATCH+ ALPHABETSIZE+ MAXVAR))) {
    condition = NEGINPT;
    }

  uint32_t varValue, inputValue;
  bool match = false;
  switch (condition)  {
    case  ALPHABET:
      if ( lhs == rhs) match = true;
      break;
    case  NEGALPHABET:
      if ( lhs  != (rhs- ALPHABETSIZE )) match = true;
      break;
    case  EPS:
      match = true;
      break;
    case  VAR:
      varValue = var[rhs- 2*ALPHABETSIZE + startVar -1 ];
      if ( lhs == varValue) match = true;
      break;
    case  INPT:
      inputValue = getInput_d_thread( input[rhs-INPUT_MATCH], shared_processed_symbol, shared_input_base,  rhs -INPUT_MATCH);
      if ( lhs == inputValue) match = true;
      break;
    case  PASSTHROUGH:
      match = true;
      break;
    case  NEGVAR:
      varValue = var[rhs- 3*ALPHABETSIZE -1 + startVar];
      if ( lhs != varValue) match = true;
      break;
    case  NEGINPT:
      inputValue = getInput_d_thread( input[rhs-INPUT_MATCH- ALPHABETSIZE], shared_processed_symbol, shared_input_base,  rhs - INPUT_MATCH - ALPHABETSIZE);
      if ( lhs != inputValue) match = true;
      break;
      }
    return match;

}


__device__
uint32_t transition_eval_d_thread( uint32_t * var, uint32_t  currentState,  uint32_t startVar, uint32_t **input, uint32_t * shared_input_base,   uint32_t *shared_processed_symbol){
  uint32_t baseID = stateList[currentState].baseID;
  uint32_t numberofTransition = stateList[currentState].numberofTransition;
  uint32_t returnID = TRANSITION_COUNT;
  for ( uint32_t i = baseID; i < (baseID + numberofTransition); i++){
    // input
    bool inputMatch = false;
    if ( transitionList[i].inputID != EPSILON_MATCH){
      // decode left-hand side
      uint32_t lhs = getInput_d_thread(input[ transitionList[i].inputID- INPUT_MATCH], shared_processed_symbol, shared_input_base,  transitionList[i].inputID- INPUT_MATCH);
      /*
      printf(" Transition %d :", i);
      printf(" left hand side = %d ;", lhs);
      printf(" right hand side = %d \n", transitionList[i].inputSymbol);
      */
      // call compare to right-hand side
      inputMatch = compareSwitch_d_thread ( var,  lhs,transitionList[i].inputSymbol, input, shared_input_base,  shared_processed_symbol, startVar);
    }
    else {
      inputMatch = true;
    }
  // variable
  bool varMatch = false;
    if ( transitionList[i].IvarID != EPSILON_MATCH){
      // decode left-hand side
      uint32_t lshVar = transitionList[i].IvarID + startVar - 2 *ALPHABETSIZE -1;
      uint32_t lhs = var[lshVar];
      // call compare to right-hand side
      varMatch = compareSwitch_d_thread ( var, lhs,transitionList[i].inputVar , input, shared_input_base, shared_processed_symbol, startVar);
    }
    else {
      varMatch = true;
    }

  if ( inputMatch && varMatch){
     return i;
    }
  }
  return returnID;
}


__device__
uint32_t translateOutput_d_thread ( uint32_t * var, uint32_t ** input, uint32_t * shared_input_base,  uint32_t * shared_processed_symbol,uint32_t outputVar, uint32_t startVar){
  uint32_t character = 1000; // illegal value

  if ( outputVar < ALPHABETSIZE)
    character = outputVar;
  else if (( outputVar >=ALPHABETSIZE) && ( outputVar <= 2*ALPHABETSIZE))
    return character;
  else if ( (outputVar > 2*(ALPHABETSIZE)) &&( outputVar < (2*ALPHABETSIZE + MAXVAR)) ){
    character = var[startVar + outputVar - 2*ALPHABETSIZE -1 ];

  }
  else if ( outputVar >= 2 * ALPHABETSIZE + MAXVAR +1){
    character = getInput_d_thread( input[outputVar- INPUT_MATCH], shared_processed_symbol,shared_input_base,  outputVar - INPUT_MATCH);
    //printf("Write to output %d: %d\n", outputVar-INPUT_MATCH, character);
  }
  return character;
}


__device__
uint32_t transition_write_d_thread(  uint32_t * var,  uint32_t chosenTransition, uint32_t startVar, uint32_t ** input, uint32_t * shared_input_base,  uint32_t*  processed_symbol, uint32_t ** output,uint32_t * simulated_output, uint32_t* outputCount , uint32_t *output_base){
  if( chosenTransition == TRANSITION_COUNT)
    return STATE_COUNT;

  // write to variable
  if ( transitionList[chosenTransition].OvarID != EPSILON_MATCH){
    uint32_t outputVar = startVar+ transitionList[chosenTransition].OvarID - 2 * ALPHABETSIZE - 1;
    //printf("Write Var %d \n", outputVar);
    var[outputVar]  =
      translateOutput_d_thread ( var,  input, shared_input_base,  processed_symbol, transitionList[chosenTransition].outputVar,startVar);
  }
  // write to output

  if ( transitionList[chosenTransition].outputID != EPSILON_MATCH){
    uint32_t output_dst = transitionList[chosenTransition].outputID - OUTPUT_START;
#ifdef DEBUG_GPU
    output[output_dst][output_base[output_dst] + outputCount[output_dst]]  =
#else
  simulated_output[output_dst]  =
#endif
      translateOutput_d_thread ( var, input, shared_input_base, processed_symbol, transitionList[chosenTransition].outputSymbol, startVar);
    outputCount[output_dst] ++;
  }

  //actiavate next State
  return transitionList[chosenTransition].nextState;
}


__device__
bool is_done_processed_thread ( uint32_t * current, uint32_t * expected){
  for ( int i = 0; i < INPUT; i++){
    if ( current[i] < expected[i])
      return false;
  }
  return true;
}


//////////////////
// main processing function
// partition_length: number of inputsymbol each stream have to processed
// input_base: element that each stream have to processed from
// processed_symbol: number of input each stream have processed
// partition_output_base: element each stream have to process from
// output_count: number of symbol have been written to each stream
__global__
void process_k_thread( TPGPU * fst,uint32_t ** input_base, uint32_t ** partition_length, uint32_t ** processed_symbol, uint32_t ** input, 
                             uint32_t ** partition_output_base, uint32_t** partition_output_count, uint32_t ** output, uint32_t **simulated_output ){
  uint32_t globalId = blockIdx.x * blockDim.x + threadIdx.x;
  uint32_t total_thread =   gridDim.x * blockDim.x ;
  uint32_t startVar = globalId * VARIABLE;
  uint32_t startVar_shared = threadIdx.x * VARIABLE;


  __shared__ uint32_t var [VARIABLE * THREAD_PER_BLOCK];
  __shared__ uint32_t shared_input_base[THREAD_PER_BLOCK][INPUT]; 
  __shared__ uint32_t shared_input_length[THREAD_PER_BLOCK][INPUT]; 
  __shared__ uint32_t shared_input_current[THREAD_PER_BLOCK][INPUT]; 
  //__shared__ uint32_t shared_output_current[THREAD_PER_BLOCK][OUTPUT];
// initialize shared variable
  for ( uint32_t i = 0; i < INPUT; i++){
    shared_input_base[threadIdx.x][i] = input_base[globalId][i];
    shared_input_length[threadIdx.x][i] = partition_length[globalId][i];
    shared_input_current[threadIdx.x][i] = 0;
  } 
  for ( uint32_t i = 0; i < VARIABLE; i++){
    var[threadIdx.x *VARIABLE + i] = 0 ;
  } 
  __syncthreads();
//printf(" Finish allocating shared variable\n");
#ifdef DEBUG_GPU
  uint32_t chosen_thread = 0;
  if (globalId == chosen_thread){
    printf( "State Table : %d state\n", STATE_COUNT);
    for ( uint32_t i = 0 ; i < STATE_COUNT; i++)      
      printf("S[%d]: %d, %d, %d, %d\n", stateList[i].id,  stateList[i].opt, stateList[i].src1, stateList[i].src2, stateList[i].dst);
    printf( "Transition Table : %d transition\n", TRANSITION_COUNT);
    for ( uint32_t i = 0 ; i < TRANSITION_COUNT; i++){      
      printf("T[%d]: %d-%d, %d-%d, %d | ", transitionList[i].id, transitionList[i].inputID, transitionList[i].inputSymbol, transitionList[i].IvarID, transitionList[i].inputVar, transitionList[i].currentState);          
      printf(" %d-%d, %d-%d, %d \n", transitionList[i].outputID, transitionList[i].outputSymbol, transitionList[i].OvarID, transitionList[i].outputVar, transitionList[i].nextState);
    }
    printf(" Allocate %d variable ", VARIABLE * THREAD_PER_BLOCK + 2*THREAD_PER_BLOCK*INPUT);
    printf(" of %d byte \n",sizeof(uint32_t)*  ( VARIABLE * THREAD_PER_BLOCK + 2*THREAD_PER_BLOCK*INPUT));
    for (uint32_t i = startVar_shared ; i < ( startVar_shared +  VARIABLE ) ; i++){
      printf( "V[%d]=%d , ", i , var[i]);
    }
    printf("\n");
      for (uint32_t j = 0; j < INPUT; j++){
        printf( "Input_length[%d][%d]=%d , ",threadIdx.x, j, shared_input_length[threadIdx.x][j]);
        printf( "Input_current[%d][%d]=%d \n ",threadIdx.x, j, shared_input_current[threadIdx.x][j]);
      }
    printf("\n");
  }
#endif
// execution
  
  uint32_t currentState = 0;
  uint32_t stateCount = STATE_COUNT;
  bool done = false;
  uint32_t chosenTransition = TRANSITION_COUNT;
  uint32_t cycle = 0;
#ifdef DEBUG_GPU
  while ( cycle < 200){
    __syncthreads();
    if ( globalId == chosen_thread){
      printf("-------------%d-----------------\n", cycle);
      printf( " Activated State: %d\n", currentState);
      for (uint32_t v = startVar; v < ( startVar_shared+  VARIABLE ) ; v++)
        printf( "V[%d] = %u | ", v, var[v]);
      printf("\n");

      for (uint32_t p = 0; p < INPUT; p++){
        printf("Input[%d]: ", p);
      for (uint32_t q = shared_input_base[threadIdx.x][p]; q <(shared_input_base[threadIdx.x][p] +   10); q++)
        printf("%d, ", input[p][q]);
      printf("\n");

      printf("Current[%d]:  %d - %d total %d \n",p,shared_input_base[threadIdx.x][p],  shared_input_current[threadIdx.x][p], shared_input_length[threadIdx.x][p]);
      for (uint32_t k = shared_input_base[threadIdx.x][p]; k <(shared_input_base[globalId][p] +  shared_input_current[threadIdx.x][p]); k++)
        printf("%u, ", input[p][k]);
      printf("\n");
      }
      for (uint32_t p = 0; p < OUTPUT; p++){
        printf("OutPut[%d]: ", p);
        for (uint32_t k = partition_output_base[globalId][p]; k < partition_output_base[globalId][p] + partition_output_count[globalId][p]; k++){
          printf("%u, ", output[p][k]);
        }
        printf("\n");
      }
    printf("Rerform Action\n");
    }
    cycle++;
#else
  while (  ( !done) && ( currentState != stateCount)){
#endif

    // state action
    state_action_d_thread( var, currentState, threadIdx.x * VARIABLE);
    
#ifdef DEBUG_GPU
    if ( globalId == chosen_thread)   printf( "Perform Action on state %d\n", currentState);
#endif
    // transition evaluation
    chosenTransition = transition_eval_d_thread( var, currentState, startVar_shared,  input, shared_input_base[threadIdx.x],  shared_input_current[threadIdx.x]);
     //__syncthreads();
#ifdef DEBUG_GPU
    if ( globalId == chosen_thread) {
      uint32_t baseID = stateList[currentState].baseID;
      uint32_t numberofTransition = stateList[currentState].numberofTransition;
      printf( "Evaluate Transition on T%d\n", chosenTransition);
      printf(" Considering Transition %d to %d\n", baseID, baseID+ numberofTransition -1 );
    }
#endif
    currentState =
    transition_write_d_thread(var, chosenTransition, startVar_shared,input, shared_input_base[threadIdx.x],   shared_input_current[threadIdx.x],  output,simulated_output[globalId],  partition_output_count[globalId], partition_output_base[globalId]);

     //__syncthreads();
#ifdef DEBUG_GPU
    if ( globalId == chosen_thread) printf( "Write Next State %d\n", currentState);
#endif

    // consumed input and deactivate transition
    if (currentState == STATE_COUNT){
      done = true;
    }
    else {
      if( transitionList[chosenTransition].inputID != EPSILON_MATCH) {
        shared_input_current[threadIdx.x][transitionList[chosenTransition].inputID-INPUT_MATCH]++;
        chosenTransition = TRANSITION_COUNT;
        }
    done = is_done_processed_thread( shared_input_current[threadIdx.x], shared_input_length[threadIdx.x]);
    }
  }
  __syncthreads();
#ifdef DEBUG_GPU
  if ( globalId == chosen_thread){
    printf("Thread %d finished with %d cycle, %d output \n",  globalId, cycle, partition_output_count[globalId][0]);
    printf( " total Thread %d \n",  gridDim.x * blockDim.x );
    for ( uint32_t j = 0; j < fst->inputCount; j++){
      printf("T%d:  %d, ",globalId,  partition_output_base[globalId][j]);
      printf(" %d|  ", partition_output_count[globalId][j]);
    }
  }
#endif
}

void FSTGPU::process_thread( TPGPU * transducer){
  printf("Begin Execution\n");
  printf(" Number of block: %d \n", number_of_block);
  printf(" Number of thread per block: %d\n", number_of_thread);
  cudaEvent_t start_execution, stop_execution;
  cudaEventCreate( &start_execution);
  cudaEventCreate( &stop_execution);

  cudaEventRecord( start_execution, 0);
  process_k_thread <<< number_of_block,number_of_thread>>> (transducer,partition_input_base,  partition_input_length, partition_input_current, input,  partition_output_base,  partition_output_current,  output , simulated_output);
  cudaEventRecord( stop_execution,0);
  cudaEventSynchronize(stop_execution);
  float execution_time_ms = 0;
  cudaEventElapsedTime(&execution_time_ms, start_execution, stop_execution);
  //cudaDeviceSynchronize();
  printf("Execution  Finished\n");
  cudaError_t err = cudaGetLastError();
  if ( err != cudaSuccess )
    printf("CUDA Error: %s\n", cudaGetErrorString(err));       
  fprintf(stderr,"Execution Time %f ms\n", execution_time_ms);
}

void FSTGPU::topo_global_to_constant_thread(TP * cpu_transducer){

  cudaMemcpyToSymbol ( stateList, cpu_transducer->stateList, STATE_COUNT * sizeof(NPDT));
  cudaMemcpyToSymbol ( transitionList, cpu_transducer->transitionList, TRANSITION_COUNT * sizeof(Transition));
}

