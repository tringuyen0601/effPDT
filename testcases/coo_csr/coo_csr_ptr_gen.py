import sys
sys.path.append('../variable/')
import variable as va
coo_csr_state       = open ( "coo_csr_ptr_state.txt", "w")
coo_csr_transition  = open ( "coo_csr_ptr_transition.txt", "w")
coo_csr_config      = open ( "coo_csr_ptr_config.txt", "w")

#Stack [0] = 513  saving max column to write final pointer
#Stack [1] = 514  i counter: pointer to data array
#Stack [2] = 515  j counter: keep track of current row
#Stack [3] = 516


print( "===========================\n")
print( "Write State File\n")
stateID = 0
transID = 0

### SETING UP: 
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,1,0\n")
stateID  += 1
## read max Row
# set up stack[1] = 0 , i-iterator
coo_csr_transition.write( str(transID) + "  : " + va.Input[0] + "-"+ va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write(va.Output[0]+  "-" + va.Input[0]+", " + va.Stack[1] +"-0  , " + str(stateID)  + "\n")
transID +=  1
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
#  stack[0] = max column
coo_csr_transition.write( str(transID) + "  : " + va.Input[0] + "-"+ va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write(va.Output[0]+  "-" + va.Input[0]+", " + va.Stack[0] +"-" +va.Input[0] + ", " + str(stateID)  + "\n")
transID +=  1

coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
#write stack[3] = number of non 0 element
coo_csr_transition.write( str(transID) + "  : " + va.Input[0] + "-"+ va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write(va.Output[0]+  "-" + va.Input[0]+", " + va.Stack[3] +"-" + va.Input[0] +", " + str(stateID)  + "\n")
transID +=  1

# set up stack[2] = 0, j-iterator
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
coo_csr_transition.write( str(transID) + "  : " + va.Input[0] + "-"+ va.passthrough + ", 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write(va.Output[1]+ "-"+ va.Stack[1] +", " + va.Stack[2] +"-0  , " + str(stateID)  + "\n")
transID +=  1

## Execution
anchorState = stateID
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
#Read from input, compare it with j
# save current input, increment input counter
coo_csr_transition.write( str(transID) + "  : " + va.Input[1]+ "-"+ va.passthrough +", " + va.Stack[2] + "-" +va.Input[1]+"," +  str(anchorState) + "  | ")
coo_csr_transition.write("512-512, 512-512, "+ str(stateID)  + "\n")
transID +=  1
# increament j 
coo_csr_state.write(str(stateID)  + ", ADDI, 1,1,1,0,0\n")
stateID  += 1
# j == input, increment i, fetch next
# loop back to anchor
decisionState = stateID-1
coo_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write( "512-512, 512-512  , " + str(stateID)  + "\n")
transID +=  1
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# i = max coloumn, reach end of row,  
coo_csr_transition.write( str(transID) + "  : 512-512, " + va.Stack[1]+"-" + va.Stack[3] +"," +  str(stateID-1) + "  | ")
coo_csr_transition.write( va.Output[1] +"-" +va.Stack[1] +", 512-512," + str(stateID)  + "\n")
transID +=  1
# i < max column, keep reading 
coo_csr_transition.write( str(transID) + "  : 512-512, " + va.Stack[1]+"-" + va.NotStack[3]+ "," +  str(stateID-1) + "  | ")
coo_csr_transition.write( "512-512 , 512-512," + str(anchorState)  + "\n")
transID +=  1

exitState = stateID
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,1\n")
stateID  += 1
#reset variable
coo_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write( "512-512, " + va.Stack[1]+"-0," + str(stateID)  + "\n")
transID +=  1
coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,1\n")
stateID  += 1
coo_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write( "512-512, " + va.Stack[2]+"-0," + str(anchorState)  + "\n")
transID +=  1


# j != input, write i, increment j
coo_csr_transition.write( str(transID) + "  : "+ va.Input[1]+"-"+va.passthrough + ", " + va.Stack[2]+"-" + va.NotInput[1]+"," +  str(anchorState) + "  | ")
coo_csr_transition.write( va.Output[1]+"-" + va.Stack[1]+" , 512-512," + str(stateID)  + "\n")
transID +=  1
# increment j
coo_csr_state.write(str(stateID)  + ", ADDI, 2,1,2,0,0\n")
stateID  += 1
coo_csr_transition.write( str(transID) + "  : 512-512, " + va.Stack[2]+"-" + va.Input[1] +"," +  str(stateID-1) + "  | ")
coo_csr_transition.write( "512-512 , 512-512," + str(stateID)  + "\n")
transID +=  1
coo_csr_transition.write( str(transID) + "  : 512-512, " + va.Stack[2]+ "-" + va.NotInput[1] + "," +  str(stateID-1) + "  | ")
coo_csr_transition.write( va.Output[1]+"-" + va.Stack[1]+", 512-512," + str(stateID-1)  + "\n")
transID +=  1
# increment i
coo_csr_state.write(str(stateID)  + ", ADDI, 1,1,1,0,0\n")
stateID  += 1
coo_csr_transition.write( str(transID) + "  : 512-512, 512-512," +  str(stateID-1) + "  | ")
coo_csr_transition.write( "512-512, 512-512  , " + str(anchorState)  + "\n")
transID +=  1

#coo_csr_transition.write( str(transID) + "  : "+ va.Input[1] + "-"+va.passthrough +", 512-512," +  str(exitState) + "  | ")
#coo_csr_transition.write( "512-512, 512-512," + str(stateID)  + "\n")
#transID +=  1
#coo_csr_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,1\n")
#stateID  += 1

print( 'Total State = ' + str(stateID) )
print(  'Total Transition = ' + str(transID) )
coo_csr_transition.close()
coo_csr_state.close()


stack_number  = 4
input_number  = 2
output_number = 2
print( "===========================\n")
print( "Write Config File\n")
coo_csr_config.write("Number of State: " + str(stateID) + "\n")
coo_csr_config.write("Number of Transition: " + str(transID)+ "\n")
coo_csr_config.write("Number of Stack: " + str(stack_number)+"\n")
coo_csr_config.write("Number of Input Stream: " + str(input_number)+"\n")
coo_csr_config.write("Number of Output Stream: " + str(output_number)+"\n")
coo_csr_config.close()


#Stack [0] = 513  saving max column to write final pointer
#Stack [1] = 514  i counter: pointer to data array
#Stack [2] = 515  j counter: keep track of current row
#Stack [3] = 516
