import sys
sys.path.append('../variable/')
import variable as va

gve_state       = open ( "gve_state.txt", "w")
gve_transition  = open ( "gve_transition.txt", "w")
gve_config      = open ( "gve_config.txt", "w")

#Stack [0] = 513  saved input 
#Stack [1] = 514  result of rightshift
#Stack [2] = 515  result of or, number to write to output stream
#ouput[0] =  output Stream

#input[0] = Input Stream


print( "===========================\n")
print( "Write State File\n")
stateID = 0
transID = 0

### SETING UP: 
gve_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# intialize Stack[1] to save result of bit shift operation
gve_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gve_transition.write( "512-512 ," + va.Stack[1] + "-0, " + str(stateID)  + "\n")
transID +=  1


### execution Start
executionStartState = stateID
gve_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1
# read an element, store it to Stack[0]
gve_transition.write( str(transID) + "  :" + va.Input[0] + "-" + va.passthrough +", 512-512," +  str(executionStartState) + "  | ")
gve_transition.write( "512-512 ," + va.Stack[0] + "-" + va.Input[0] +", " + str(stateID)  + "\n")
transID +=  1

#compute result tooutput
continueState = stateID
gve_state.write(str(stateID)  + ", ANDI, 0,127,1,0,0\n")
stateID  += 1

gve_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gve_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")
transID +=  1

gve_state.write(str(stateID)  + ", ORI, 1,128,1,0,0\n")
stateID  += 1

gve_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gve_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")
transID +=  1

# leftshift Stack[0] by 7
gve_state.write(str(stateID)  + ", RSHIFTI, 0,7,0,0,0\n")
stateID  += 1
# if result != 0, output 
gve_transition.write( str(transID) + "  : 512-512, "+ va.Stack[0] + "-256," +  str(stateID-1) + "  | ")
gve_transition.write( va.Output[0] + "-"+ va.Stack[1] + " , 512-512 , " + str(continueState)  + "\n")
transID +=  1

# if result == 0,  
gve_transition.write( str(transID) + "  : 512-512, "+ va.Stack[0] + "-0," +  str(stateID-1) + "  | ")
gve_transition.write(  "512-512, 512-512, " + str(stateID)  + "\n")
transID +=  1
# set bit 7 to 0 and output
gve_state.write(str(stateID)  + ", ANDI, 1,127,1,0,0\n")
stateID  += 1

gve_transition.write( str(transID) + "  :512-512, " + va.Stack[0] + "-" + va.passthrough+"," +  str(stateID-1) + "  | ")
gve_transition.write( va.Output[0] + "-"+ va.Stack[1] + " , 512-512, " + str(executionStartState)  + "\n")

transID +=  1

print ( "State: " + str(stateID) )
print ( "Transition: " + str(transID))


stack_number  = 2
input_number  = 1
output_number = 1
print( "===========================\n")
print( "Write Config File\n")
gve_config.write("Number of State: " + str(stateID) + "\n")
gve_config.write("Number of Transition: " + str(transID)+ "\n")
gve_config.write("Number of Stack: " + str(stack_number)+"\n")
gve_config.write("Number of Input Stream: " + str(input_number)+"\n")
gve_config.write("Number of Output Stream: " + str(output_number)+"\n")
gve_config.close()


