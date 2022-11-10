decoding_state = open("bp_decode_state.txt", "w")
decoding_transition = open("bp_decode_transition.txt", "w")
decoding_config = open("bp_decode_config.txt", "w")

#output length 
output_length   = 8
#compress length
compress_length = 2

number_per_output = output_length  // compress_length 

print( "===========================\n")
print( "Write State File\n")
print( "===========================\n")
print( "Write Transition File\n")
stateID = 0
transID = 0
aState  = 0

decoding_state.write(str(stateID) + ",  EPSILON, 0 ,0,0,1,0\n")
stateID += 1  
decoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  515-0, " + str(stateID)  + "\n")
transID += 1 


decoding_state.write(str(stateID) + ",  EPSILON, 0 ,0,0,1,0\n")
stateID += 1  
decoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  516-0, " + str(stateID)  + "\n")
transID += 1 
 
anchorState = stateID
decoding_state.write(str(stateID) + ",  ADDI, 3 , " +   str( int(2**(output_length-1) + 2**(output_length-2))) + ",1,1,0\n")
stateID += 1 
aState +=1 
decoding_transition.write(str(transID)+": 577-641,  512-512,  " + str(stateID-1) + " | 512-512,  513-577, " + str(stateID)  + "\n")
transID += 1  
decoding_state.write(str(stateID) + ",  AND, 1,0,2,0,0\n")
stateID +=  1
aState +=1 
decoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  512-512, " + str(stateID)  + "\n")
transID += 1  
decoding_state.write(str(stateID) + ",  RSHIFTI, 2," + str(output_length-2)  + ",2,0,0\n")
stateID +=  1
aState +=1 



for order in range(1,(number_per_output ) ):
  decoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 642-515,  512-512, " + str(stateID)  + "\n")
  transID += 1  
  decoding_state.write(str(stateID) + ",  RSHIFTI, 1,2,1,0,0\n")
  stateID +=  1
  aState +=1 
  decoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  512-512, " + str(stateID)  + "\n")
  transID += 1  
  decoding_state.write(str(stateID) + ",  AND, 1,0,2,0,0\n")
  stateID +=  1
  aState +=1 
  decoding_transition.write(str(transID)+": 512-512,  512-512,  " + str(stateID-1) + " | 512-512,  512-512, " + str(stateID)  + "\n")
  transID += 1  
  decoding_state.write(str(stateID) + ",  RSHIFTI, 2," + str(output_length - 2 *(order+1 ))  + ",2,0,0\n")
  stateID +=  1
  aState +=1 


decoding_transition.write(str(transID)+": 512-512,  514-641,  " + str(stateID-1) + " | 642-515,  512-512,"+str(stateID) +" \n")
transID +=  1
decoding_state.write(str(stateID) + ",  EPSILON, 0 ,0,0,1,0\n")
stateID += 1  
decoding_transition.write(str(transID)+": 512-512,  513-641,  " + str(stateID-1) + " | 512-512,  512-512, " + str(anchorState)  + "\n")
transID += 1 

decoding_state.close()
decoding_transition.close()

stack_number    = 4
input_number    = 1
output_number   = 1

print( "===========================\n")
print( "Write Config File\n")
decoding_config.write("Number of State: " + str(stateID) + "\n")
decoding_config.write("Number of Transition: " + str(transID)+ "\n")
decoding_config.write("Number of Stack: " + str(stack_number)+"\n")
decoding_config.write("Number of Input Stream: " + str(input_number)+"\n")
decoding_config.write("Number of Output Stream: " + str(output_number)+"\n")
decoding_config.write("Number of Arithmetic State: " + str(aState)+"\n")
decoding_config.close()


