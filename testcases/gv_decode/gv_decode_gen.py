import sys
sys.path.append('../variable/')
import variable as va

gvd_state       = open ( "gvd_state.txt", "w")
gvd_transition  = open ( "gvd_transition.txt", "w")
gvd_config      = open ( "gvd_config.txt", "w")

#Stack [0] = 513  saved input 
#Stack [1] = 514  next element flag
#Stack [2] = 515  actual content
#Stack [3] = 516  final result
#Stack [4] = 517  bit shift counter for final value
#ouput[0] =  output Stream

#input[0] = Input Stream


print( "===========================\n")
print( "Write State File\n")
stateID = 0
transID = 0

### SETING UP: 
gvd_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# intialize Stack[1] to save result of next read flag
gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ," + va.Stack[1] + "-0, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# intialize Stack[2] to save result of actual data
gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ," + va.Stack[2] + "-0, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# intialize Stack[3] to final result
gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ," + va.Stack[3] + "-0, " + str(stateID)  + "\n")
transID +=  1
gvd_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# intialize Stack[4] to final result left shift counter
gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ," + va.Stack[4] + "-0, " + str(stateID)  + "\n")
transID +=  1
gvd_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

# intialize Stack[5] to number of bit to be shifted t the left + S[5] = S4] * 7
gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ," + va.Stack[5] + "-0, " + str(stateID)  + "\n")
transID +=  1

### execution Start

# read first element
nextElementState = stateID
# zero out final value
gvd_state.write(str(stateID)  + ", ANDI, 3,0,3,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :" + va.Input[0] +"-" + va.passthrough+ ", 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 , "+va.Stack[0]+  "-" + va.Input[0]+", " + str(stateID)  + "\n")
transID +=  1

continueState = stateID
gvd_state.write(str(stateID)  + ", ANDI, 0,127,2,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ,512-512, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", ANDI, 0,128,1,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ,512-512, " + str(stateID)  + "\n")
transID +=  1


gvd_state.write(str(stateID)  + ", MULI, 4,7,5,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ,512-512, " + str(stateID)  + "\n")
transID +=  1

# move read value to the right position in final number
gvd_state.write(str(stateID)  + ", LSHIFT, 2,5,2,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ,512-512, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", OR, 3,2,3,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :512-512, 512-512," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 ,512-512, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", ADDI, 4,1,4,0,0\n")
stateID  += 1


gvd_transition.write( str(transID) + "  :512-512, " + va.Stack[1]+"-0," +  str(stateID-1) + "  | ")
gvd_transition.write( va.Output[0]+"-" +va.Stack[3] + " , 512-512, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", ANDI, 4,0,4,0,0\n")
stateID  += 1
gvd_transition.write( str(transID) + "  :512-512, " + va.Stack[0] +"-" + va.passthrough+"," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 , 512-512, " + str(nextElementState)  + "\n")
transID +=  1



gvd_transition.write( str(transID) + "  :512-512, " + va.Stack[1]+"-256," +  str(stateID-2) + "  | ")
gvd_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")
transID +=  1

gvd_state.write(str(stateID)  + ", EPSILON, 0,0,0,0,0\n")
stateID  += 1

gvd_transition.write( str(transID) + "  :" + va.Input[0] +"-" + va.passthrough+ ", " + va.Stack[0] +"-" + va.passthrough +"," +  str(stateID-1) + "  | ")
gvd_transition.write( "512-512 , "+va.Stack[0]+  "-" + va.Input[0]+", " + str(continueState)  + "\n")
transID +=  1


print ( "State: " + str(stateID) )
print ( "Transition: " + str(transID))


stack_number  = 6
input_number  = 1
output_number = 1
print( "===========================\n")
print( "Write Config File\n")
gvd_config.write("Number of State: " + str(stateID) + "\n")
gvd_config.write("Number of Transition: " + str(transID)+ "\n")
gvd_config.write("Number of Stack: " + str(stack_number)+"\n")
gvd_config.write("Number of Input Stream: " + str(input_number)+"\n")
gvd_config.write("Number of Output Stream: " + str(output_number)+"\n")
gvd_config.close()


