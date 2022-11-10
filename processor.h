#pragma once
#include <fstream>
#include <assert.h>
#include <iostream>
#include <map>
#include  "npdt.h"
#include  "argument.h"
#include  "processor_gpu.h"
#define PRINT_IO 1

#define DEBUG 1
#define OUTPUT_LENGTH 2048
/*
enum COMPARECODE {  ALPHABET    = 0, 
                    NEGALPHABET  = 1, 
                    EPS         = 2, 
                    STACK       = 3,  
                    INPT        = 4, 
                    PASSTHROUGH = 5, 
                    NEGSTACK    = 6, 
                    NEGINPT     = 7, 
                    ILL         = 8  
                  };
*/
enum MODE { NO_MEASURE  = 0,
            PAPI        = 1,
            TIME        = 2
          };
struct TPGPU;
class TP {   
public:
  std::map<std::string, uint64_t> opcode;
  /* Full transducer information  */
  helper * config;
  double start_time, end_time;
  
  uint32_t stateCount;
  uint32_t transitionCount;
  uint32_t varCount;
  uint32_t inputCount;
  uint32_t outputCount;

  /* stack and memory info  */  
  uint32_t * var;   
  NPDT * stateList;
  Transition * transitionList; 

  /* input and output Tape  */ 
  bool endofInput;
  uint32_t **inStream;
  uint32_t * input_length;
  uint32_t ** outStream;
  uint32_t *  output_length;


  /* State Action data  */
  bool * pendingTransition;  
  
  /* Transition Match data  */
  bool * confirmedTransition;  

  /* OutputUpdate data  */
  bool * activatedState;  


//  TP( uint64_t no_State, uint64_t no_transition, uint64_t no_stack, std::string inputPath, std::string outputPath);
  TP (helper * cf);
  void opt_optID ();
  void loadFST_CPU();
  void loadFST_GPU( TPGPU * h_processor, uint32_t blocks, uint32_t threads);
  /* setting up     */
  void readState ( std::string filename, int verbose = 0);
  void readTransition ( std::string filename, int verbose = 0);
  void reorderTransition();
  void to_DOT ( std::string destination);
  void epsilonMarker();
  std::string action_convert ( uint32_t opcode, uint32_t src1, uint32_t src2, uint32_t dst, bool log = false);
  std::string transition_convert ( uint32_t alphabet, bool log = false);
  /* helper */
  void printTransitionTable();
  void printStateTable();
  void printMemInfo();
};

