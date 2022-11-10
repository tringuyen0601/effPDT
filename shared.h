#define THREAD_PER_BLOCK 128 
// BP DECODE 0
// BP ENCODE 1
// GV DECODE 2
// GV ENCODE 3
// RL DECODE 4
// RL ENCODE 5
// COO-CSR   6
// DENSE-CSR 7
// CSV_PARSING ENCODED DET 8
#define MODE  8


// BP DECODE
#if MODE == 0
  #define STATE_COUNT 15
  #define TRANSITION_COUNT 15 
  #define VARIABLE 4
  #define INPUT 1
  #define OUTPUT 1

// BP ENCODE
#elif MODE == 1  
  #define STATE_COUNT 17
  #define TRANSITION_COUNT 17 
  #define VARIABLE 3
  #define INPUT 1
  #define OUTPUT 1

// GV DECODE
#elif MODE == 2  
  #define STATE_COUNT 14
  #define TRANSITION_COUNT 15 
  #define VARIABLE 6
  #define INPUT 1
  #define OUTPUT 1

// GV ENCODE
#elif MODE == 3  
  #define STATE_COUNT 6
  #define TRANSITION_COUNT 7 
  #define VARIABLE 2
  #define INPUT 1
  #define OUTPUT 1

// RL DECODE
#elif MODE == 4  
  #define STATE_COUNT 3
  #define TRANSITION_COUNT 4 
  #define VARIABLE 2
  #define INPUT 1
  #define OUTPUT 1

// RL ENCODE
#elif MODE == 5  
  #define STATE_COUNT 3
  #define TRANSITION_COUNT 4 
  #define VARIABLE 2
  #define INPUT 1
  #define OUTPUT 1

// COO-CSR
#elif MODE == 6  
  #define STATE_COUNT 11
  #define TRANSITION_COUNT 14 
  #define VARIABLE 4
  #define INPUT 2
  #define OUTPUT 2

// DENSE-CSR
#elif MODE == 7  
  #define STATE_COUNT 15
  #define TRANSITION_COUNT 17 
  #define VARIABLE 6
  #define INPUT 2
  #define OUTPUT 2

// CSV_PARSING ENCODED DET
#elif MODE == 8  
  #define STATE_COUNT 8
  #define TRANSITION_COUNT 15 
  #define VARIABLE 2
  #define INPUT 1
  #define OUTPUT 1

#else
  #define STATE_COUNT 10
  #define TRANSITION_COUNT 10 
  #define VARIABLE 4
  #define INPUT 1
  #define OUTPUT 1
#endif
