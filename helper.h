#pragma once
#include <stdint.h>
#include <string>
#include <stdlib.h>
enum BENCHMARK  { 
  RLE_ENCODE        = 0,
  RLE_ENCODE_OPT    = 1,
  RLE_DECODE        = 2,
  RLE_DECODE_OPT    = 3,
  BP_ENCODE         = 4,
  BP_DECODE         = 5,               
  GV_ENCODE         = 6,
  GV_DECODE         = 7,               
  DENSE_DOK         = 8,
  DOK_LIL           = 9,
  LIL_COO           = 10,
  COO_CSR           = 11,
  STACK_POP         = 12,
  MULTI_WRITE       = 13,
  DENSE_CSR         = 14,
  CSR_DENSE         = 15,
  RLE_ENCODE_NO_STACK = 16,
  BP_ENCODE_NO_STACK = 17,
  BP_DECODE_NO_STACK = 18,
  DENSE_CSR_PTR         = 19,
  CSV_ENC_DET    = 20
};



class helper {
  public:
  int benchmark;
// transducer config
  uint32_t  varno;
  uint32_t  stateno;
  uint32_t  transno;
  uint32_t  inputno;
  uint32_t  outputno;
  uint32_t  size_32b;
  std::string stateFile; 
  std::string transitionFile; 
  std::string configFile; 
  std::string * inputFile; 
  std::string * outputFile; 
  std::string dotFile; 


  helper ( std::string * infile, std::string *outfile, uint32_t inputsize,  int test);
  void transducer_config();
};
