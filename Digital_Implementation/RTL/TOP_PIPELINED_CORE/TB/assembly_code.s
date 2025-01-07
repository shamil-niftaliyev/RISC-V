## Pseudo assembly task: Find Log2(64) using beq loop
start:        addi x2, x0, 2               # Base
              addi x3, x0, 64              # Argument
              addi x4, x0, 0               # Temporary argument
              addi x5, x0, 0               # Temporary exponent
              addi x8, x0, 1               # Storing 1
addup:        beq  x4, x3, logfinished     # Go to logfinished if x4 = 64
              add  x4, x4, x2              # x4 = x4 + 2
              addi x5, x5, 1               # x5 = x5 + 1    
              jal  x6, addup
logfinished:  sw x5, 50(x0)                # Writing the result into x50 of the memory
              addi x4, x0, 0               # Resetting x4
              addi x5, x0, 0               # Resetting x5                                         
complement:   addi x6, x0, -1              # Load negative one into x6
              lw   x4, 50(x0)              # Load the value of exponent into x4
              sub  x5, x6, x4              # x5 = -1 - x4
              addi x5, x5, 1               # x5 = x5 + 1 (getting 2's complement)
isnegative:   slt  x6, x5, x0              # if x5 < 0 then x6 = 1
choose:       beq  x6, x8, finish2
finish1:      or   x7, x5, x6
              sw   x7, 54(x0)
finish2:      and  x7, x5, x6
              sw   x7, 52(x0)