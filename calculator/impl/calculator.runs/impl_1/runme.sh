#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
# 

echo "This script was generated under a different operating system."
echo "Please update the PATH and LD_LIBRARY_PATH variables below, before executing this script"
exit

if [ -z "$PATH" ]; then
  PATH=E:/Vivado/2016.1/ids_lite/ISE/bin/nt64;E:/Vivado/2016.1/ids_lite/ISE/lib/nt64:E:/Vivado/2016.1/bin
else
  PATH=E:/Vivado/2016.1/ids_lite/ISE/bin/nt64;E:/Vivado/2016.1/ids_lite/ISE/lib/nt64:E:/Vivado/2016.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='C:/Users/mathi/Desktop/FH_Technikum/Semester_4/CHIP1/Final_Project/calculator/impl/calculator/calculator.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log calc_top_struc_cfg.vdi -applog -m64 -messageDb vivado.pb -mode batch -source calc_top_struc_cfg.tcl -notrace


