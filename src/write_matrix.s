.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)


    mv s0 a0            # s0 = a0 is the pointer to string representing the filename
    mv s1 a1            # s1 = a1 is the pointer to the start of the matrix in memory
    mv s2 a2            # s2 = a2 is the number of rows in the matrix
    mv s3 a3            # s3 = a3 is the number of columns in the matrix

    # 1. Open the file with write permissions.
    mv a0 s0            # a0 is the pointer to the filename string
    li a1 1             # a1 is 1 for write-only
    jal fopen

    addi t0 x0 -1           # t0 = -1 
    beq a0 t0 exception2    # if a0 = -1, fopen returns an error

    mv s4 a0                # s4 = a0 is the file descriptor of the file



    # 2. Write the number of rows and columns to the file.
    # Allocate space on the heap to store the number of rows and columns
    li a0 8                 # a0 is the size of the memory that we want to allocate (in bytes)
    jal malloc  

    li t0 0        
    beq a0 t0 exception1    # if a0 = 0, malloc returns an error

    mv s5 a0                # s5 = a0 is the pointer to the number of rows and columns in memory
    sw s2 0(s5)             # store the number of rows (s2) to memory at s5
    sw s3 4(s5)             # store the number of columns (s3) to memory at (s5 + 4)


    # call fwrite to write the number of rows and columns to the file
    mv a0 s4                # a0 = s4 is the file descriptor of the file we want to write to, previously returned by fopen
    mv a1 s5                # a1 = s5 is the pointer to a buffer containing what we want to write to the file
    li a2 2                 # a2 is the number of elements to write to the file
    li a3 4                 # a3 is the size of each element

    addi sp sp -4 
    sw a2 0(sp)
    jal fwrite 
    lw a2 0(sp)
    addi sp sp 4

    bne a0 a2 exception4    # if a0 != a2, fwrite does not write the correct number of bytes


    # free the pointer to the number of rows and columns in memory


    # 3. Write the data to the file
    mv a0 s4
    mv a1 s1 
    mul a2 s2 s3
    li a3 4

    addi sp sp -4 
    sw a2 0(sp)
    jal fwrite 
    lw a2 0(sp)
    addi sp sp 4

    bne a0 a2 exception4        # fwrite does not write the correct number of bytes



    # 4.Close the file.
    mv a0 s4
    jal fclose

    li t0 -1
    beq a0 t0 exception3        # if a0 = -1, fclose returns an error



    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 28

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
exception4:
    li a0 30            # fwrite does not write the correct number of bytes
    j exit