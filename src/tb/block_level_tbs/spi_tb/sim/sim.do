# QuestaSim Script for SPI Testbench

# IMPORTANT set YOUR QUESTA_HOME path!
set QUESTA_HOME C:/fpga/questasim_10.7c

set UVM_HOME    ${QUESTA_HOME}/verilog_src/uvm-1.2
set RTL         ../../../../rtl
set AGENTS      ../../../../vip/agents
set UTILS       ../../../../vip/utils

# Default test - only set if not already defined
if ![info exists TEST] {
    set TEST        spi_interrupt_test
}

quit -sim
catch {file delete -force work}

vlib work

# UVM - compile explicitly for Questa 10.7c compatibility
vlog -incr +incdir+${UVM_HOME}/src ${UVM_HOME}/src/uvm_pkg.sv -ccflags -DQUESTA \
    -ccflags -Wno-maybe-uninitialized \
    -ccflags -Wno-missing-declarations \
    -ccflags -Wno-return-type \
    ${UVM_HOME}/src/dpi/uvm_dpi.cc

# RTL
vlog -incr +incdir+${RTL}/spi/rtl/verilog ${RTL}/spi/rtl/verilog/*.v

# Agents
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/apb_agent +incdir+${UTILS} ${AGENTS}/apb_agent/apb_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/spi_agent +incdir+${UTILS} ${AGENTS}/spi_agent/spi_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/apb_agent/apb_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/apb_agent/apb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/apb_agent/apb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/spi_agent/spi_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/spi_agent/spi_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/spi_agent/spi_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${UTILS}/interrupt/intr_pkg.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${UTILS}/interrupt/intr_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${UTILS}/interrupt/intr_bfm.sv -timescale 1ns/10ps -suppress 2263

# Register Model
vlog -incr +incdir+${UVM_HOME}/src +incdir+../register_model ../register_model/spi_reg_pkg.sv

# Env, Sequences, Tests
vlog -incr +incdir+${UVM_HOME}/src +incdir+../env ../env/spi_env_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+../sequences ../sequences/spi_bus_sequence_lib_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+../sequences ../sequences/spi_test_seq_lib_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+../test ../test/spi_test_lib_pkg.sv -suppress 2263

# TB
vlog -timescale 1ns/10ps +incdir+${RTL}/spi/rtl/verilog ../tb/hvl_top.sv -timescale 1ns/10ps
vlog -timescale 1ns/10ps +incdir+${RTL}/spi/rtl/verilog ../tb/hdl_top.sv -timescale 1ns/10ps

# SIM
vsim -c -do "run -all; quit -f" hvl_top hdl_top +UVM_TESTNAME=${TEST} -suppress 8887
