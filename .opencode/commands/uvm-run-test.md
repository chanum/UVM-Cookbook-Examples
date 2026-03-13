---
description: Run UVM testbench simulation
agent: general
---

# UVM Test Runner

I'll run a UVM simulation test.

Usage:
- `/uvm-run-test` - defaults to spi_tb / spi_reg_test
- `/uvm-run-test spi_tb spi_interrupt_test` 
- `/uvm-run-test gpio_tb gpio_input_test`

Available testbenches:
- **spi_tb**: spi_interrupt_test, spi_poll_test, spi_reg_test
- **gpio_tb**: gpio_input_test, gpio_outputs_test, gpio_reg_test  
- **pss_tb**: pss_spi_polling_test, pss_spi_interrupt_test, pss_gpio_outputs_test

$ARGUMENTS

Now determine which testbench and test to run, then execute the simulation and report pass/fail.
