vsim -t ns -novopt -lib work work.tb_alu_sim_cfg  
view *
do alu_wave.do
run 1300 ms
