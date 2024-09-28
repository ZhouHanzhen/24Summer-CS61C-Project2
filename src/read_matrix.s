.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -32 
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)


    mv s0 a0            # s0 is the pointer to filename string
    mv s1 a1            # s1 is the pointer to the number of rows
    mv s2 a2            # s2 is the pointer to the number of columns




    # 1. open file
    mv a0 s0            # a0 is the pointer to the filename string
    li a1 0             # a1 is 0 for read-only
    jal fopen

    addi t0 x0 -1           # t0 = -1 
    beq a0 t0 exception2    # if a0 = -1, fopen returns an error

    mv s3 a0                # s3 = a0 is the file descriptor of the file




    # 2. read the number of rows and colulmns
    # read the number of rows
    mv a0 s3            # a0 = s3 is the file descriptor
    mv a1 s1            # a1 = s1 is the pointer to the row_number buffer where the read bytes will be stored
    li a2 4             # a2 = 4 is the number of bytes to read from the file

    jal fread

    li t0 4                 # t0 = 4
    bne a0 t0 exception4    # if a0 != 4, fread does not read the correct number of bytes

    # read the number of colulmns
    mv a0 s3            # a0 = s3 is the file descriptor
    mv a1 s2            # a1 = s2 is the pointer to the column_number buffer where the read bytes will be stored
    li a2 4             # a2 = 4 is the number of bytes to read from the file

    jal fread

    li t0 4                 # t0 = 4
    bne a0 t0 exception4    # if a0 != 4, fread does not read the correct number of bytes




    # 3. allocate space on the heap to store the matrix
    lw t0 0(s1)             # t0 is number of rows
    lw t1 0(s2)             # t1 is number of columns
    mul s4 t0 t1            # s4 = t0 * t1 is the number of integers in the matrix
    slli t2 s4 2            # t2 = s4 * 4 is the number of bytes in the matrix
    mv a0 t2                # a0 is the size of the memory that we want to allocate (in bytes).
    jal malloc
    
    li t0 0 
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error

    mv s5 a0                # s5 is the pointer to the matrix and later returned value of the read_matrix function
 



    # 4. read the matrix from the file to the memory allocated in the previous step
    mv s6 s5                # s6 = s5 is the loop pointer to the matrix
    li t1 0                 # i = t1 = 0

loop_read:
    # read the integers of the matrix
    mv a0 s3            # a0 = s3 is the file descriptor
    mv a1 s6            # a1 = s6 is the loop pointer to the integer buffer where the read bytes will be stored
    li a2 4             # a2 = 4 is the number of bytes to read from the file

    addi sp sp -4
    sw t1 0(sp)

    jal fread

    lw t1 0(sp)
    addi sp sp 4

    li t0 4                 # t0 = 4
    bne a0 t0 exception4    # if a0 != 4, fread does not read the correct number of bytes

    addi t1 t1 1            # i += 1
    addi s6 s6 4            # s6 += 4 is the loop pointer to the next integer to read
    blt t1 s4 loop_read     # if i < n * m, loop read integer




    # 5. close the file
    mv a0 s3                # a0 = s3 is the file descriptor of the file we want to close
    jal fclose

    li t0 -1                # t0 = -1
    beq a0 t0 exception3    # if a0 = -1, fclose returns an error




    # 6. return a pointer to the matrix
    mv a0 s5                # a0 = s5 is the pointer to the matrix in memory



    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32

    jr ra

exception1:             # malloc returns an error
    li a0 26
    j exit

exception2:             # fopen returns an error
    li a0 27
    j exit

exception3:             # fclose returns an error.
    li a0 28
    j exit
    
exception4:             # fread does not read the correct number of bytes
    li a0 29
    j exit
