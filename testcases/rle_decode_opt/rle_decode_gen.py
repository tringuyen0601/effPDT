decoding_state = open("rle_decode_state.txt", "w")
decoding_transition = open("rle_decode_transition.txt", "w")
decoding_config = open("rle_decode_config.txt", "w")


state_number = 3
trans_number = 4 
stack_number = 2
input_number = 1
output_number = 1


print( "===========================\n")
print( "Write Config File\n")
decoding_config.write("Number of State: " + str(state_number) + "\n")
decoding_config.write("Number of Transition: " + str(trans_number)+ "\n")
decoding_config.write("Number of Stack: " + str(stack_number)+"\n")
decoding_config.write("Number of Input Stream: " + str(input_number)+ "\n")
decoding_config.write("Number of Output Stream: " + str(output_number)+"\n")
decoding_config.close()


print( "===========================\n")
print( "Write State File\n")
decoding_state.write("0, EPSILON, 0,0,0,1,0\n")
decoding_state.write("1, EPSILON, 0,0,0,0,0\n")
decoding_state.write("2, SUBI   , 0,1,0,0,0\n")
decoding_state.close()

decoding_transition.write("0, 577-641,  512-512,  0 | 512-512,  514-577,  1\n") 
decoding_transition.write("1, 577-641,  512-512,  1 | 642-514,  513-577,  2\n") 
decoding_transition.write("2, 512-512,  513-256,  2 | 642-514,  512-512,  2\n") 
decoding_transition.write("3, 512-512,  513-0,  2 | 512-512,  512-512,  0\n") 
decoding_transition.close()

# 577 = 513 + 63 +0 = Input
# 578 = 513 + 63 +1 = Output
# Stack 0 = 513 ; stack 1 = 514 



