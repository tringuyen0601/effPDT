#include "processor.h"
#include "npdt.h"
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdlib.h>
#include <cmath>
#include <sys/time.h>

inline double gettime_ms(){
  timespec t;
  clock_gettime(CLOCK_MONOTONIC_RAW, &t);
  return (t.tv_sec + t.tv_nsec*1e-9)*1000;
}
TP::TP( helper * cf){

  printf("INITIALIZE on CPU\n");
  config = cf;
  stateCount          = config->stateno; 
  transitionCount     = config->transno;
  varCount            = config->varno; 
  inputCount          = config->inputno; 
  outputCount         = config->outputno; 
  endofInput          = false;
  stateList           = (NPDT *)        malloc (stateCount      * sizeof(NPDT));
  var                 = (uint32_t *)      malloc (varCount        * sizeof(uint32_t));
  transitionList      = (Transition *)  malloc (transitionCount * sizeof(Transition));
  
  pendingTransition   = (bool *)        malloc (transitionCount * sizeof(bool));
  confirmedTransition = (bool *)        malloc (transitionCount * sizeof(bool));
  activatedState      = (bool *)        malloc (stateCount      * sizeof(bool));

/*  set initial state to activated, the rest to not */
  activatedState[0] = 1;    
  stateList[0].accepting = 0; 
  for (uint32_t i = 1; i < stateCount; i++){
    stateList[i].accepting = 0; 
    stateList[i].epsilonState = false; 
    activatedState[i] = 0;    
  }
  for (uint32_t j = 0; j < transitionCount; j++){ 
    pendingTransition[j] = 0;    
    confirmedTransition[j] = 0;    
  }
  opt_optID();
/* initialize I/O stream  */
  inStream = (uint32_t **) malloc ( inputCount * sizeof( uint32_t *));
  input_length = (uint32_t *) malloc ( inputCount * sizeof( uint32_t ));
  printf("INITIALIZE IO on CPU\n");

  FILE * inputFile;
  if (( config->benchmark == COO_CSR) ||  ( config->benchmark == DENSE_CSR_PTR) ){
    inputFile = fopen( config->inputFile[0].c_str(), "r");
    fseek( inputFile, 0, SEEK_END);
    printf("reading meta data: %s\n",  config->inputFile[0].c_str());
    input_length[0] = ftell ( inputFile)/4;
    printf("Meta data has %u element\n", input_length[0] );
    inStream[0] = (uint32_t *) malloc ( (input_length[0]+1) * sizeof( uint32_t ));
    fseek( inputFile, 0, SEEK_SET);
    fread ( inStream[0], input_length[0],4, inputFile);
    fclose(inputFile);

    inputFile = fopen( config->inputFile[1].c_str(), "r");
    fseek( inputFile, 0, SEEK_END);
    printf("Reading Row index: %s\n",  config->inputFile[1].c_str());
    uint32_t filesize  = ftell ( inputFile)/4;
    uint32_t duplicate = config->size_32b / filesize;
    if ( duplicate ==0) duplicate = 1;
    input_length[1] = duplicate * filesize;
    printf("Row has %d element\n",filesize );
    printf("duplicate %d times to be %d bytes \n", duplicate,input_length[1]*4 );

    uint32_t *  filecontent  = (uint32_t *) malloc ( (filesize) * sizeof( uint32_t ));
    fseek( inputFile, 0, SEEK_SET);
    fread ( filecontent, filesize,4, inputFile);
    fclose(inputFile);

    printf("finished reading row\n");
    inStream[1] = (uint32_t *) malloc ( (input_length[1]+1) * sizeof( uint32_t ));
    memset( inStream[1], 0,  (input_length[1] + 1) * sizeof(uint32_t));

    printf("finished setting up row\n");
    for ( int k = 0; k < duplicate; k++){
      memcpy( &inStream[1][k * filesize], filecontent, filesize* sizeof(uint32_t));
    }
#ifdef PRINT_IO
    printf("Print input 0 of %u element\n", input_length[0]);
    uint32_t printsize = input_length[0];
    if (printsize > 10) printsize = 10;
    for ( int k  = 0; k < printsize; k++){
      printf("%u; ", inStream[0][k]);
    }
      printf("\n");
    printf("Print input 1 of %u element\n", input_length[1]);
    printsize = input_length[1];
    if (printsize > 10) printsize = 10;
    for ( int k  = 0; k < printsize; k++){
      printf("%u; ", inStream[1][k]);
    }
      printf("\n");
#endif
    printf("Finishing input %d\n"); 
    printf("Initialize %d output\n", outputCount);
    outStream = (uint32_t **) malloc ( outputCount * sizeof( uint32_t *));
    output_length = (uint32_t *) malloc ( outputCount * sizeof( uint32_t ));

    output_length[0] = input_length[0] * duplicate; 
    printf("Print output  0 of %u element\n", output_length[0]);
    outStream[0] = (uint32_t *) malloc ( output_length[0] * sizeof( uint32_t ));
    memset( outStream[0], 0, output_length[0]* sizeof ( uint32_t));

    output_length[1] = input_length[1] + 1; 
    printf("Print output 1 of %u element\n", output_length[1]);
    outStream[1] = (uint32_t *) malloc ( output_length[1] * sizeof( uint32_t ));
    memset( outStream[1], 0, output_length[1]* sizeof ( uint32_t));
  }
  else {
    for ( uint32_t j = 0; j < inputCount; j++){
      inputFile = fopen( config->inputFile[j].c_str(), "r");
      fseek( inputFile, 0, SEEK_END);
      if ( j == 0){
        uint32_t filesize  = ftell ( inputFile)/4;
        uint32_t duplicate = config->size_32b / filesize;
        if ( duplicate ==0) duplicate = 1;
        input_length[j] = duplicate * filesize;
        printf("Input %d has %d element\n", j,filesize );
        printf("duplicate %d times to be %d bytes \n", duplicate,input_length[j]*4 );

        uint32_t *  filecontent  = (uint32_t *) malloc ( (filesize) * sizeof( uint32_t ));
        fseek( inputFile, 0, SEEK_SET);
        fread ( filecontent, filesize,4, inputFile);
        fclose(inputFile);

        printf("finished reading file\n");
        inStream[j] = (uint32_t *) malloc ( (input_length[j]+1) * sizeof( uint32_t ));
        memset( inStream[j], 0,  (input_length[j] + 1) * sizeof(uint32_t));

        printf("finished setting up\n");
        for ( int k = 0; k < duplicate; k++){
          memcpy( &inStream[j][k * filesize], filecontent, filesize* sizeof(uint32_t));
        }
      }
      else {
        printf("reading %s\n",  config->inputFile[j].c_str());
        input_length[j] = ftell ( inputFile)/4;
        printf("Input %d has %u element\n", j,input_length[j] );
        printf("Input %d size: %u bytes\n", j,input_length[j]*4 );
        inStream[j] = (uint32_t *) malloc ( (input_length[j]+1) * sizeof( uint32_t ));
        fseek( inputFile, 0, SEEK_SET);
        fread ( inStream[j], input_length[j],4, inputFile);
        fclose(inputFile);
      }
#ifdef PRINT_IO
      printf("Print input of %u element\n", input_length[j]);
      uint32_t printsize = input_length[j];
      if (printsize > 10) printsize = 10;
      for ( int k  = 0; k < printsize; k++){
        printf("%u; ", inStream[j][k]);
      }
      printf("\n");
#endif
      printf("Finishing input %d\n", j); 
    }

    printf("Initialize %d output\n", outputCount);
    outStream = (uint32_t **) malloc ( outputCount * sizeof( uint32_t *));
    output_length = (uint32_t *) malloc ( outputCount * sizeof( uint32_t ));
    //output_length[0] = OUTPUT_LENGTH; 
    output_length[0] = input_length[0] * 4; 
    printf("Print output of %u element\n", output_length[0]);
      for ( uint32_t j = 0; j < outputCount; j++){
      outStream[j] = (uint32_t *) malloc ( output_length[0] * sizeof( uint32_t ));
      memset( outStream[j], 0, output_length[0]* sizeof ( uint32_t));
    }
  }


// initialize variable
  for (uint32_t j = 0; j < varCount; j++){ 
    var[j]  = j;
  }
  printf("FINISH INITIALIZE on CPU\n");
  printMemInfo();
}

void TP::opt_optID ( ){
  opcode["EPSILON"] = 0;
  opcode["ADD"]     = 1;
  opcode["ADDI"]    = 2;
  opcode["SUB"]     = 3;
  opcode["SUBI"]    = 4;
  opcode["MUL"]     = 5;
  opcode["MULI"]    = 6;
  opcode["DIV"]     = 7;
  opcode["DIVI"]    = 8; 
  opcode["SET"]     = 9; 
  opcode["POP"]     = 10; 
  opcode["LSHIFT"]  = 11; 
  opcode["LSHIFTI"] = 12; 
  opcode["RSHIFT"]  = 13; 
  opcode["RSHIFTI"] = 14; 
  opcode["OR"]      = 15; 
  opcode["ORI"]     = 16; 
  opcode["AND"]     = 17; 
  opcode["ANDI"]    = 18; 
}

void TP::epsilonMarker (){
  for (uint64_t i = 0; i < transitionCount; i++){
    if ( transitionList[i].inputSymbol == EPSILON_MATCH)
      stateList[ transitionList[i].currentState].epsilonState = true;
    }
}

