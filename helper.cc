#include "helper.h"
#include <iostream>
#include <fstream>
#include <string.h>

helper::helper ( std::string * infile, std::string  * outfile, uint32_t inputsize,  int test){
  std::string base;
  benchmark= test;
  switch(test){
    case RLE_ENCODE:
      base            = "./testcases/rle_encode";
      stateFile       = base + "/rle_encode_state.txt";
      transitionFile  = base + "/rle_encode_transition.txt";
      configFile      = base + "/rle_encode_config.txt";
      dotFile         = "./graph/rle_encode_";
      break;
    case RLE_ENCODE_NO_STACK:
      base            = "./testcases/rle_encode_no_stack";
      stateFile       = base + "/rle_encode_state.txt";
      transitionFile  = base + "/rle_encode_transition.txt";
      configFile      = base + "/rle_encode_config.txt";
      dotFile         = "./graph/rle_encode_no_stack_";
      break;
    case RLE_ENCODE_OPT:
      base            = "./testcases/rle_encode_opt";
      stateFile       = base + "/rle_encode_state.txt";
      transitionFile  = base + "/rle_encode_transition.txt";
      configFile      = base + "/rle_encode_config.txt";
      dotFile         = "./graph/rle_encode__opt_";
      break;
    case RLE_DECODE:
      base            = "./testcases/rle_decode";
      stateFile       = base + "/rle_decode_state.txt";
      transitionFile  = base + "/rle_decode_transition.txt";
      configFile      = base + "/rle_decode_config.txt";
      dotFile         = "./graph/rle_decode_";
      break;
    case RLE_DECODE_OPT:
      base            = "./testcases/rle_decode_opt";
      stateFile       = base + "/rle_decode_state.txt";
      transitionFile  = base + "/rle_decode_transition.txt";
      configFile      = base + "/rle_decode_config.txt";
      dotFile         = "./graph/rle_decode_opt_";
      break;
    case BP_ENCODE:
      base            = "./testcases/bp_encode";
      stateFile       = base + "/bp_encode_state.txt";
      transitionFile  = base + "/bp_encode_transition.txt";
      configFile      = base + "/bp_encode_config.txt";
      dotFile         = "./graph/bp_encode_";
      break;
    case BP_ENCODE_NO_STACK:
      base            = "./testcases/bp_encode_novar";
      stateFile       = base + "/bp_encode_novar_state.txt";
      transitionFile  = base + "/bp_encode_novar_transition.txt";
      configFile      = base + "/bp_encode_novar_config.txt";
      dotFile         = "./graph/bp_encode_novar_";
      break;
    case BP_DECODE:
      base            = "./testcases/bp_decode";
      stateFile       = base + "/bp_decode_state.txt";
      transitionFile  = base + "/bp_decode_transition.txt";
      configFile      = base + "/bp_decode_config.txt";
      dotFile         = "./graph/bp_decode_";
      break;
    case BP_DECODE_NO_STACK:
      base            = "./testcases/bp_decode_novar";
      stateFile       = base + "/bp_decode_novar_state.txt";
      transitionFile  = base + "/bp_decode_novar_transition.txt";
      configFile      = base + "/bp_decode_novar_config.txt";
      dotFile         = "./graph/bp_decode_novar_";
      break;
    case GV_ENCODE:
      base            = "./testcases/gv_encode";
      stateFile       = base + "/gve_state.txt";
      transitionFile  = base + "/gve_transition.txt";
      configFile      = base + "/gve_config.txt";
      dotFile         = "./graph/gv_encode_";
      break;
    case GV_DECODE:
      base            = "./testcases/gv_decode";
      stateFile       = base + "/gvd_state.txt";
      transitionFile  = base + "/gvd_transition.txt";
      configFile      = base + "/gvd_config.txt";
      dotFile         = "./graph/gv_decode_";
      break;
    case DENSE_DOK:
      base            = "./testcases/dense_dok";
      stateFile       = base + "/dense_dok_state.txt";
      transitionFile  = base + "/dense_dok_transition.txt";
      configFile      = base + "/dense_dok_config.txt";
      dotFile         = "./graph/dense_dok_";
      break;
    case DOK_LIL:
      base            = "./testcases/dok_lil";
      stateFile       = base + "/dok_lil_state.txt";
      transitionFile  = base + "/dok_lil_transition.txt";
      configFile      = base + "/dok_lil_config.txt";
      dotFile         = "./graph/dok_lil_";
      break;
    case  LIL_COO:
      base            = "./testcases/lil_coo";
      stateFile       = base + "/lil_coo_state.txt";
      transitionFile  = base + "/lil_coo_transition.txt";
      configFile      = base + "/lil_coo_config.txt";
      dotFile         = "./graph/lil_coo_";
      break;
    case  COO_CSR:
      base            = "./testcases/coo_csr";
      stateFile       = base + "/coo_csr_ptr_state.txt";
      transitionFile  = base + "/coo_csr_ptr_transition.txt";
      configFile      = base + "/coo_csr_ptr_config.txt";
      dotFile         = "./graph/coo_csr_ptr_";
      break;
    case  STACK_POP:
      base            = "./testcases/stackPop";
      stateFile       = base + "/stackPop_state.txt";
      transitionFile  = base + "/stackPop_transition.txt";
      configFile      = base + "/stackPop_config.txt";
      dotFile         = "./graph/stackPop_";
      break;
    case  MULTI_WRITE:
      base            = "./testcases/multi_write";
      stateFile       = base + "/multiWrite_state.txt";
      transitionFile  = base + "/multiWrite_transition.txt";
      configFile      = base + "/multiWrite_config.txt";
      dotFile         = "./graph/multiWrite_";
      break;
    case DENSE_CSR:
      base            = "./testcases/dense_csr";
      stateFile       = base + "/dense_csr_state.txt";
      transitionFile  = base + "/dense_csr_transition.txt";
      configFile      = base + "/dense_csr_config.txt";
      dotFile         = "./graph/dense_csr_";
      break;
    case DENSE_CSR_PTR:
      base            = "./testcases/dense_csr_ptr";
      stateFile       = base + "/dense_csr_state.txt";
      transitionFile  = base + "/dense_csr_transition.txt";
      configFile      = base + "/dense_csr_config.txt";
      dotFile         = "./graph/dense_csr_ptr_";
      break;
    case CSR_DENSE:
      base            = "./testcases/csr_dense";
      stateFile       = base + "/csr_dense_state.txt";
      transitionFile  = base + "/csr_dense_transition.txt";
      configFile      = base + "/csr_dense_config.txt";
      dotFile         = "./graph/csr_dense_";
      break;
    case  CSV_ENC_DET:
      base            = "./testcases/csv_parsing";
      stateFile       = base + "/csv_state.txt";
      transitionFile  = base + "/csv_transition.txt";
      configFile      = base + "/csv_config.txt";
      dotFile         = "./graph/csv_enc_det_";
      break;
  }
 
  transducer_config(); 
  inputFile  = (std::string *) malloc ( inputno * sizeof(std::string));
  inputFile = infile;
  outputFile  = (std::string *) malloc ( outputno * sizeof(std::string));
  outputFile = outfile;
  size_32b = inputsize;
}
void helper::transducer_config(){
  std::ifstream fin ( configFile, std::ios::in );
  std::string line;


  getline(fin, line);
  char * str = const_cast<char*> (line.c_str());
  char * token = strtok( str, ":");

  /* read number of state  */
  token = strtok( NULL, ", |");
  std::string str_token = std::string(token);
  stateno = uint64_t (std::stoi(str_token));
  std::cout << " Number of State: " << stateno <<std::endl;


  getline(fin, line);
  str = const_cast<char*> (line.c_str());
  token = strtok( str, ":");

  /* read number of transition  */
  token = strtok( NULL, ", |");
  str_token = std::string(token);
  transno = uint64_t (std::stoi(str_token)) ;
  std::cout << " Number of transition: " << transno <<std::endl;


  getline(fin, line);
  str = const_cast<char*> (line.c_str());
  token = strtok( str, ":");

  /* read number of Variable  */
  token = strtok( NULL, ", |");
  str_token = std::string(token);
  varno = uint64_t (std::stoi(str_token));
  std::cout << " Number of Vaiable: " << varno <<std::endl;

  getline(fin, line);
  str = const_cast<char*> (line.c_str());
  token = strtok( str, ":");

  /* read number of Input  */
  token = strtok( NULL, ", |");
  str_token = std::string(token);
  inputno = uint64_t (std::stoi(str_token));
  std::cout << " Number of Input Stream: " << inputno <<std::endl;

  getline(fin, line);
  str = const_cast<char*> (line.c_str());
  token = strtok( str, ":");

  /* read number of Output  */
  token = strtok( NULL, ", |");
  str_token = std::string(token);
  outputno = uint64_t (std::stoi(str_token));
  std::cout << " Number of Output Stream: " << outputno <<std::endl;

}

