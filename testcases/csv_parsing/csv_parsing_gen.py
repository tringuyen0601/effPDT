import sys
sys.path.append('../variable/')
import variable as va

csv_state = open("csv_state.txt", "w")
csv_transition = open("csv_transition.txt", "w")
csv_config = open("csv_config.txt", "w")

state_number  = 0
trans_number  = 0
stack_number  = 2
input_number  = 1
output_number = 1
#Stack[0]: output signal
#Stack[1]: current column

condition = 5
total_col = 15
cond_col = 0
output_col = 5
current_col = 0

print( "===========================\n")
print( "Write State File\n")
stateID = 0
transID = 0

initialState = 0
csv_state.write( str(stateID) + ", EPSILON, 0,0,0,0,0\n")
stateID +=1

#1-yes
# if reach conditional column
csv_transition.write( str(transID) + "  : 512-512, "+ va.Stack[1] +"-" + str(cond_col)+", " +str(initialState)+" | ")
csv_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")
transID +=  1

csv_state.write( str(stateID) + ", EPSILON, 0,0,0,0,0\n")
stateID +=1

#1.1-yes
#if match, set signal to output
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(condition) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512, "+ va.Stack[0]+"-1, " + str(stateID)  + "\n")
transID +=  1
#1.1-no
# not match, pass
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(256+ condition) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(stateID)  + "\n")
transID +=  1


# read 1 column until output column
findOutputState = stateID
csv_state.write ( str(stateID) + ", EPSILON, 0,0,0,0,0\n")
stateID +=1
#1.3-no
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(256+ord(';')) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(stateID-1)  + "\n")
transID +=  1
#1.3-yes
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(ord(';')) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(stateID)  + "\n")
transID +=  1
csv_state.write ( str(stateID) + ", ADDI, 1,1,1,0,0\n")
addState = stateID
stateID +=1

#1.2-yes
#if reach output column
csv_transition.write( str(transID) + "  : 512-512, "+ va.Stack[1] +"-" + str(output_col)+"," +str(addState) +" | ")
csv_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")
transID +=  1
csv_state.write( str(stateID) + ", EPSILON, 0,0,0,0,0\n")
stateID +=1
#if signal is set, output and reset signal
#1.2.1-yes
csv_transition.write( str(transID) + "  : "+va.Input[0] +"-" +va.passthrough +", "+ va.Stack[0] +"-1," +str(stateID-1) +" | ")
csv_transition.write( va.Output[0]+"-" +va.Input[0] +" , " + va.Stack[0]+"-0, " + str(stateID)  + "\n")                                 
transID +=  1
#1.2.1-no
csv_transition.write( str(transID) + "  : "+va.Input[0] +"-" +va.passthrough +", "+ va.Stack[0] +"-257," +str(stateID-1) +" | ")
csv_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")                                 
transID +=  1

#1.2-no
# if have not reach output column
csv_transition.write( str(transID) + "  : 512-512, "+ va.Stack[1] +"-" + str(256+ output_col)+"," +str(addState) +" | ")   
csv_transition.write( "512-512,512-512, " + str(findOutputState)  + "\n")                           
transID +=  1

#read till end of line
#reset colum counter
csv_state.write( str(stateID) + ", ANDI, 1,0,1,0,0\n")
stateID +=1

#1.4-no
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(256+ord('\n')) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(stateID-1)  + "\n")
transID +=  1

#1.4-yes
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(ord('\n')) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(initialState)  + "\n")
transID +=  1


###########################
# not conditional column, read until find coniditonal column
#1-no
csv_transition.write( str(transID) + "  : 512-512, "+ va.Stack[1] +"-" + str(256+cond_col)+", " +str(initialState)+" | ")
csv_transition.write( "512-512 , 512-512, " + str(stateID)  + "\n")
transID +=  1

csv_state.write( str(stateID) + ", EPSILON, 0,0,0,0,0\n")
stateID +=1
#read until reach a column
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(256+ord(';')) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(stateID-1)  + "\n")
transID +=  1

# reach a new col, increment counter and loop  back
csv_transition.write( str(transID) + "  :" + va.Input[0] + "-" + str(ord(';')) +", 512-512," +  str(stateID-1) + "  | ")
csv_transition.write( "512-512,512-512, " + str(stateID)  + "\n")
transID +=  1

csv_state.write( str(stateID) + ", ADDI, 1,1,1,0,0\n")
stateID +=1

csv_transition.write( str(transID) + "  : 512-512, 512-512, " +str(stateID-1)+" | ")
csv_transition.write( "512-512 , 512-512, " + str(initialState)  + "\n")
transID +=  1

print( 'Total State = ' + str(stateID) )
print(  'Total Transition = ' + str(transID) )
csv_transition.close()
csv_state.close()


print( "===========================\n")
print( "Write Config File\n")
csv_config.write("Number of State: " + str(stateID) + "\n")
csv_config.write("Number of Transition: " + str(transID)+ "\n")
csv_config.write("Number of Stack: " + str(stack_number)+"\n")
csv_config.write("Number of Input Stream: " + str(input_number)+"\n")
csv_config.write("Number of Output Stream: " + str(output_number)+"\n")
csv_config.close()


