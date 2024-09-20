onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_calc_top/clk_i
add wave -noupdate -format Logic /tb_calc_top/reset_i
add wave -noupdate -format Logic /tb_calc_top/sw_i
add wave -noupdate -format Logic /tb_calc_top/pb_i
add wave -noupdate -format Logic /tb_calc_top/ss_o
add wave -noupdate -format Logic /tb_calc_top/ss_sel_o
add wave -noupdate -format Logic /tb_calc_top/led_o
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/s_start
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/s_finished
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/s_result
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/i_alu/s_operation
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/i_calc_ctrl/s_entrystate
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/i_calc_ctrl/dig0_o
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/i_calc_ctrl/dig1_o
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/i_calc_ctrl/dig2_o
add wave -noupdate -format Logic /tb_calc_top/i_calc_top/i_calc_ctrl/dig3_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {50 ms}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -signalnamewidth 0
configure wave -justifyvalue left
