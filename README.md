# FPGA Calculator for Basys 3 Board
This is an example implementation of a simple calculator circuit in vhdl.
The Project was implemented with Siemens ModelSim and later put on the [Basys 3 FPGA Developement Board](https://www.xilinx.com/products/boards-and-kits/1-54wqge.html) with Xilinx Vivado.
The calculator can add, square and exOR two 12 bit numbers. Additionally it can invert a single 12 bit number.

It is structured in a calc_top module with 3 submodules: calc_ctrl, io_ctrl and alu.
There are compile and simulation scripts for all submodules and the whole configuration. Also there are full feature testbenches for the submodules and a small test for the whole configuration. 



