set_max_transition 0.15 ${DESIGN_NAME}
set_input_transition 0.08 [all_inputs]
set_max_transition 0.08 [all_outputs]

set_max_fanout 6 ${DESIGN_NAME}

set clock_period 50
set clock_uncertainty [expr $clock_period * 0.001] 
set clock_transition 0.080
set clock_latency 0.1 

create_clock -name clk -period $clock_period [get_ports clk]

set_clock_uncertainty $clock_uncertainty [get_clocks clk]
set_clock_transition $clock_transition [get_clocks clk]
set_clock_latency $clock_latency [get_clocks clk]

set_load 0.3 [all_outputs]
set_driving_cell -no_design_rule -lib_cell NBUFFX4_RVT [all_inputs]

set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" a*] -clock clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" a*] -clock clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" b*] -clock clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" b*] -clock clk
set_output_delay -max [expr $clock_period * 0.5] [get_ports -filter "direction == out" c*] -clock clk
set_output_delay -min [expr $clock_period * 0.4] [get_ports -filter "direction == out" c*] -clock clk
set_output_delay -max [expr $clock_period * 0.3] [get_ports -filter "direction == out" mo*] -clock clk
set_output_delay -min [expr $clock_period * 0.2] [get_ports -filter "direction == out" mo*] -clock clk

set_false_path -from [get_ports -filter "direction == in" rst]
