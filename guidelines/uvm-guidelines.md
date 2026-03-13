# UVM Guidelines

UVM brings clarity to the SystemVerilog language by providing a structure for how to use the features in SystemVerilog. However, in many cases, UVM provides multiple mechanisms to accomplish the same work. This guideline document provides structure to UVM in the same way that UVM provides structure to SystemVerilog.

---

## Quick Reference: UVM Do's and Don'ts

| ✅ UVM Do's | ❌ UVM Don'ts |
| :--- | :--- |
| Define classes within packages | Avoid `` `including `` a class in multiple locations |
| Define one class per file | Avoid constructor arguments other than `name` and `parent` |
| Use factory registration macros | Avoid field automation macros |
| Use message macros | Avoid calling `super.build_phase()` from extended components |
| Always specify the `name` argument to constructor | Avoid `uvm_comparer` policy class |
| Manually implement `do_copy()`, `do_compare()`, etc. | Avoid the sequence list and default sequence |
| Use `sequence.start(sequencer)` | Avoid the sequence macros (`` `uvm_do ``) |
| Use `start_item()` and `finish_item()` | Avoid `pre_body()` and `post_body()` in a sequence |
| Use the `uvm_config_db` API | Avoid explicitly consuming time in sequences |
| Use a configuration class for each agent | Avoid `set/get_config_string/_int/_object()` |
| Use phase objection mechanism | Avoid the `uvm_resource_db` API |
| Use the `phase_ready_to_end()` func | Avoid callbacks |
| Use the `run_phase()` in transactors | Avoid user-defined phases |
| Only use reset/configure/main/shutdown in tests | Avoid phase jumping and phase domains (for now) |
| | Avoid raising/lowering objections for every transaction |

---

## 1. Class Definitions

### 1.1 Rule: Define all classes within a package
> Define all classes within a package (exception: Abstract/Concrete classes). Don't `` `include `` class definitions haphazardly throughout the testbench. Having all classes defined in a package makes it easy to share class definitions. Importing a class wherever it is needed can cause a class to be defined multiple times as different types.

### 1.2 Rule: Define one class per file
> Every class should be defined in its own file named `<CLASSNAME>.svh`. The file should then be included in another file which defines a package (ending in `_pkg.sv`). The file containing the class definition should not contain any `import` or `include` statements.

**Directory Structure Example:**
` ` `text
example_agent/
└── example_agent_pkg.sv
    ├── example_item.svh
    ├── example_config.svh
    ├── example_driver.svh
    ├── example_monitor.svh
    ├── example_agent.svh
    ├── example_api_seq1.svh
    └── reg2example_adapter.svh
` ` `

**Package File Example (`example_pkg.sv`):**
` ` `systemverilog
// Begin example_pkg.sv file
`include "uvm_macros.svh"

package example_pkg;
  import uvm_pkg::*;
  import another_pkg::*;
 
  // Include any transactions/sequence_items
  `include "example_item.svh"
 
  // Include any configuration classes
  `include "example_config.svh"
 
  // Include any components
  `include "example_driver.svh"
  `include "example_monitor.svh"
  `include "example_agent.svh"
 
  // Include any API sequences
  `include "example_api_seq1.svh"
 
  // Include the UVM Register Layer Adapter
  `include "reg2example_adapter.svh"
endpackage : example_pkg
// End example_pkg.sv file
` ` `

### 1.3 Rule: Call `super.new(name [,parent])` first
> Explicitly pass the required arguments to the super constructor as the first line. The constructor should only contain the call to `super.new()` and optionally new covergroups. All other objects should be built in the `build_phase()` (components) or `body()` (sequences).

### 1.4 Rule: Always Specify the "name" argument
> Always specify the `name` argument to the `uvm_object` constructor (Required in UVM 1.2+).

### 1.5 Rule: Never call `super.build_phase()`
> Never call `super.build_phase()` from any component extended from a UVM base class. It engages the evil Field Automation macros, causing performance degradation. (Note: It is OK to call it from your *own* custom base classes).

### 1.6 Rule: Don't add extra constructor arguments
> Extra arguments other than `name` and `parent` will result in the UVM Factory being unable to create the object requested, or they will always fall back to default values.

---

## 2. Factory

### 2.1 Rule: Register and create all classes with the Factory
> Registering all classes and creating all objects with the UVM Factory maximizes flexibility with no run-time penalty.

### 2.2 Rule: Import packages that define registered classes
> Be sure to import all packages that have classes defined in them, especially the package containing all the tests into the top-level testbench module.

### 2.3 Guideline: Match handle name with string name
> When creating an object with the factory `create()` call, match the object's handle name with the string name passed into the first argument to aid in debugging the hierarchy.

---

## 3. Macros

### 3.1 Rule: Use factory registration macros
> Use `` `uvm_object_utils() ``, `` `uvm_object_param_utils() ``, `` `uvm_component_utils() ``, and `` `uvm_component_param_utils() ``. Avoid `` `uvm_sequence_utils() `` and `` `uvm_sequencer_utils() ``.

### 3.2 Guideline: Use UVM message macros
> Use `` `uvm_info() ``, `` `uvm_warning() ``, `` `uvm_error() ``, and `` `uvm_fatal() `` for performance savings and automatic file/line number logging.

### 3.3 Guideline: Write your own core methods
> Write your own `do_copy()`, `do_compare()`, `do_print()`, `do_pack()`, and `do_unpack()` functions. **Do not use the field automation macros** (like `` `uvm_field_int() ``) as they generate hundreds of lines of inefficient code. Also, avoid using the `uvm_comparer` policy class in your `do_compare()` function.

---

## 4. Sequences

### 4.1 Rule: Use `sequence.start(sequencer)`
> Start your sequences by creating them in a test and calling `sequence.start(sequencer)` in a run phase task. Use `fork/join` blocks for parallel execution.

### 4.2 Rule: Create sequence items manually
> Create sequence items with the factory. Use `start_item()` and `finish_item()`. **Do not use** the 18 UVM sequence macros (`` `uvm_do ``, `` `uvm_send ``, etc.).

### 4.3 Guideline: Avoid `pre_body()` and `post_body()`
> Do not use `pre_body()` and `post_body()`. Move their functionality to the beginning and end of the `body()` task instead.

### 4.4 Guideline: Input variables `rand`, output non-`rand`
> Make sequence input variables `rand` for easy manipulation. Output variables (accessed after the sequence runs) should not be `rand` to save resources.

### 4.5 Rule: No explicit time consumption
> Sequences should not explicitly consume time (e.g., `#10ns`). This reduces reuse and breaks emulator acceleration.

### 4.6 Guideline: Check for null sequencer handles
> When using a virtual sequencer, check for null sequencer handles before executing virtual sequences.

---

## 5. Phasing

### 5.1 Guideline: Transactors only implement `run_phase()`
> Drivers and monitors should only implement `run_phase()`. They should not implement any other time-consuming phases.

### 5.2 Guideline: Limit runtime phases to tests
> Avoid the usage of `reset_phase()`, `configure_phase()`, `main_phase()`, `shutdown_phase()`, and their `pre_/post_` versions in components. Use them only in tests. Use standard `fork/join` for sync points.

### 5.3 Guideline: Avoid phase jumping and domains
> Avoid these features for now unless you are a very advanced user, as they are not well understood.

### 5.4 Guideline: Do not use user-defined phases
> Adding custom phases makes integration and debugging extremely difficult.

---

## 6. Configuration

### 6.1 Rule: Use `uvm_config_db` API exclusively
> Use `uvm_config_db`. **Do not use** `set/get_config_object()`, `set/get_config_string()`, or `set/get_config_int()` (they are deprecated). Do not use the `uvm_resource_db` API.

### 6.2 Rule: Create configuration classes
> Create a configuration class for each agent to hold its settings (bits, strings, virtual interfaces). Use a single `uvm_config_db #(config_class)::set()` call for type-safety and efficiency.

### 6.3 Guideline: Don't use config space for frequent communication
> Use standard TLM communication for frequent information changes between components instead of polling the configuration database.

### 6.4 Rule: Pass virtual interfaces via `uvm_config_db`
> Pass virtual interface handles from the top-level testbench using: `uvm_config_db #(virtual bus_interface)::set(null, "uvm_test_top", "bus_interface", bus_interface);`

---

## 7. Coverage

### 7.1 Guideline: Wrap covergroups
> Place covergroups within wrapper classes extended from `uvm_object` so the testbench can dynamically decide at run-time whether to construct them.

---

## 8. End of Test

### 8.1 Rule: Use the phase objection mechanism
> Raise and drop objections on the `phase` argument to control test completion. Use `phase_ready_to_end()` to extend time when needed.

### 8.2 Rule: Only raise/lower objections in a test
> Do not raise and lower objections on a transaction-by-transaction basis (e.g., in drivers or monitors) as it causes significant simulation slowdown.

---

## 9. Callbacks

### 9.1 Guideline: Do not use callbacks
> Avoid the UVM callback mechanism due to memory/performance footprint and ordering issues. Use standard OOP practices instead (like factory overrides or child object delegation).

---

## 10. MCOW (Manual Copy on Write)

### 10.1 Guideline: Copy transactions before modifying
> If a component modifies a transaction received via TLM 1.0 (blocking put/get ports, analysis_ports), it must make a copy first. SV does not have a `const` attribute, making direct modifications dangerous. (Note: This does not apply to Sequences and TLM 2.0).

---

## 11. Command Line Processor

### 11.1 Rule: Don't prefix user plusargs with `uvm_`
> Do not use `uvm_` or `UVM_` prefixes, as they are reserved for the UVM committee.

### 11.2 Guideline: Use company/group prefixes
> Use a company or group prefix for user-defined plusargs to prevent namespace collisions when sharing IP.