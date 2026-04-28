
#questa script file 
# 1. Create the work library
vlib work

# 2. Compile RTL and SystemVerilog files in correct order
vlog spi_master.v
vlog -sv spi_if.sv
vlog -sv transaction.sv
vlog -sv generator.sv
vlog -sv driver.sv
vlog -sv monitor.sv
vlog -sv scoreboard.sv
vlog -sv environment.sv
vlog -sv testbench.sv

# 3. Load the simulation with visibility for all signals (+acc)
vsim -voptargs="+acc" work.testbench

# 4. Add signals to the waveform
# -r /* adds all signals recursively (RTL + Testbench)
add wave -r /*

# 5. Run the simulation
run -all

# 6. Zoom to fit the full transaction in the wave window
wave zoom full
