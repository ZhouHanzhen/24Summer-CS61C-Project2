.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi sp sp -12
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)

    addi t0 x0 1
    blt a1 t0 exception

    addi t0 x0 0            # i = t0 = 0
    addi s0 x0 0            # index = s0 = 0
    lw s1 0(a0)             # max = s1 = arr[0]

loop_start:
    slli s2 t0 2            
    add t1 a0 s2
    lw t2 0(t1)             # t2 = arr[i]

ebreak
    bge s1 t2 loop_continue # if max >= arr[i], continue
    addi s1 t2 0            # if max < arr[i], max = arr[i]
    addi s0 t0 0            # index = i

loop_continue:
    addi t0 t0 1            # i = i + 1
    blt t0 a1 loop_start    # if i < a1, loop

loop_end:
    mv a0 s0                # a0 = s0 = index, return index

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    addi sp sp 12 

    
    jr ra

exception:
    li a0 36
    j exit