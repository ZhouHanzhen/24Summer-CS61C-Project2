.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    addi t0 x0 1
    blt a1 t0 exception
    blt a2 t0 exception
    blt a4 t0 exception
    blt a5 t0 exception
    bne a2 a4 exception

    # Prologue

    addi sp sp -32
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw ra 28(sp)

    mv s0 a0    # m0
    mv s1 a1    # s1 = n
    mv s2 a2    # s2 = m
    mv s3 a3    # m1
    mv s4 a4    # s4 = m
    mv s5 a5    # s5 = k
    mv s6 a6    # d
    
    addi t0 x0 0                # i = t0 = 0
    addi t1 x0 0                # j = t1 = 0
    slli t2 s2 2                # t2 = s2 * 4 = m * 4
    slli t3 s5 2                # t3 = s5 * 4 = k * 4

outer_loop_start:
    
    
inner_loop_start:
    # pass the arguments to the a's registers
    mv a0 s0                    # a0 is the pointer to the start of arr0, is s0
    mv a1 s3                    # a1 is the pointer to the start of arr1, is s3
    mv a2 s2                    # a2 is the number of elements to use, is s2 = m
    addi a3 x0 1                # a3 is the stride of arr0, is 1
    mv a4 s5                    # a4 is the stride of arr1, is s5 = k

    addi sp sp -16
    sw t0 0(sp)
    sw t1 4(sp)
    sw t2 8(sp)
    sw t3 12(sp)

    # call the dot function
    jal dot
    sw a0 0(s6)                 # d[i][j] = a0 = dot product, store the dot product to the memory

    lw t0 0(sp)
    lw t1 4(sp)
    lw t2 8(sp)
    lw t3 12(sp)
    addi sp sp 16 

    addi t1 t1 1                # j += 1
    addi s3 s3 4                # s3 += 4; s3 is the pointer to the next column of m1
    addi s6 s6 4                # s6 is the pointer to the location of next d[i][j]
    blt t1 s5 inner_loop_start  # if j < k, inner loop

inner_loop_end:
    addi t1 x0 0                # inner loop end , set j = 0
    sub s3 s3 t3                # inner loop end, set s3 to the first column of m1, s3 = s3 - t3 = s3 - k * 4
    
    addi t0 t0 1                # i += 1
    add s0 s0 t2                # s0 is the pointer to the next row of m0
    blt t0 s1 outer_loop_start  # if i < n, outer loop

outer_loop_end:


    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw ra 28(sp)
    addi sp sp 32

    jr ra

exception:
    li a0 38
    j exit