# Image-Downsampling-Processor
Design and Implementation of RISC related processor using VERILOG HDL and XILINX SPARTAN-6 FPGA

## compileme.py
simple asm compiler (don't rely solely on this for error detection)

usage:

python compileme.py <input file name(required)> <output file name(optional)>

## tryme.py
simple asm simulator (don't rely solely on this for error detection)

usage:

python tryme.py <input file name(required)> <output file name(optional)>

edit source file's "MEM" dictionary for initializing dram

## processor_top_module.v
top module of the processor. should include two block rams;
1. iram->16x4096 bits (12 bit address width)
2. dram->8x131072 bits (17 bit address width)

## ISA
### INSTRUCTIONS

1. NOP ------> NO OPERATION ------> 0000
2. ADD[R][CONST] ------> AC<-AC+([R]+[CONST]) ------> 0001
3. SUB[R][CONST] ------> AC<-AC-([R]+[CONST]) ------> 0010
4. MUL[R][CONST] ------> AC<-AC*([R]+[CONST]) ------> 0011
5. DIV[R][CONST] ------> AC<-AC/([R]+[CONST]) ------> 0100
6. SHR<8'b0>[N] ------> SHIFT RIGHT N BITS ------> 0101
7. SHL<8'b0>[N] ------> SHIFT LEFT N BITS ------> 0110
8. LOAD[M] ------> MDR <-[M+2*MBR] ------> 0111
9. STORE[M] ------> [M+2*MBR] <-MDR ------> 1000
10. JUMP[INST] ------> JUMP TO [INST] ------> 1001
11. JMPZ[INST] ------> JUMP TO [INST] IF Z FLAG IS HIGH ------> 1010
12. JMPDEC[INST] ------> JUMP TO [INST] AND DECREMENT LR BY ONE IF LRZ IS LOW ------> 1011
13. MOVE[S][D] ------> [D]<-[S] ------> 1100
14. UARTSEND ------> WAIT FOR UART OUTPUT TO COMPLETE ------> 1101
15. UARTREAD ------> WAIT FOR UART INPUT TO COMPLETE ------> 1110

### DATA WIDTH:
OPCODE ------> 4 BITS

[R] ------> 5 BITS

[CONST] ------> 7 BITS

[N] ------> 4 BITS

[M] ------> 12 BITS

[INST] ------> 12 BITS

[S], [D] ------> 5 BITS


### FLAGS

1. ------> Z ------> AC IS ZERO FLAG
2. ------> LRZ ------> LR IS ZERO FLAG
3. ------> TXBUSY ------> UART TX BUSY FLAG
4. ------> RXREADY ------> UART RX READY FLAG



### REGISTERS

1. PC ------> PROGRAM COUNTER 
2. IR ------> INSTRUCTION REGISTER
3. ZR ------> ZERO REGISTER ------> 00000 
4. MBR ------> MEMORY BASE REGISTER ------> 00001
5. MDR ------> MEMORY DATA REGISTER ------> 00010
6. UARTTX ------> UART TX REGISTER ------> 00011
7. UARTRX ------> UART RX REGISTER ------> 00100
8. AC ------> ACCUMULATOR ------> 00101
9. LR ------> LOOP REGISTER ------> 00110
10. R1 ------> GP REG ------> 1XXXX (XXXX from 0000 to 1111)
11. R2 ------> GP REG
12. R3 ------> GP REG
13. R4 ------> GP REG
14. R5 ------> GP REG
15. R6 ------> GP REG
16. R7 ------> GP REG
17. R8 ------> GP REG
18. R9 ------> GP REG
19. R10 ------> GP REG
