#pragma once
#include <fstream>
#include <assert.h>
#include <iostream>
#include <map>
#include "processor.h"
#define DEBUG 1

struct TPGPU {   
  /* Full transducer information  */
  
  uint32_t stateCount;
  uint32_t transitionCount;
  uint32_t varCount;
  uint32_t inputCount;
  uint32_t outputCount;

  /* stack and memory info  */  
  uint32_t * var;   
  NPDT * stateList;
  Transition * transitionList; 

  /* State Action data  */
  bool * pendingTransition;  
  
  /* Transition Match data  */
  uint32_t confirmedTransition;  

  /* OutputUpdate data  */
  uint32_t  activatedState;  
};

