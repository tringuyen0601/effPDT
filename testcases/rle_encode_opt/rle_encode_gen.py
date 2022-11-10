encoding_state = open("rle_encode_state.txt", "w")
encoding_transition = open("rle_encode_transition.txt", "w")
encoding_config = open("rle_encode_config.txt", "w")

state_number  = 3
trans_number  = 4
stack_number  = 2
input_number  = 1
output_number = 1
print( "===========================\n")
print( "Write Config File\n")
encoding_config.write("Number of State: " + str(state_number) + "\n")
encoding_config.write("Number of Transition: " + str(trans_number)+ "\n")
encoding_config.write("Number of Stack: " + str(stack_number)+"\n")
encoding_config.write("Number of Input Stream: " + str(input_number)+"\n")
encoding_config.write("Number of Output Stream: " + str(output_number)+"\n")
encoding_config.close()


print( "===========================\n")
print( "Write State File\n")
encoding_state.write("0,  ANDI,  1,0,1,0,1\n")
encoding_state.write("1,  ADDI, 1,1,1,0,0\n")
encoding_state.write("2,  ANDI,  1,0,1,0,1\n")
encoding_state.close()



# 578 = 513 + 64 +0 = Input
# 579 = 513 + 64 +1 = Output
# Stack 0 = 513 ; stack 1 = 514 
print( "===========================\n")
print( "Write Transition File\n")
encoding_transition.write("0: 577-641,  512-512,  0 | 642-577,  513-577,  1\n" )
#self transition
encoding_transition.write("1: 577-641,  513-577,  1 | 512-512,  512-512,  1\n")
# Exit transition
encoding_transition.write("2: 577-641,  513-833,  1 | 642-514,  513-577,  2\n")
# loop back transition
encoding_transition.write("3: 512-512,  512-512,  2 | 642-513,  512-512,  1\n")
encoding_transition.close()


