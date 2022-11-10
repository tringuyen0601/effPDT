// initialize by reading a config file
#pragma once
#include  <cstring>
#include  <string>
#include  <stdlib.h>
#include  <stdio.h>
#include  <fstream>
#include  <iostream>
#include  <assert.h>
#include  "helper.h"

class ARGUMENT {
  public:
  // helper config
    int number_of_input;
    std::string *  InputFile;
    int number_of_output;
    std::string *  OutputFile;
    std::string benchmark_str;
    int benchmark_int;
    
    helper  * config; 

    ARGUMENT( std::string configFile, uint32_t inputsize);
    int benchmarkConvert  ( std::string testname);
    void TestInfo( uint32_t inputsize);
};
