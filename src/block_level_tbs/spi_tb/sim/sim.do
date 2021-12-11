# QuestaSim Script

# IMPORTANT set UVM path!
set UVM_LIB    C:/fpga/questasim64_10.7c/uvm-1.2

set RTL        ../../../rtl
set AGENTS     ../../../agents
set UTILS      ../../../utils
set TAR_PATH   ../../../../
set TEST       spi_interrupt_test


quit -sim
catch {file delete -force work}

vlib work

vlog -incr +incdir+${UVM_LIB} +incdir+${RTL}/spi/rtl/verilog ${RTL}/spi/rtl/verilog/*.v
vlog -incr +incdir+${UVM_LIB} +incdir+${AGENTS}/apb_agent +incdir+${UTILS} ${AGENTS}/apb_agent/apb_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_LIB} +incdir+${AGENTS}/spi_agent +incdir+${UTILS} ${AGENTS}/spi_agent/spi_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_LIB} +incdir+../register_model ../register_model/spi_reg_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${AGENTS}/apb_agent/apb_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${AGENTS}/apb_agent/apb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${AGENTS}/apb_agent/apb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${AGENTS}/spi_agent/spi_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${AGENTS}/spi_agent/spi_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${AGENTS}/spi_agent/spi_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${UTILS}/interrupt/intr_pkg.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${UTILS}/interrupt/intr_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} ${UTILS}/interrupt/intr_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_LIB} +incdir+../env ../env/spi_env_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_LIB} +incdir+../sequences ../sequences/spi_bus_sequence_lib_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_LIB} +incdir+../sequences ../sequences/spi_test_seq_lib_pkg.sv
vlog -incr +incdir+${UVM_LIB} +incdir+../test ../test/spi_test_lib_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_LIB} -timescale 1ns/10ps +incdir+${RTL}/spi/rtl/verilog ../tb/hvl_top.sv
vlog -incr +incdir+${UVM_LIB} -timescale 1ns/10ps +incdir+${RTL}/spi/rtl/verilog ../tb/hdl_top.sv

vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME=${TEST} -suppress 8887
