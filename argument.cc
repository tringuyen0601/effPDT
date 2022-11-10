#include  "argument.h"

ARGUMENT::ARGUMENT (std::string configFile, uint32_t inputsize){
  std::ifstream cf ( configFile, std::ios::in);

  std::string line;
  std::cout <<"Read Input"<< std::endl;
  /* read number of input  */
  getline(cf, line);
  std::cout <<line << std::endl;
  char * str = const_cast<char*> (line.c_str());
  char * token = strtok( str, ":");
  token = strtok( NULL, ", |");
  std::string str_token = std::string(token);
  number_of_input = uint64_t (std::stoi(str_token));
  InputFile   = (std::string  *) malloc ( number_of_input * sizeof(std::string));
  for ( int i =0; i < number_of_input; i++){

    getline(cf, line);
    str = const_cast<char*> (line.c_str());
    std::cout << "reading: "<< str<< std::endl;
    token = strtok( str, ":");
    std::cout << "Parsing: " << token<< std::endl;
    token = strtok( NULL, ", |");
    std::cout << "Parsing: " << token<< std::endl;
    new ( &(InputFile)[i]) std::string(token);
   // InputFile[i]  = std::string(token);
    std::cout <<"INPUT FILE: " << InputFile[i]<< std::endl;
  }


  std::cout <<"Read Output"<< std::endl;
  /* read number of output  */
  getline(cf, line);
  str = const_cast<char*> (line.c_str());
  token = strtok( str, ":");
  token = strtok( NULL, ", |");
  str_token = std::string(token);
  number_of_output = uint64_t (std::stoi(str_token));
  OutputFile   = (std::string  *) malloc ( number_of_output * sizeof(std::string));
  for ( int i =0; i < number_of_output; i++){
    getline(cf, line);
    str = const_cast<char*> (line.c_str());
    token = strtok( str, ":");
    token = strtok( NULL, ", |");
    new ( &(OutputFile)[i]) std::string(token);
    //OutputFile[i]  = std::string(token);
  }

  /* get test name  */
  std::cout <<"Read Testname"<< std::endl;
  getline(cf, line);
  str = const_cast<char*> (line.c_str());
  token = strtok( str, ":");
  token = strtok( NULL, ", |");
  benchmark_str = std::string(token);
  benchmark_int = benchmarkConvert( benchmark_str);

  std::cout <<"Config"<< std::endl;
  config  = new helper( InputFile, OutputFile, inputsize,  benchmark_int);

  TestInfo( inputsize);
}


int ARGUMENT::benchmarkConvert(std::string testname){
  if  (testname ==  "RLE_ENCODE")     return  RLE_ENCODE;
  if  (testname ==  "RLE_ENCODE_NO_STACK")     return  RLE_ENCODE_NO_STACK;
  if  (testname ==  "RLE_ENCODE_OPT") return  RLE_ENCODE_OPT;
  if  (testname ==  "RLE_DECODE")     return   RLE_DECODE;
  if  (testname ==  "RLE_DECODE_OPT") return RLE_DECODE_OPT;
  if  (testname ==  "BP_ENCODE")      return  BP_ENCODE;
  if  (testname ==  "BP_ENCODE_NO_STACK")      return  BP_ENCODE_NO_STACK;
  if  (testname ==  "BP_DECODE")      return  BP_DECODE;
  if  (testname ==  "BP_DECODE_NO_STACK")      return  BP_DECODE_NO_STACK;
  if  (testname ==  "GV_ENCODE")      return GV_ENCODE;
  if  (testname ==  "GV_DECODE")      return  GV_DECODE;
  if  (testname ==  "DENSE_DOK")      return  DENSE_DOK;
  if  (testname ==  "DOK_LIL")        return  DOK_LIL;
  if  (testname ==  "LIL_COO")        return  LIL_COO;
  if  (testname ==  "COO_CSR")        return  COO_CSR;
  if  (testname ==  "STACK_POP")      return  STACK_POP;
  if  (testname ==  "MULTI_WRITE")    return MULTI_WRITE;
  if  (testname ==  "DENSE_CSR")      return  DENSE_CSR;
  if  (testname ==  "CSR_DENSE")      return  CSR_DENSE;
  if  (testname ==  "DENSE_CSR_PTR")      return  DENSE_CSR_PTR;
  if  (testname ==  "CSV_ENC_DET") return  CSV_ENC_DET;
  std::cout<< " INVALID TEST"<<std::endl;
  assert(1);
  return 1;   
    
}

void ARGUMENT::TestInfo( uint32_t inputsize){
  std::cerr << "Benchmark: " << benchmark_str << "(" <<  benchmark_int<<")"  <<std::endl;
  std::cerr<< " Number of Input: "  << number_of_input<<std::endl;
  for ( int i = 0; i < number_of_input; i++){
    std::cerr << "Input File[" <<i<<"]  "<< InputFile[i] <<std::endl;
  }
  std::cerr<< " Number of Output: "  << number_of_output<<std::endl;
  for ( int i = 0; i < number_of_output; i++){
    std::cerr << "Output File[" <<i<<"]   "<<   OutputFile[i] <<std::endl;  
  }
}
