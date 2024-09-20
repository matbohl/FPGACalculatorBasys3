vsim -t ns -novopt -lib work work.tb_calc_top_sim_cfg  
view *
do calculator_wave.do
run 100 ms
