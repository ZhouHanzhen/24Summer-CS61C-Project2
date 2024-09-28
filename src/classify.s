.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0 5
    bne a0 t0 exception2
    
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)
    sw s8 36(sp)
    sw s9 40(sp)
    sw s10 44(sp)
    sw s11 48(sp)


    mv s0 a0                # s0 = a0 is argc
    mv s1 a1                # s1 = a1 is argv
    mv s2 a2                # s2 = a2 is silent mode


    # 1. Read three matrices m0, m1, and input from files.

    # Read pretrained m0
    # allocate space for the pointer arguments
    li a0 8 
    jal malloc

    li t0 0 
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error
    mv s3 a0                # s3 = a0, keep the pointer to the space allocated for later free

    mv a1 s3                # a1 = s3 is the pointer to the number of rows of m0
    addi a2 s3 4            # a2 = s3 + 4 is the pointer to the number of columns of m0              
    lw a0 4(s1)             # a0 = s1 + 4 is the pointer to the filepath string of m0
    
    jal read_matrix
    mv s4 a0                # s4 = a0 is the pointer to the matrix m0 in memory 



    # Read pretrained m1
    # allocate space for the pointer arguments
    li a0 8 
    jal malloc

    li t0 0 
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error
    mv s5 a0                # s5 = a0, keep the pointer to the space allocated for later free

    mv a1 s5                # a1 = s5 is the pointer to the number of rows of m1
    addi a2 s5 4            # a2 = s5 + 4 is the pointer to the number of columns of m1              
    lw a0 8(s1)             # a0 = s1 + 8 is the pointer to the filepath string of m1
    
    jal read_matrix
    mv s6 a0                # s6 = a0 is the pointer to the matrix m1 in memory



    # Read input matrix
    # allocate space for the pointer arguments
    li a0 8 
    jal malloc

    li t0 0 
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error
    mv s7 a0                # s7 = a0, keep the pointer to the space allocated for later free

    mv a1 s7                # a1 = s7 is the pointer to the number of rows of input matrix
    addi a2 s7 4            # a2 = s7 + 4 is the pointer to the number of columns of input matrix            
    lw a0 12(s1)            # a0 = s1 + 12 is the pointer to the filepath string of input matrix
    
    jal read_matrix
    mv s8 a0                # s8 = a0 is the pointer to the input matrix in memory




    # 2. Compute h = matmul(m0, input)

    # malloc space to fit h
    lw t0 0(s3)             # t0 is the number of rows of m0
    lw t1 4(s7)             # t1 is the number of columns of input matrix
    mul t2 t0 t1            # t2 = t0 * t1 is the number of integers in h 
    mv s9 t2                # s9 = t2 is the number of integers in h
    slli t2 t2 2            # t2 = t2 * 4 is the number of bytes for h

    mv a0 t2                # a0 is the size of the memory that we want to allocate (in bytes)
    jal malloc 

    li t0 0
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error
    mv s10 a0               # s10 is the pointer to h in memory

    # Compute h = matmul(m0, input) 
    mv a0 s4                # a0 is A pointer to the start of the first matrix m0
    lw a1 0(s3)             # a1 is the number of rows (height) of the first matrix m0
    lw a2 4(s3)             # a2 is the number of columns (width) of the first matrix m0
    mv a3 s8                # a3 is the pointer to the start of the second matrix input
    lw a4 0(s7)             # a4 is the number of rows (height) of the second matrix input
    lw a5 4(s7)             # a5 is the number of columns (width) of the second matrix input
    mv a6 s10               # a6 is the pointer to the start of an integer array where the result h should be stored
    jal matmul  





    # 3. Compute h = relu(h)
    mv a0 s10               # a0 = s10 is the pointer to the start of the integer array h
    mv a1 s9                # a1 = s9 is the number of integers in the array h
    jal relu





    # 4.
    # malloc space to fit o
    lw t0 0(s5)             # t0 is the number of rows of m1
    lw t1 4(s7)             # t1 is the number of columns of matrix h
    mul t2 t0 t1            # t2 = t0 * t1 is the number of integers in o 
    slli t2 t2 2            # t2 = t2 * 4 is the number of bytes for o

    mv a0 t2                # a0 is the size of the memory that we want to allocate (in bytes)
    jal malloc 

    li t0 0
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error
    mv s11 a0               # s11 is the pointer to o in memory

    # Compute o = matmul(m1, h)
    mv a0 s6                # a0 is A pointer to the start of the first matrix m1
    lw a1 0(s5)             # a1 is the number of rows (height) of the first matrix m1
    lw a2 4(s5)             # a2 is the number of columns (width) of the first matrix m1
    mv a3 s10               # a3 is the pointer to the start of the second matrix h
    lw a4 0(s3)             # a4 is the number of rows (height) of the second matrix h
    lw a5 4(s7)             # a5 is the number of columns (width) of the second matrix h
    mv a6 s11               # a6 is the pointer to the start of an integer array where the result o should be stored
    jal matmul

    # Write output matrix o
    lw a0 16(s1)            # a0 = s1 + 16 is the pointer to the filepath string of output matrix
    mv a1 s11               # a1 = s11 is the pointer to the matrix o in memory
    lw a2 0(s5)             # a3 is the number of rows in the matrix
    lw a3 4(s7)             # a4 is the number of columns in the matrix
    jal write_matrix





    # 5. Compute and return argmax(o)
    lw t0 0(s5)
    lw t1 4(s7)
    mul a1 t0 t1
    mv a0 s11
    jal argmax

    mv s9 a0                # s9 = a0 the index of the largest element


    # If enabled, print argmax(o) and newline
    li t0 0
    bne s2 t0 free_data     # if s2 != 0, no print

    mv a0 s9
    jal print_int           # if enabled, print argmax(o) and newline

    li a0 '\n'
    jal print_char 



    # 6. Free any data you allocated with malloc  
free_data:
    mv a0 s3
    jal free

    mv a0 s5 
    jal free

    mv a0 s7
    jal free

    mv a0 s10 
    jal free

    mv a0 s11
    jal free





    # 7. return value, argmax(o)
    mv a0 s9

    
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    lw s8 36(sp)
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)
    addi sp sp 52

    jr ra

exception1:             # malloc returns an error
    li a0 26
    j exit

exception2:             # incorrect number of command line arguments
    li a0 31
    j exit
