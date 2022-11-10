#include "gpu_fst_engine.h"

__global__ 
void printTransitionKernel1( TPGPU * transducer){
  printf("%d variable \n", transducer->varCount);
  printf("%d state \n", transducer->stateCount);
  printf("%d transition \n", transducer->transitionCount);
  for ( int i =0; i < transducer->varCount; i++){
    printf("variable[%d] = %d \n", i, transducer->var[i]);
  }

  for ( int i =0; i < transducer->stateCount; i++){
    printf("State %d \n", transducer->stateList[i].id);
  }
  for ( int i =0; i < transducer->transitionCount; i++){
    printf("Transition %d \n", transducer->transitionList[i].id);
  }
}

void FSTGPU::printFST( TPGPU * transducer, bool state, bool transition, bool variable){
  cudaError_t error;

  TPGPU * TEMP_FST = (TPGPU *) malloc (sizeof( TPGPU)); 
  cudaMemcpy( TEMP_FST, transducer, sizeof(TPGPU), cudaMemcpyDeviceToHost);

  if (state){
    printf("============================================\n");
    printf( "%d States\n", TEMP_FST->stateCount);
    NPDT * stateList = (NPDT *) malloc (TEMP_FST->stateCount * sizeof(NPDT));
    error = cudaMemcpy( stateList, TEMP_FST->stateList, TEMP_FST->stateCount * sizeof(NPDT), cudaMemcpyDeviceToHost);

    if ( error != cudaSuccess){
      printf( "GPU assert%s \n", cudaGetErrorString(error));
    }
    for (int i = 0; i < TEMP_FST->stateCount; i++){
      printf("STATE %d ", stateList[i].id);
      action_convert ( stateList[i].opt,stateList[i].src1, stateList[i].src2, stateList[i].dst);
    }
  }
  
  if ( transition){
    printf("============================================\n");
    printf( "%d Transition\n", TEMP_FST->transitionCount);
    Transition * transitionList = (Transition *) malloc (TEMP_FST->transitionCount * sizeof(Transition));
    error = cudaMemcpy( transitionList, TEMP_FST->transitionList, TEMP_FST->transitionCount * sizeof(Transition), cudaMemcpyDeviceToHost);

    if ( error != cudaSuccess){
      printf( "GPU assert%s \n", cudaGetErrorString(error));
    }
    for (int i = 0; i < TEMP_FST->transitionCount; i++){
      printf("T%d :", transitionList[i].id);
      transition_convert ( transitionList[i].inputID);
      printf("==");
      transition_convert ( transitionList[i].inputSymbol);
      printf(",");
      transition_convert ( transitionList[i].IvarID);
      printf("==");
      transition_convert ( transitionList[i].inputVar);
      printf(" -> ");
      printf(" T%d ", transitionList[i].nextState);
      transition_convert ( transitionList[i].outputID);
      printf("==");
      transition_convert ( transitionList[i].outputSymbol);
      printf(",");
      transition_convert ( transitionList[i].OvarID);
      printf("==");
      transition_convert ( transitionList[i].outputVar);
      printf("\n");
    }
  }
  if( variable){
    printf("============================================\n");
    printf( "%d Variable\n", TEMP_FST->varCount);
    uint32_t * varList = (uint32_t *) malloc (TEMP_FST->varCount * sizeof(uint32_t));
    error = cudaMemcpy( varList, TEMP_FST->var, TEMP_FST->varCount * sizeof(uint32_t), cudaMemcpyDeviceToHost);

    if ( error != cudaSuccess){
      printf( "GPU assert%s \n", cudaGetErrorString(error));
    }
    for (int i = 0; i < TEMP_FST->varCount; i++){
      printf("S[%d] = %d \n", i,varList[i]);
    }
  }
}



void FSTGPU::action_convert( uint32_t opcode, uint32_t src1, uint32_t src2, uint32_t dst){
  switch ( opcode) {
    case 1: // ADD
      printf( "S[%d] = S[%d] + S[%d]\n", dst, src1, src2);;
      break;
    case 2: // ADD I
      printf( "S[%d] = S[%d] + %d\n", dst, src1, src2);;
      break;
    case 3: //  SUB
      printf( "S[%d] = S[%d] - S[%d]\n", dst, src1, src2);;
      break;
    case 4: // SUBI
      printf( "S[%d] = S[%d] - %d\n", dst, src1, src2);;
      break;
    case 5: //  MUL
      printf( "S[%d] = S[%d] * S[%d]\n", dst, src1, src2);;
      break;
    case 6: // MULI:
      printf( "S[%d] = S[%d] * %d\n", dst, src1, src2);;
      break;
    case 7: // DIV
      printf( "S[%d] = S[%d] / S[%d]\n", dst, src1, src2);;
      break;
    case 8: //DIVI
      printf( "S[%d] = S[%d] / %d\n", dst, src1, src2);;
      break;
    case 9:
      printf("NO LONGER SUPPORT SET");
      break;
    case 10:
      printf("NO LONGER SUPPORT POP");
      break;
    case 11:  // LSHIFT
      printf( "S[%d] = S[%d] << S[%d]\n", dst, src1, src2);;
      break;
    case 12:  // LSHIFTI 
      printf( "S[%d] = S[%d] << %d\n", dst, src1, src2);;
      break;   
    case 13:  // RSHIFT
      printf( "S[%d] = S[%d] >> S[%d]\n", dst, src1, src2);;
      break;
    case 14:  // RSHIFTI
      printf( "S[%d] = S[%d] >> %d\n", dst, src1, src2);;
      break;
    case 15:  //  OR
      printf( "S[%d] = S[%d] | S[%d]\n", dst, src1, src2);;
      break;
    case 16:  //  ORI
      printf( "S[%d] = S[%d] | %d\n", dst, src1, src2);;
      break;
    case 17:  //  AND
      printf( "S[%d] = S[%d] & S[%d]\n", dst, src1, src2);;
      break;
    case 18:  //  ANDI
      printf( "S[%d] = S[%d] & %d\n", dst, src1, src2);;
      break;
    case 0:
      printf("Epsilon\n");
      break;
      }
}



void FSTGPU::transition_convert ( uint32_t alphabet) {
int epsilon = 222;
  if ( alphabet < ALPHABETSIZE)  
    printf("%c",  alphabet);
  else if ( (alphabet >= ALPHABETSIZE)  && ( alphabet < EPSILON_MATCH) ){
    printf( "!%c", alphabet-ALPHABETSIZE);
    }
  else if (   alphabet  == EPSILON_MATCH) {
    printf("%c", epsilon);
  }
  else if ( ( alphabet  >= VARSTART ) && (alphabet  < (VARSTART + MAXVAR ) ) ) {
    printf( "S[%d]", alphabet - (VARSTART));
  }
  else if ( ( alphabet  >= INPUTSTART)  && (alphabet  < (INPUTSTART + MAXVAR) )  ) {
    printf("I[%d]",alphabet- (INPUTSTART));
  }
  else if (   alphabet  == ANY_MATCH) {
    printf("*");
  }
  else if ( ( alphabet  >= OUTPUTSTART) && (alphabet  < (OUTPUTSTART + MAXVAR) )  ){
    printf("O[%d]",alphabet- (OUTPUTSTART));
  }
  else if ( ( alphabet  >=  (VARSTART + ALPHABETSIZE) )  && ( alphabet < ( VARSTART + ALPHABETSIZE + MAXVAR)) ) {
    printf("!S[%d]", alphabet - (VARSTART) - (ALPHABETSIZE));
  }
  else if  ( (alphabet  >= (INPUTSTART + ALPHABETSIZE) ) && (alphabet < (INPUTSTART + MAXVAR + ALPHABETSIZE) )  ) {
    printf("!I[%d]", alphabet- (INPUTSTART) -(ALPHABETSIZE)) ;
  }
  else if (   alphabet  == ANY_PUSH) {
    printf("Push");
  }
}


