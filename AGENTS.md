# AGENTS.md - UVM Cookbook Examples

This document provides guidelines for agentic coding agents working in this repository.

## Project Overview

This is a **SystemVerilog/UVM verification codebase** containing UVM (Universal Verification Methodology) testbenches for various IP blocks. It uses Questa/ModelSim for simulation.

## Directory Structure

```
src/
├── rtl/           # RTL designs (spi, gpio, uart, ahb2apb, pss, icpit)
├── vip/           # Verification IP (agents and utilities)
│   ├── agents/    # APB, SPI, GPIO, AHB, UART, Modem agents
│   └── utils/     # Interrupt utilities
└── tb/            # Testbenches
    ├── block_level_tbs/  # spi_tb, gpio_tb
    └── sub_system_tbs/   # pss_tb
```

## Build/Lint/Test Commands

### Running Simulations

#### SPI Testbench (block_level_tbs)
```bash
cd src/tb/block_level_tbs/spi_tb/sim
make all              # Build and run default test (spi_interrupt_test)
make run              # Run with default test
make build            # Build only
TEST=spi_poll_test make run  # Run specific test
make clean            # Clean build artifacts
```

#### PSS Subsystem Testbench
```bash
cd src/tb/sub_system_tbs/pss_tb/sim
make all              # Build and run default test (pss_spi_interrupt_test)
make run              # Run with default test
make uvm rtl build tb # Build components
TEST=pss_gpio_outputs_test make run  # Run specific test
make clean            # Clean build artifacts
```

#### Using sim.do (Questa Direct)
```bash
cd src/tb/sub_system_tbs/pss_tb/sim
# Edit sim.do to set TEST variable, then:
vsim -c -do sim.do
```

### Running a Single Test

Set the `TEST` environment variable:
```bash
TEST=spi_interrupt_test make run    # SPI testbench
TEST=pss_spi_polling_test make run  # PSS testbench
```

Available tests (check `*_test_lib_pkg.sv` files):
- spi_tb: `spi_interrupt_test`, `spi_poll_test`, `spi_reg_test`
- pss_tb: `pss_spi_interrupt_test`, `pss_gpio_outputs_test`

## Git Commands

### Creating a Commit

Only create commits when explicitly requested. When asked to commit:

```bash
# Check status and recent commits
git status
git log --oneline -5

# Stage files and commit
git add <files>
git commit -m "description of changes"
```

### Git Guidelines

- Never update git config or run destructive commands (force push, hard reset)
- Never amend commits unless explicitly requested
- Avoid committing secrets (.env, credentials, etc.)

## Code Style Guidelines

### File Organization

- **Packages**: Use `.sv` extension for package definitions (e.g., `spi_agent_pkg.sv`)
- **Package includes**: Use `.svh` extension for included files (e.g., `spi_driver.svh`)
- **Package naming**: `<module>_pkg.sv` (lowercase with underscores)
- **Class files**: `<class_name>.svh` (lowercase extension, original class case)

### Copyright Header
Every file must include the Apache 2.0 license header:
```systemverilog
//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Packages | snake_case | `spi_agent_pkg` |
| Classes | snake_case | `spi_driver`, `spi_seq_item` |
| Functions/Tasks | snake_case | `build_phase`, `get_config` |
| Variables | snake_case | `m_cfg`, `m_env`, `req`, `rsp` |
| Macros | UPPER_SNAKE_CASE | `uvm_component_utils`, `UVM_TESTNAME` |
| Constants | UPPER_SNAKE_CASE | `UVM_ACTIVE`, `UVM_PASS` |
| Interfaces | snake_case | `spi_if`, `apb_monitor_bfm` |
| File prefixes | component type | `spi_*.svh`, `apb_*.svh` |

### Class Structure

Follow this template for UVM classes:
```systemverilog
// Class Description:
// [Brief description of class purpose]

class <class_name> extends <parent_class>;

  // UVM Factory Registration Macro
  `uvm_component_utils(<class_name>)

  // Virtual Interfaces
  local virtual <interface_bfm> m_bfm;

  // Data Members
  <type> m_cfg;

  // Methods
  extern function new(string name = "<class_name>", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: <class_name>

function <class_name>::new(string name = "<class_name>", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void <class_name>::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // Implementation
endfunction: build_phase
```

### Package Structure

```systemverilog
package <module>_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Additional imports
  import <other_pkg>::*;

  // Includes - order matters!
  `include "<class1>.svh"
  `include "<class2>.svh"
  // ...

endpackage: <module>_pkg>
```

### UVM Macros

- Use `\` `uvm_component_utils(cls)` for components
- Use `\` `uvm_sequence_utils(cls, sqr)` for sequences
- Use `\` `uvm_do(req)` for sequence execution
- Use `\` `uvm_info/warn/error/fatal` for reporting

### Error Handling

- Use `\` `uvm_fatal` for unrecoverable errors (missing interfaces, config)
- Use `\` `uvm_error` for verification failures
- Use `\` `uvm_warning` for non-fatal issues
- Always include descriptive IDs: `\` `uvm_fatal("CFG ERR", "message")`

### Import/Include Order

1. `import uvm_pkg::*;`
2. `\` `include "uvm_macros.svh"`
3. Package-level macros/config
4. Class includes (in dependency order)

### Indentation and Formatting

- Use **2 spaces** for indentation (not tabs)
- Align comments with code above
- Maximum line length: ~120 characters
- Use meaningful section comments:
  ```systemverilog
  //------------------------------------------
  // Data Members
  //------------------------------------------
  //------------------------------------------
  // Methods
  //------------------------------------------
  ```

### Configuration

- Use `uvm_config_db` for virtual interface passing
- Use `uvm_resource_db` for non-interface configuration
- Always check `get()` with `uvm_fatal` if interface is required

### Phase Ordering

Follow standard UVM phase order:
1. `build_phase` (bottom-up)
2. `connect_phase` (bottom-up)
3. `end_of_elaboration_phase`
4. `start_of_simulation_phase`
5. `run_phase` (task)
6. `extract_phase`
7. `check_phase`
8. `report_phase`
9. `final_phase`

## Tools and Requirements

- **Simulator**: Questa/ModelSim (set `QUESTA_HOME` environment variable)
- **UVM Version**: UVM 1.2
- **SystemVerilog**: IEEE 1800 standard
