#include "processor.h"
#include <string>
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdlib.h>

/////////////////////////////////////////////////////
void TP::loadFST_CPU(){
  std::cout <<" Read State from "<<config->stateFile.c_str()<<  std::endl;
  readState(config->stateFile.c_str(), 1);
  std::cout <<" Read Transition"<<std::endl;
  readTransition (config->transitionFile.c_str(), 1);
  reorderTransition();

  //epsilonMarker();

  to_DOT( config->dotFile + "base.dot");
}

/* Read State value from an input file  */
void TP::readState( std::string filename, int verbose ){
  std::ifstream fin ( filename, std::ios::in );
  std::string line;
  uint32_t i = 0;
  while ( getline(fin, line)){
    char * str = const_cast<char*> (line.c_str());
    /* read state ID  */
    char * token = strtok( str, ", |");
    std::string str_token = std::string(token);
    stateList[i].id  = (uint32_t) std::stoi(str_token);
    if ( verbose){
      std::cout  << "State "<<str_token <<": " ;
    }

    /* read Action Optcode  */
    /* process opcode   */
    token = strtok( NULL, ", |");
    stateList[i].opt  = opcode.at(token);
    if ( verbose){
      std::cout << stateList[i].opt;
      std::cout << token << ", ";
    }
    /* process source 1 */
    char * source1 = strtok( NULL, ", |");
    std::string str_source1 = std::string(source1);
    if ( verbose){
      std::cout << str_source1  << ",";
    }
    stateList[i].src1  = (uint32_t) std::stoi(str_source1);

    /* process source 2 */
    token = strtok( NULL, ", |");
    str_token = std::string(token);
    if ( verbose){
      std::cout << token << " ,";
    }
    stateList[i].src2  = (uint32_t) strtoul(str_token.c_str(),NULL, 0);


    /* process destination */
    token = strtok( NULL, ", |");
    str_token = std::string(token);
    if ( verbose){
      std::cout << token << " ,";
    }
    stateList[i].dst  = (uint32_t) std::stoi(str_token);
    
    /* process InitialState */
    token = strtok( NULL, ", |");
    str_token = std::string(token);
    if ( verbose){
      std::cout << token << " ,";
    }
    stateList[i].initial  = (bool) std::stoi(str_token);

    /* process acceptingState */
    token = strtok( NULL, ", |");
    str_token = std::string(token);
    if ( verbose){
      std::cout << token << std::endl;
    }
    stateList[i].accepting  = (bool) std::stoi(str_token);
    stateList[i].baseID = 0;
    stateList[i].numberofTransition = 0;
    i++;
  }
  //stateList[i-1].accepting = 1;
}

void TP::readTransition ( std::string filename , int verbose ){

  std::cout << " READ from " << filename.c_str() << std::endl;
  std::ifstream fin ( filename, std::ios::in );
  std::string line;
  uint32_t i = 0;
  while ( getline(fin, line)){
    char * str = const_cast<char*> (line.c_str());

    /* read transition ID  */
    char * token = strtok( str, " : , - |");
    std::string str_token = std::string(token);
    transitionList[i].id  = (uint32_t) std::stoi(str_token);
    if ( verbose) std::cout << "Transition "<<token <<": " ;

    /* read matching condition  */
    /* input Tape ID  */
    char * InputTapeID = strtok( NULL, ": , - |");
    std::string str_InputTapeID = std::string(InputTapeID);
    if( verbose) std::cout << str_InputTapeID  << "-";
    transitionList[i].inputID  = (uint32_t) std::stoi(str_InputTapeID);

    /* input Tape Match  */
    char * InputMatch = strtok( NULL, ": , -  |");
    std::string str_InputMatch = std::string(InputMatch);
    if( verbose) std::cout << str_InputMatch  << ",";
    transitionList[i].inputSymbol  = (uint32_t) std::stoi(str_InputMatch);

    /* variable Match */
    char * varMatchID = strtok( NULL, ": , - |");
    std::string str_varMatchID = std::string(varMatchID);
    if(verbose) std::cout << str_varMatchID  << "-";
    transitionList[i].IvarID  = (uint32_t) std::stoi(str_varMatchID);
    
    char * varMatch = strtok( NULL, ": , - |");
    std::string str_varMatch = std::string(varMatch);
    if(verbose) std::cout << str_varMatch  << ",";
    transitionList[i].inputVar  = (uint32_t) std::stoi(str_varMatch);

    /* current State */
    char * curState = strtok( NULL, ": , - |");
    std::string str_curState = std::string(curState);
    if(verbose) std::cout << str_curState << " |";
    transitionList[i].currentState  = (uint32_t) std::stoi(str_curState);


    /* read Result   */
    /* output Tape ID */
    char * OutputTapeID = strtok( NULL, ": , - |");
    std::string str_OutputTapeID = std::string(OutputTapeID);
    if(verbose) std::cout << str_OutputTapeID  << "-";
    transitionList[i].outputID  = (uint32_t) std::stoi(str_OutputTapeID);

    /* output Tape  */
    char * OutputMatch = strtok( NULL, ": , -  |");
    std::string str_OutputMatch = std::string(OutputMatch);
    if(verbose) std::cout << str_OutputMatch  << ",";
    transitionList[i].outputSymbol  = (uint32_t) std::stoi(str_OutputMatch);

    /* output Variable */
    char * outputVarID = strtok( NULL, ": , - |");
    std::string str_outputVarID = std::string(outputVarID);
    if(verbose) std::cout << str_outputVarID  << "-";
    transitionList[i].OvarID  = (uint32_t) std::stoi(str_outputVarID);

    char * outputVar = strtok( NULL, ": , - |");
    std::string str_outputVar = std::string(outputVar);
    if(verbose) std::cout << str_outputVar  << ",";
    transitionList[i].outputVar  = (uint32_t) std::stoi(str_outputVar);

    /* Destination Tape */
    char * nState = strtok( NULL, ": , -  |");
    std::string str_nState = std::string(nState);
    if(verbose) std::cout << str_nState  << ",\n";
    transitionList[i].nextState  = (uint32_t) std::stoi(str_nState);
    i++;

  }
}

void TP::reorderTransition(){
  std::cout << " ORIGINAL  TRANSITION TABLE"<< std::endl;
//  printTransitionTable();
//  printStateTable();
  Transition * reorder  =   (Transition *) malloc ( transitionCount * sizeof(Transition)); 
  uint64_t count =0; 
  for ( uint32_t i=0; i<stateCount; i++ ){
    uint32_t size = 0;
    bool first = false;
    for ( uint32_t j =0; j < transitionCount; j++){
      if ( transitionList[j].currentState == i){

        if ( first == false) {
           stateList[i].baseID = count;
            first = true;
        }

        reorder[count].id       = count;
        reorder[count].inputID  = transitionList[j].inputID;
        reorder[count].inputSymbol  = transitionList[j].inputSymbol;
        reorder[count].IvarID  = transitionList[j].IvarID;
        reorder[count].inputVar  = transitionList[j].inputVar;
        reorder[count].currentState  = transitionList[j].currentState;

        reorder[count].outputID  = transitionList[j].outputID;
        reorder[count].outputSymbol  = transitionList[j].outputSymbol;
        reorder[count].OvarID  = transitionList[j].OvarID;
        reorder[count].outputVar  = transitionList[j].outputVar;
        reorder[count].nextState  = transitionList[j].nextState;
        count++;
        size++;
      }
    }
    stateList[i].numberofTransition = size;
  }
  //free( transitionList);
  transitionList  = reorder;
  //std::cout << " RE-ORDERED TRANSITION TABLE"<< std::endl;
  //printTransitionTable();
  //printStateTable();
}

/////////////////////////////////////////////////////////////////////////////////////
/* helper function  */

// dot generation function
void TP::to_DOT(std::string destination){
  std::ofstream fout ( destination, std::ios::out );
  fout << "digraph \"graph\" { "<<std::endl;
  fout << "\trankdir=LR;"<< std::endl; 

//// create states////
  fout <<"\tsubgraph statemachine {"<< std::endl;

  //std::cout << " Write State " <<std::endl;
  for ( uint32_t i = 0; i < stateCount; i++){
    fout << "N" << stateList[i].id ;
    fout <<"\t\t[shape = circle," <<std::endl; 
    //fout <<"\t\tlabel=\"ID:"<< stateList[i].id<<std::endl;
    fout <<"label=<ID:"<< stateList[i].id << " | ";
    //fout <<action_convert( stateList[i].opt) <<"," ;
    //fout <<stateList[i].src1 <<" ," <<stateList[i].src2 <<" ," << stateList[i].dst <<">" <<std::endl;
    fout <<action_convert( stateList[i].opt,  stateList[i].src1, stateList[i].src2, stateList[i].dst ) << " >";
    if(activatedState[i] == true    ) {
      fout <<"\t\tstyle = filled, color=\"#eb8034\"];" <<std::endl; 
    }
    else if( ( stateList[i].accepting == true) && (stateList[i].initial == false ) ){
      fout <<"\t\tcolor=\"red\"];" <<std::endl;
    }
    else if((stateList[i].accepting == false) &&  ( stateList[i].initial == true)) {
      fout <<"\t\tstyle = filled, color=\"lightblue\"];" <<std::endl; 
    }
    else if(activatedState[i] == true    ) {
      fout <<"\t\tstyle = filled, color=\"#eb8034\"];" <<std::endl; 
    }
    else {
      fout <<"\t\tcolor=\"black\"];" <<std::endl;
    }
  }

  //std::cout <<" Write Transition" <<std::endl;

  for ( uint32_t i = 0; i < transitionCount; i++){
    fout << "\tN" << transitionList[i].currentState <<" -> N" << transitionList[i].nextState ;
    fout << "[label=<T" << i << "  : (  ";
    fout << transition_convert( transitionList[i].inputID) << "==";
    fout << transition_convert( transitionList[i].inputSymbol) << ", ";
    fout << transition_convert( transitionList[i].IvarID) << "=="; 
    fout << transition_convert( transitionList[i].inputVar) << " | ";
    fout << transition_convert( transitionList[i].outputID) << "=";
    fout << transition_convert( transitionList[i].outputSymbol) << ", ";
    fout << transition_convert( transitionList[i].OvarID) << "="; 
    fout << transition_convert( transitionList[i].outputVar) << ")> ";

    fout << "color=\"black\"];" << std::endl;

  }
  fout <<"\t}" << std::endl;
  //std::cout << "Write Variable" << std::endl;
  fout << "\tsubgraph Variable {"<<std::endl;
  fout << "\t\trankdir=LR;"<< std::endl;
  fout << "\t\tVar [shape=none, label=<" <<std::endl;
  fout << "\t\t<TABLE>"<<std::endl; 
  for ( uint32_t i = 0; i < varCount ; i++){
    fout <<"\t\t\t<TR>" << std::endl;
    fout << "\t\t\t\t<TD>" << "Var[" << i << "]= "<<var[i] <<"  </TD> " <<std::endl;
    fout <<"\t\t\t</TR>" << std::endl;
  }
  fout << "\t\t</TABLE> >];"<<std::endl; 
  fout << "\t\t}"<<std::endl;

 
  fout << "\t}"<<std::endl; 


  fout.close();
}

std::string TP::action_convert( uint32_t opcode, uint32_t src1, uint32_t src2, uint32_t dst, bool log){
  std::string code; 
  switch ( opcode) {
    case 1: // ADD 
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] + S[" +std::to_string(src2) +"]";
      break;
    case 2: // ADD I
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] + " +std::to_string(src2);
      break;
    case 3: //  SUB
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] - S[" +std::to_string(src2) +"]";
      break;
    case 4: // SUBI
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] - " +std::to_string(src2);
      break;
    case 5: //  MUL
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] x S[" +std::to_string(src2) +"]";
      break;
    case 6: // MULI:
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] x " +std::to_string(src2);
      break;
    case 7: // DIV
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] / S[" +std::to_string(src2) +"]";
      break;
    case 8: //DIVI
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] / " +std::to_string(src2);
      break;
    case 9:
      code = "NO LONGER SUPPORT SET";
      break;
    case 10:
      code = "NO LONGER SUPPORT POP";
      break;
    case 11:  // LSHIFT
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#60;&#60; S[ " +std::to_string(src2) + "]";
      break;
    case 12:  // LSHIFTI
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#60;&#60;  " +std::to_string(src2);
      break;
    case 13:  // RSHIFT
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#62;&#62; S[" +std::to_string(src2) + "]";
      break;
    case 14:  // RSHIFTI
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#62;&#62; " +std::to_string(src2);
      break;
    case 15:  //  OR
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#124; S[" +std::to_string(src2) +"]";
      break;
    case 16:  //  ORI
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#124; " +std::to_string(src2);
      break;
    case 17:  //  AND
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#38;  S[" +std::to_string(src2) +"]";
      break;
    case 18:  //  ANDI
      code = "S[" + std::to_string(dst) +"] = S[" + std::to_string(src1) + "] &#38;  " +std::to_string(src2);
      break;
    case 0:
      code = "&Epsilon;";
      if (log) code = "_";
      break;
  }  
  return code;
}


std::string TP::transition_convert ( uint32_t alphabet, bool log) {
  std::string code = "WRONG";
  if ( alphabet < ALPHABETSIZE)  code =   std::to_string(alphabet);
  else if ( (alphabet >= ALPHABETSIZE)  && ( alphabet < EPSILON_MATCH) ){ 
    code =   std::to_string (uint32_t ( alphabet - ALPHABETSIZE)  );
    code = "!" + code;
  }
  else if (   alphabet  == EPSILON_MATCH) {
    code = "&epsilon;";
    if (log) code = "_";
  }
  else if ( ( alphabet  >= VARSTART ) && (alphabet  < (VARSTART + MAXVAR ) ) ) {
    code = "S["+ std::to_string( alphabet - uint32_t (VARSTART)) + "]";
  }
  else if ( ( alphabet  >= INPUTSTART)  && (alphabet  < (INPUTSTART + MAXVAR) )  ) {
    code = "I[" +std::to_string(alphabet-uint32_t (INPUTSTART)) + "]"; 
  }
  else if (   alphabet  == ANY_MATCH) {
    code = "*"; 
  }
  else if ( ( alphabet  >= OUTPUTSTART) && (alphabet  < (OUTPUTSTART + MAXVAR) )  ){
    code = "O[" +std::to_string(alphabet-uint32_t( OUTPUTSTART)) +"]"; 
  }
  else if ( ( alphabet  >=  (VARSTART + ALPHABETSIZE) )  && ( alphabet < ( VARSTART + ALPHABETSIZE + MAXVAR)) ) {
    code = "!S["+ std::to_string( alphabet -uint32_t( VARSTART) - uint32_t(ALPHABETSIZE)) + "]";
  }
  else if  ( (alphabet  >= (INPUTSTART + ALPHABETSIZE) ) && (alphabet < (INPUTSTART + MAXVAR + ALPHABETSIZE) )  ) {
    code = "!I[" +std::to_string(alphabet- uint32_t(INPUTSTART) -uint32_t(ALPHABETSIZE)) + "]"; 
  }
  else if (   alphabet  == ANY_PUSH) {
    code = "Push"; 
  }
  return code;

}


void TP::printTransitionTable(){
  for ( uint32_t i =0; i < transitionCount; i++){
    std::cout <<"T"<< transitionList[i].id <<": ";
    std::cout << transition_convert( transitionList[i].inputID, 1) << "==";
    std::cout << transition_convert( transitionList[i].inputSymbol,1) << ", ";      
    std::cout << transition_convert( transitionList[i].IvarID,1) << "==";
    std::cout << transition_convert( transitionList[i].inputVar,1) << ", ";
    std::cout << transitionList[i].currentState <<" | ";
    std::cout << transition_convert( transitionList[i].outputID,1) << "=";
    std::cout << transition_convert( transitionList[i].outputSymbol,1) << ", ";     
    std::cout << transition_convert( transitionList[i].OvarID,1) << "=";
    std::cout << transition_convert( transitionList[i].outputVar,1) << ", ";
    std::cout << transitionList[i].nextState <<std::endl;
  }
}

void TP::printStateTable(){ 
  for ( uint32_t  i = 0; i < stateCount; i++){  
    std::cout <<"State " << stateList[i].id <<": " << "Base T: " << stateList[i].baseID;
    std::cout << " Outgoing T: " << stateList[i].numberofTransition <<std::endl;
    std::cout << action_convert( stateList[i].opt, stateList[i].src1, stateList[i].src2, stateList[i].dst, 1)<<std::endl;
  }                                                                              
}

void TP::printMemInfo(){
  std::cout << "============================="<< std::endl;
  std::cout <<" MEMORY REQUIREMENT " << std::endl;
  std::cout <<" State Number: " << stateCount <<std::endl;
  std::cout <<" State Size: " << stateCount* sizeof(NPDT) << " B"<< std::endl;
  std::cout <<" Transition Number: " << transitionCount <<std::endl;
  std::cout <<" Transition Size: " << transitionCount* sizeof(Transition) << " B"<< std::endl;
  std::cout <<" Variable Number: " << varCount <<std::endl;
  std::cout <<" Variable Size: " << varCount* sizeof(uint32_t ) << " B"<< std::endl;

  std::cout << "============================="<< std::endl;
}
