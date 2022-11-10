#pragma once
#include <stdint.h>
#define MAXVAR 64

#define ALPHABETSIZE 256
#define EPSILON_MATCH 512

#define VARSTART  EPSILON_MATCH  + 1
#define INPUTSTART VARSTART + MAXVAR 
#define ANY_MATCH  641
#define OUTPUTSTART ANY_MATCH + 1

#define ANY_PUSH  ANY_MATCH + 256
#define INPUT_MATCH  577
#define NOT_INPUT INPUT_MATCH + 256

#define OUTPUT_START 642
enum OPERATION {  EPSILON = 0, 
                  ADD     = 1, 
                  ADDI    = 2, 
                  SUB     = 3, 
                  SUBI    = 4, 
                  MUL     = 5, 
                  MULI    = 6, 
                  DIV     = 7, 
                  DIVI    = 8, 
                  SET     = 9, 
                  POP     = 10,
                  LSHIFT  = 11,
                  LSHIFTI = 12,
                  RSHIFT  = 13,
                  RSHIFTI = 14,
                  OR      = 15,
                  ORI     = 16,
                  AND     = 17, 
                  ANDI    = 18 
                };

class NPDT {

public:
  /* state identifier */
  uint32_t id;

  /* outgoing transition  */
  uint32_t  baseID;
  uint32_t  numberofTransition;

  /* action           */
  
  uint32_t   src1;
  uint32_t   src2;
  uint32_t   dst;
  uint8_t opt;
    
  /* helper variable  */
  bool accepting;
  bool initial;
  bool epsilonState;
  
  /* helper function  */
  //void print_State();

};


class Transition {
public:
  /* helper variable  */
  uint32_t id;

  /* Matching condition */
  uint32_t  inputID;
  uint32_t  inputSymbol;
  uint32_t  IvarID;
  uint32_t  inputVar;
  uint32_t  currentState;

  /* Result */
  uint32_t  outputID;
  uint32_t  outputSymbol;
  uint32_t  OvarID;
  uint32_t  outputVar;
  uint32_t  nextState;

  /* helper function  */
  //void print_Transition();
};
