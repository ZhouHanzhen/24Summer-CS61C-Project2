.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
ebreak
relu:
    # Prologue
    addi sp sp -4
    sw s0 0(sp)
    
    # if a1 < 1, exception
    addi t0 x0 1
    blt a1 t0 exception

    addi t1 x0 0        # t1 = i = 0

loop_start:
    slli s0 t1 2
    add t2 a0 s0
    lw t3 0(t2)                 # t3 = arr[i]

    bge t3 x0 loop_continue     # arr[i] >= 0, loop
    addi t3 x0 0                # arr[i] < 0, t3 = 0 
    sw t3 0(t2)                 # arr[i] = 0

loop_continue:   
    addi t1 t1 1                # i = i + 1 
    blt t1 a1 loop_start     # i < num of elements in the array

loop_end:

    # Epilogue
    lw s0 0(sp) 
    addi sp sp 4

    jr ra

exception:
    li a0 36
    j exit

