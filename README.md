# Image-Downsampling-Processor
Design and Implementation of RISC related processor using VERILOG HDL and XILINX SPARTAN-6 FPGA

## compileme.py
simple asm compiler

usage:

compileme.py <input file name(required)> <output file name(optional)>

## processor_top_module.v
top module of the processor. should include two block rams;
1. iram->16x4096 bits (12 bit address width)
2. dram->8x131072 bits (17 bit address width)
