# QuestaSim Script

# IMPORTANT set UVM path!
set QUESTA_HOME C:/fpga/questasim_10.7c
set UVM_HOME    ${QUESTA_HOME}/verilog_src/uvm-1.2

set BLOCK_TB    ../../../block_level_tbs
set RTL         ../../../../rtl
set AGENTS      ../../../../vip/agents
set UTILS       ../../../../vip/utils

set TEST pss_spi_interrupt_test

quit -sim
catch {file delete -force work}

vlib work

# UVM
vlog -incr +incdir+${UVM_HOME}/src ${UVM_HOME}/src/uvm_pkg.sv -ccflags -DQUESTA \
    -ccflags -Wno-maybe-uninitialized \
    -ccflags -Wno-missing-declarations \
    -ccflags -Wno-return-type \
    ${UVM_HOME}/src/dpi/uvm_dpi.cc

# RTL
vlog -incr +incdir+${RTL}/spi/rtl/verilog ${RTL}/spi/rtl/verilog/*.v
vlog -incr +incdir+${RTL}/gpio/rtl/verilog ${RTL}/gpio/rtl/verilog/*.v
vlog -sv -incr +incdir+${RTL}/uart/rtl ${RTL}/uart/rtl/*.v
vlog ${RTL}/icpit/rtl/*.v -timescale 1ns/10ps
vlog -incr +incdir+${RTL}/gpio/rtl/verilog ${RTL}/ahb2apb/rtl/*.sv -timescale 1ns/10ps
vlog -incr +incdir+${RTL}/gpio/rtl/verilog ${RTL}/pss/rtl/pss.sv -timescale 1ns/10ps
vlog ${RTL}/pss/rtl/pss_wrapper.sv -timescale 1ns/10ps

# AGENTS & SEQS
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/apb_agent +incdir+${UTILS} ${AGENTS}/apb_agent/apb_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/spi_agent +incdir+${UTILS} ${AGENTS}/spi_agent/spi_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/ahb_agent +incdir+${UTILS} ${AGENTS}/ahb_agent/ahb_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/gpio_agent +incdir+${UTILS} ${AGENTS}/gpio_agent/gpio_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/modem_agent +incdir+${UTILS} ${AGENTS}/modem_agent/modem_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${AGENTS}/uart_agent +incdir+${UTILS} ${AGENTS}/uart_agent/uart_agent_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/apb_agent/apb_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/apb_agent/apb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/apb_agent/apb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/spi_agent/spi_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/spi_agent/spi_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/spi_agent/spi_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/gpio_agent/gpio_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/gpio_agent/gpio_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/gpio_agent/gpio_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/ahb_agent/ahb_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/ahb_agent/ahb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/ahb_agent/ahb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/modem_agent/modem_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/modem_agent/modem_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/modem_agent/modem_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/uart_agent/serial_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/uart_agent/uart_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${AGENTS}/uart_agent/uart_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${UTILS}/interrupt/intr_pkg.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${UTILS}/interrupt/intr_if.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src ${UTILS}/interrupt/intr_bfm.sv -timescale 1ns/10ps -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/spi_tb/register_model ${BLOCK_TB}/spi_tb/register_model/spi_reg_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/gpio_tb/register_model ${BLOCK_TB}/gpio_tb/register_model/gpio_reg_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+../register_model ../register_model/pss_reg_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/spi_tb/env ${BLOCK_TB}/spi_tb/env/spi_env_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/gpio_tb/env ${BLOCK_TB}/gpio_tb/env/gpio_env_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+../env ../env/pss_env_pkg.sv -suppress 2263
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/spi_tb/sequences ${BLOCK_TB}/spi_tb/sequences/spi_bus_sequence_lib_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/spi_tb/sequences ${BLOCK_TB}/spi_tb/sequences/spi_test_seq_lib_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/gpio_tb/sequences ${BLOCK_TB}/gpio_tb/sequences/gpio_bus_sequence_lib_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+${BLOCK_TB}/gpio_tb/sequences ${BLOCK_TB}/gpio_tb/sequences/gpio_test_sequence_lib_pkg.sv
vlog -incr +incdir+${UVM_HOME}/src +incdir+../sequences ../sequences/pss_test_seq_lib_pkg.sv 
vlog -incr +incdir+${UVM_HOME}/src +incdir+../test ../test/pss_test_lib_pkg.sv -suppress 2263

# TB
vlog -timescale 1ns/10ps ../tb/apb_prober.sv -timescale 1ns/10ps
vlog -timescale 1ns/10ps ../tb/binder.sv -timescale 1ns/10ps
vlog -timescale 1ns/10ps +incdir+${RTL}/gpio/rtl/verilog ../tb/hvl_top.sv -timescale 1ns/10ps
vlog -timescale 1ns/10ps +incdir+${RTL}/gpio/rtl/verilog ../tb/hdl_top.sv -timescale 1ns/10ps

# SIM
vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME=${TEST} -suppress 8887

# coverage report -detail