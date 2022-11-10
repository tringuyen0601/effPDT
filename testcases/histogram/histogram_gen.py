import sys
sys.path.append('../variable/')
import variable as va
hist_state       = open ( "hist_state.txt", "w")
hist_transition  = open ( "hist_transition.txt", "w")
hist_config      = open ( "hist_config.txt", "w")

#Stack[0] = input
#Stack[1] = counter
#Stack[2] = upper_bound
#Stack[3] = lower_bound
upper_bound = 100 
lower_bound = 0
print( "===========================\n")
print( "Write State File\n")
stateID = 0
transID = 0

### SETING UP UPPER AND LOWER BOUND:
hist_state.write(str(stateID)  + ", ADDI, 2,"+str(upper_bound) +",2,1,0\n")
stateID  += 1

hist_transition.write( str(transID) + "  : 512-0-512 , 512-0-512," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(stateID)  + "\n")
transID +=  1
hist_state.write(str(stateID)  + ", ADDI, 3,"+str(lower_bound) +",3,1,0\n")
stateID  += 1

hist_transition.write( str(transID) + "  : 512-0-512 , 512-0-512," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(stateID)  + "\n")
transID +=  1




### Comparing
anchorState = stateID
hist_state.write(str(stateID)  + ", EPSILON, 0,0,0,1,0\n")
stateID  += 1
hist_transition.write( str(transID) + "  : " + va.Input[0] + "-0-"+ va.passthrough + ", 512-0-512," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, " + va.Stack[0] +"-" +va.Input[0] +" , " + str(stateID)  + "\n")
transID +=  1

##### check upper
hist_state.write(str(stateID)  + ", EPSILON, 0,0,0,1,0\n")
stateID  += 1

hist_transition.write( str(transID) + "  : 512-0-512,"+ va.Stack[0] +"-"+va.LessThan +"-"+va.Stack[2] +"," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(stateID)  + "\n")
transID +=  1
hist_transition.write( str(transID) + "  : 512-0-512,"+ va.Stack[0] +"-"+va.Equal+"-"+va.Stack[2] +"," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(anchorState)  + "\n")
transID +=  1
hist_transition.write( str(transID) + "  : 512-0-512,"+ va.Stack[0] +"-"+va.GreaterThan +"-"+va.Stack[2] +"," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(anchorState)  + "\n")
transID +=  1

##### check lower
hist_state.write(str(stateID)  + ", EPSILON, 0,0,0,1,0\n")
stateID  += 1

hist_transition.write( str(transID) + "  : 512-0-512,"+ va.Stack[0] +"-"+va.LessThan +"-"+va.Stack[3] +"," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(anchorState)  + "\n")
transID +=  1
hist_transition.write( str(transID) + "  : 512-0-512,"+ va.Stack[0] +"-"+va.Equal+"-"+va.Stack[3] +"," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(stateID)  + "\n")
transID +=  1
hist_transition.write( str(transID) + "  : 512-0-512,"+ va.Stack[0] +"-"+va.GreaterThan +"-"+va.Stack[3] +"," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(stateID)  + "\n")
transID +=  1

#### increment
hist_state.write(str(stateID)  + ", ADDI, 1,1,1,1,0\n")
stateID  += 1
hist_transition.write( str(transID) + "  : 512-0-512 , 512-0-512," +  str(stateID-1) + "  | ")
hist_transition.write("512-512, 512-512 , " + str(anchorState)  + "\n")
transID +=  1

hist_state.close()
hist_transition.close()

stack_number    = 4
input_number    = 1
output_number   = 1

print( "===========================\n")
print( "Write Config File\n")
hist_config.write("Number of State: " + str(stateID) + "\n")
hist_config.write("Number of Transition: " + str(transID)+ "\n")
hist_config.write("Number of Stack: " + str(stack_number)+"\n")
hist_config.write("Number of Input Stream: " + str( input_number) +"\n")
hist_config.write("Number of Output Stream: " + str( output_number) +"\n")
hist_config.close()


