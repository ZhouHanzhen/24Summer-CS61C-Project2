.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    addi t0 x0 1            # t0 = 1
    blt a2 t0 exception1    # n < 1
    blt a3 t0 exception2
    blt a4 t0 exception2

    # Prologue
    addi sp sp -16
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)

    add t0 x0 x0            # t0 = i = 0
    add t1 x0 x0            # t1 = j = 0
    add t5 x0 x0            # t5 = k = 0
    add s0 x0 x0            # product = s0 = 0


loop_start:
    slli s1 t0 2
    add t2 a0 s1
    lw t3 0(t2)             # t3 = arr0[i]

    slli s2 t1 2 
    add t2 a1 s2 
    lw t4 0(t2)             # t4 = arr1[j]

    mul s3 t3 t4            # s3 = arr0[i] * arr1[j] 
    add s0 s0 s3            # s0 = s0 + arr0[i] * arr1[j] 

    add t0 t0 a3            # i += a3
    add t1 t1 a4            # j += a4
    addi t5 t5 1            # k += 1

    blt t5 a2 loop_start      # if k < n,loop_start


loop_end:
    mv a0 s0                # return product

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    addi sp sp 16

    jr ra

exception1: 
    li a0 36
    j exit

exception2:
    li a0 37
    j exit
