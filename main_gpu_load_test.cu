//#include  "processor.h"
#include "gpu_fst_engine.h"
#include <stdlib.h>
#include <stdint.h>
#include <iostream>
#include <cstring>

int main ( int argc, char *argv[]){

  uint32_t threads= 0;
  uint32_t blocks = 0;
  uint32_t size_32b = 0;
  float size_gb = 0;
  uint32_t mode = 0;
 
  std:: cout << " SET thread per block : " << THREAD_PER_BLOCK << std::endl; 
  std:: cout << " SET MODE: " << MODE << std::endl; 
  std:: cout << " SET " << STATE_COUNT << " state"  << std::endl; 
  std:: cout << " SET " << TRANSITION_COUNT<< " transition"  << std::endl; 
  std:: cout << " SET VARIABLE : " << VARIABLE << std::endl; 
  std:: cout << " SET INPUT : " << INPUT << std::endl; 
  std:: cout << " SET OUTPUT : " << OUTPUT << std::endl; 
  std::cout << "Reading: " << argc << " arggument" << std::endl;
  if ( argc != 6) {
    std::cout << " need 6 argument ( config file, number_of_block, number_of_threads, size in GB( accepting floating point), execution mode ), only get " << argc<< " argument"<< std::endl;
 	std::cout << " Mode 0: Global Memory" << std::endl;
 	std::cout << " Mode 1: Topology in Shared Memory" << std::endl;
  exit(0);
  }
  std::string configFile  = std::string(argv[1]);
  mode = atoi( argv[5]);
  size_gb = atof( argv[4]);
  size_32b = (uint32_t) ( (size_gb * 1e9 )/ 4);
  threads = atoi( argv[3]);
  blocks = atoi( argv[2]);
  std::cout  << "block: : " << blocks<<std::endl;
  std::cout  << "thread: : " << threads<<std::endl;
  std::cout  << "input Size: : " << size_gb<<"GB or " << size_32b<< " element of 32bit"  <<std::endl;
  std::cout << "Config File: "<< configFile <<std::endl; 
  std::cout <<" Setting up argument" << std::endl;
  ARGUMENT  * argm = new ARGUMENT  ( configFile, size_32b);
  std::cerr << " Input Size : " << size_gb <<" GB" <<std::endl; 
  FSTGPU * FST_ENGINE = (FSTGPU *)malloc(sizeof( FSTGPU));
  TP * processor  = new TP( argm->config);
  printf("LOAD FST TO CPU\n");
  processor->loadFST_CPU();
  printf("INITIALIZE GPU FST\n");
  TPGPU * Hprocessor;
  cudaMalloc(&Hprocessor,  sizeof(TPGPU));
  
  printf("LOAD FST TO GPU\n");
  processor->loadFST_GPU( Hprocessor, blocks, threads);
  printf("START PRINTING FROM KERNEL\n");
  //FST_ENGINE->printFST( Hprocessor, 1,1,1);
  FST_ENGINE->IO_setup( processor, blocks, threads);
  FST_ENGINE->IO_partition (processor,  argm->benchmark_int);
  if ( mode == 0){
    FST_ENGINE->process (Hprocessor );
  }
  else if ( mode == 1){
    FST_ENGINE->process_shared(Hprocessor );
  }
  else if ( mode == 2){
    FST_ENGINE->topo_global_to_constant(processor);
    FST_ENGINE->process_constant(Hprocessor );
  }
  else if ( mode == 3){
    FST_ENGINE->topo_global_to_constant_thread(processor);
    FST_ENGINE->process_thread(Hprocessor );
  
  }
  std::cout <<" Application Finishes" << std::endl;
//return ;
}
