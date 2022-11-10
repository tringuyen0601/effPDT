encoding_state = open("bp_encode_state.txt", "w")
encoding_transition = open("bp_encode_transition.txt", "w")
encoding_config = open("bp_encode_config.txt", "w")

#output length 
output_length   = 32 
#compress length
compress_length = 8
formater =int ( '0x000000ff', 0) 
number_per_output = output_length  // compress_length 

print( "===========================\n")
print( "Write State File\n")
print( "===========================\n")
print( "Write Transition File\n")
stateID = 0
transID = 0
aState = 0
# state 1 : pop variable
encoding_state.write(str(stateID) +",  EPSILON,    0,0,0,0,0\n")
stateID +=  1
encoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  514-0, " + str(stateID)  + "\n")
transID += 1  

encoding_state.write(str(stateID) +",  EPSILON,    0,0,0,0,0\n")
stateID +=  1
encoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  513-0, " + str(stateID)  + "\n")
transID += 1  

encoding_state.write(str(stateID) +",  EPSILON,    0,0,0,0,0\n")
stateID +=  1
encoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  515-"+str(formater) +", " + str(stateID)  + "\n")
transID += 1  
anchorState = stateID
encoding_state.write(str(stateID) +",  EPSILON,    0,0,0,0,0\n")
stateID +=  1
for order in range(1,(number_per_output +1) ):
  encoding_transition.write(str(transID)+": 577-641,  513-641  " + str(stateID-1) + " | 512-512,  513-577, " + str(stateID)  + "\n")
  transID += 1  
  encoding_state.write(str(stateID) + ",  AND, 0, 2 ,0,0,0\n")
  encoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID) + " | 512-512,  512-512, " + str(stateID+1)  + "\n")
  aState +=1
  stateID +=  1
  transID += 1  

  encoding_state.write(str(stateID) + ",  LSHIFTI, 0," + str(compress_length *(number_per_output - order))  +",0,0,0\n")
  encoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID) + " | 512-512,  512-512, " + str(stateID+1)  + "\n")
  stateID +=  1
  transID += 1  
  aState +=1
  encoding_state.write(str(stateID) + ",  OR, 1,0,1,0,0\n")
  stateID +=  1
  aState +=1


encoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 642-514,  512-512, " +str(stateID) +"\n")
transID += 1  
encoding_state.write(str(stateID) +",  EPSILON,    0,0,0,0,0\n")
stateID +=  1
encoding_transition.write(str(transID)+": 512-512,  514-641,  " + str(stateID-1) + " | 512-512,  514-0,"  + str(anchorState)  +" \n")
transID += 1  
encoding_state.close()
encoding_transition.close()


stack_number    = 3
input_number    = 1
output_number   = 1

print( "===========================\n")
print( "Write Config File\n")
encoding_config.write("Number of State: " + str(stateID) + "\n")
encoding_config.write("Number of Transition: " + str(transID)+ "\n")
encoding_config.write("Number of Stack: " + str(stack_number)+"\n")
encoding_config.write("Number of Input Stream: " + str( input_number) +"\n")
encoding_config.write("Number of Output Stream: " + str( output_number) +"\n")
encoding_config.write("Arithmetic State: " + str( aState) +"\n")
encoding_config.close()


