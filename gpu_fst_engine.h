#pragma once
//#include "processor_gpu.h"
#include "processor.h"
#include "shared.h"
#define OUTPUT_PER_THREAD 1000
#define MIN_LENGTH 10
#define DEBUG_GPU 1
//#undef DEBUG_GPU

#define SAME_START 1
//#undef SAME_START

#define TIMING 1 
__constant__  NPDT stateList[STATE_COUNT];
__constant__ Transition  transitionList[TRANSITION_COUNT];


enum COMPARECODE {  ALPHABET      = 0,
                      NEGALPHABET = 1,
                      EPS         = 2,
                      VAR         = 3,
                      INPT        = 4,
                      PASSTHROUGH = 5,
                      NEGVAR      = 6,
                      NEGINPT     = 7,
                      ILL         = 8
                  };

class FSTGPU {
  public:
// IO stream
  
  uint32_t inputCount;
  uint32_t **input;
  uint32_t * input_length;
  uint32_t outputCount;
  uint32_t ** output;

// IO partition Information
  uint32_t number_of_block;
  uint32_t number_of_thread;
  uint32_t total_threads;

  // temp varaible to simulate writing 
  uint32_t ** simulated_output;

  // how many symbol each thread have to process
  uint32_t ** partition_input_length;
  uint32_t ** partition_input_length_cpu;
  // where each thread process from
  uint32_t ** partition_input_base;
  uint32_t ** partition_input_base_cpu;
  // how many symbol each thread have processed
  uint32_t ** partition_input_current;
  uint32_t ** partition_input_current_cpu;
  // where each thread write to 
  uint32_t ** partition_output_base;
  uint32_t ** partition_output_base_cpu;
  // how many symbol have each thread written 
  uint32_t ** partition_output_current;
  uint32_t ** partition_output_current_cpu;
  // core function
  void IO_setup( TP * cpu_transducer, uint32_t blocks, uint32_t threads);
  void IO_partition ( TP* cpu_transducer, int test); 
  void topo_global_to_constant ( TP* cpu_transducer); 
  void topo_global_to_constant_thread ( TP* cpu_transducer); 
  void process(TPGPU * transducer);
  void process_shared(TPGPU * transducer);
  void process_constant(TPGPU * transducer);
  void process_thread(TPGPU * transducer);
  void copyBack( TP * transducer);

  // parition scheme
  void partition (  TP * cpu_transducer, int test); 
  void RLE_ENCODING( TP * cpu_transducer);
  void CSV_PARSING( TP * cpu_transducer);
  void RLE_DECODING( TP * cpu_transducer);
  void BP_ENCODING( TP * cpu_transducer);
  void COOCSR( TP * cpu_transducer);

  // helper function  
  void save_thread_config( TP * cpu_transducer, std::string destination);
  void printFST( TPGPU * transducer, bool state, bool transition, bool variable);
  void action_convert( uint32_t opcode, uint32_t src1, uint32_t src2, uint32_t dst);
  void transition_convert(uint32_t alphabet);
};
