CUDAROOT=/usr/local/cuda-11.5
CUDA_LIB_DIR= -L$(CUDAROOT)/lib64
CUDA_INC_DIR= -I$(CUDAROOT)/include
CC = g++
CUDA= nvcc
PTHREAD = -lpthread
OPT = -g
WARN = -Wall
VERSION =  -std=c++11 
CFLAGS = $(OPT) $(VERSION)
CUDAINFO = --ptxas-options=-v
CUDAFLAG = -arch=sm_61

FST_CPU   = helper.o  argument.o  processor.o processor_helper.o
FST_GPU = processor_gpu.o 
FST_ENGINE = gpu_fst_engine_helper.o gpu_fst_engine_execute.o gpu_fst_engine_execute_shared.o  gpu_fst_engine_execute_constant.o gpu_fst_engine_execute_thread.o gpu_fst_engine_io.o gpu_fst_engine_partition.o
CORE_OBJ =   $(FST_CPU) $(FST_CPU) $(FST_ENGINE)
GPULOAD = main_gpu_load_test.o
#################################

# default rule
all:  object	generate

object:
	$(CC) $(CFLAGS) -c *.cc 
	$(CUDA) $(CUDAFLAG) $(CUDA_LIB_DIR) $(CUDA_INC_DIR)  -lcuda -lcudart -c *.cu  
generate:
#	$(CUDA) -o bin/gpu_load_test  $(CUDA_LIB_DIR) $(CUDA_INC_DIR) -lcudart $(CFLAGS) $(CORE_OBJ) $(GPULOAD)  
	$(CUDA) -o bin/gpu_load_test  $(CUDA_LIB_DIR) $(CUDA_INC_DIR) -lcuda -lcudart $(CFLAGS) $(FST_CPU) $(FST_GPU) $(FST_ENGINE)  $(GPULOAD)  
clean:
	rm -f *.o
	rm -f bin/*
