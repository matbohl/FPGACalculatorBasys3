vsim -t ns -novopt -lib work work.tb_calc_ctrl_sim_cfg  
view *
do calc_ctrl_wave.do
run 1000 ns
