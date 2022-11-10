import sys
sys.path.append('../variable/')
import variable as va

dense_csr_state       = open ( "dense_csr_state.txt", "w")
dense_csr_transition  = open ( "dense_csr_transition.txt", "w")
dense_csr_config      = open ( "dense_csr_config.txt", "w")

#Stack [0] = 513  row counter :j
#Stack [1] = 514  column counter :i
#Stack [2] = 515  column constant
#Stack [3] = 516  saved value
#Stack [4] = 517  number of non-0 value
#Stack [5] = 518  datacounter to output as csr pointer
#ouput[0] =  row
#ouput[1] =  col
#ouput[2] =  data
#ouput[3] =  meta

#input[0] = data
#input[1] = meta

print( "===========================\n")
print( "Write State File\n")
stateID = 0
transID = 0
### SETING UP: set i, j = 0, record number of column
## Set up j-iterator, read max Row
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  :" + va.Input[0] + "-" + va.passthrough +", 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write( va.Output[0] +  "-"+ va.Input[0] + " ," + va.Stack[0] + "-0, " + str(stateID)  + "\n")  
transID +=  1

# Set up i-iterator, read max Column
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  :" + va.Input[0] + "-" + va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write( va.Output[0] +  "-"+ va.Input[0] + " ," + va.Stack[2] + "-" + va.Input[0] +", " + str(stateID)  + "\n")  
transID +=  1

# saved number of non-0 value to stack 4
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  :" + va.Input[0] + "-" + va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write(  va.Output[0]+ "-"+va.Input[0]  + "," + va.Stack[4] + "-"+ va.Input[0]+   ", " + str(stateID)  + "\n")  
transID +=  1

# read 1 more time to close stream 1
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  :" + va.Input[0] + "-" + va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write(  "512-512, " + va.Stack[1] + "-0 , " + str(stateID)  + "\n")  
transID +=  1

dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")  
dense_csr_transition.write(  "512-512 ," + va.Stack[3] + "-0 , " + str(stateID)  + "\n")  
transID +=  1

#initialize data pointer , csr ptr output
beginState= stateID
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")  
dense_csr_transition.write(  va.Output[1]+ "-0 ," + va.Stack[5] + "-0 , " + str(stateID)  + "\n")  
transID +=  1

### Read a value, if it is not 0, output
outputState = stateID
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
# value is not 0, output
dense_csr_transition.write( str(transID) + "  : " + va.Input[1] +"-256, 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write( "512-512, " + va.Stack[3] + "-" + va.Input[1] +", " + str(stateID)  + "\n")  
transID +=  1
# increment data pointer 
dense_csr_state.write(str(stateID)  + ", ADDI, 5,1,5,0,0\n")
stateID  += 1

# write row coordinate
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write(  "512-512, 512-512  , " + str(stateID)  + "\n")  
transID +=  1
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# Reset Stack 3 
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")  
dense_csr_transition.write(  "512-512, 512-512  , " + str(stateID)  + "\n")  
transID +=  1

#value is 0, skip output
dense_csr_transition.write( str(transID) + "  :" +va.Input[1]+"-0, 512-512," +  str(outputState) + "  | ")
dense_csr_transition.write( "512-512, 512-512  , " + str(stateID)  + "\n")  
transID +=  1




### calculate coordinate of next value
calculateState= stateID
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
#increment column counter
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write( "512-512, 512-512  , " + str(stateID)  + "\n")  
transID +=  1
dense_csr_state.write(str(stateID)  + ", ADDI, 1,1,1,0,0,0\n")
stateID  += 1

# i != max column
dense_csr_transition.write( str(transID) + "  : 512-512, "+ va.Stack[1]+"-" + va.NotStack[2]+"," +  str(stateID-1) + "  | ")
dense_csr_transition.write( "512-512, 512-512 , " + str(outputState)  + "\n")  
transID +=  1


# i = max column
dense_csr_transition.write( str(transID) + "  : 512-512, "+ va.Stack[1]+"-" + va.Stack[2]+ "," +  str(stateID-1) + "  | ")
dense_csr_transition.write( "512-512, 512-512 , " + str(stateID)  + "\n")  
transID +=  1
# reset column j-terator, output csr ptr
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  : 512-512,  512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write( va.Output[1] + "-" + va.Stack[5]+", "+ va.Stack[1] + "-0  , " + str(stateID)  + "\n")  
transID +=  1
#increment row counter
dense_csr_state.write(str(stateID)  + ", ADDI, 0,1,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  : 512-512, " + va.Stack[5] +"-" + va.NotStack[4]+ "," +  str(stateID-1) + "  | ")
dense_csr_transition.write("512-512,  512-512, " + str(outputState)  + "\n")  
transID +=  1

dense_csr_transition.write( str(transID) + "  : 512-512, " + va.Stack[5] +"-" + va.Stack[4]+ "," +  str(stateID-1) + "  | ")
dense_csr_transition.write("512-512, " + va.Stack[0] + "-0 , " + str(stateID)  + "\n")  
transID +=  1
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write("512-512, " + va.Stack[1] + "-0 , " + str(stateID)  + "\n")  
transID +=  1
dense_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
dense_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
dense_csr_transition.write("512-512, " + va.Stack[3] + "-0 , " + str(beginState)  + "\n")  
transID +=  1
dense_csr_state.close()
dense_csr_transition.close()

print ( "State: " + str(stateID) )
print ( "Transition: " + str(transID))


stack_number  = 6
input_number  = 2
output_number = 2
print( "===========================\n")
print( "Write Config File\n")
dense_csr_config.write("Number of State: " + str(stateID) + "\n")
dense_csr_config.write("Number of Transition: " + str(transID)+ "\n")
dense_csr_config.write("Number of Stack: " + str(stack_number)+"\n")
dense_csr_config.write("Number of Input Stream: " + str(input_number)+"\n")
dense_csr_config.write("Number of Output Stream: " + str(output_number)+"\n")
dense_csr_config.close()


