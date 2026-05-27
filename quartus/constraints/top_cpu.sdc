# Timing constraints for top_cpu (Intel Quartus / TimeQuest)
# Adjust clock period if your board uses another frequency.

# Example: 50 MHz board clock -> period 20 ns
create_clock -name clk -period 20.000 [get_ports {clk}]

# Reset is asynchronous in RTL; false path from reset is often acceptable for student projects.
# set_false_path -from [get_ports {rst_n}]
