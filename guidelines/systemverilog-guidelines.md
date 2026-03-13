# SystemVerilog Do's

- Use a consistent coding style - see guidelines
- Use a descriptive typedef for variables
- Use an end label for methods, classes and packages
- Use `` `includes `` to compile classes into packages
- Define classes within packages
- Define one class per file
- Only `` `include `` a file in one package
- Import packages to reference their contents
- Check that `$cast()` calls complete successfully
- Check that `randomize()` calls complete successfully
- Use `if` rather than `assert` to check the status of method calls
- Wrap covergroups in class objects
- Only sample covergroups using the `sample()` method
- Label covergroup coverpoints and crosses

# SystemVerilog Don'ts

- Avoid `` `including `` the same class in multiple locations
- Avoid placing code in `$unit`
- Avoid using associative arrays with a wildcard index
- Avoid using `#0` delays
- Don't rely on static initialization order

---

# SystemVerilog Guidelines | Body

## General Coding Style

Although bad coding style does not stop your code from working, it does make it harder for others to understand and makes it more difficult to maintain. Take pride in writing well-ordered and uniformly formatted code.

### 1.1 Guideline: Indent your code with spaces

Use a consistent number of spaces to indent your code every time you start a new nested block, 2 or 3 spaces is recommended. Do not use tabs since the tab settings vary in different editors and viewers and your formatting may not look as you intended. Many text editors have an indenting mode that automatically replaces tabs with a defined number of spaces.

### 1.2 Guideline: Only one statement per line

Only have one declaration or statement per line. This makes the code clearer and easier to understand and debug.

**Recommended:**

```systemverilog
// Variable definition:
logic enable;
logic completed;
logic in_progress;

// Statements:
// (See next Guideline for the use of begin-end pairs
// with conditional statements)
//
if (enable == 0)
  in_progress = 1;
else
  in_progress = 0;
```

**Not Recommended:**

```systemverilog
// Variable definition:
logic enable, completed, in_progress;

// Statements:
if (enable == 0) in_progress = 1; else in_progress = 0;
```

### 1.3 Guideline: Use a begin-end pair to bracket conditional statements

This helps make it clear where the conditional code begins and where it ends. Without a begin-end pair, only the first line after the conditional statement is executed conditionally and this is a common source of errors.

**Recommended:**

```systemverilog
// Both statements executed conditionally:
if (i > 0) begin
  count = current_count;
  target = current_target;
end
```

**Not Recommended:**

```systemverilog
if (i > 0)
  count = current_count;
  target = current_target; // This statement is executed unconditionally
```

### 1.4 Guideline: Use parenthesis in Boolean conditions

This makes the code easier to read and avoids mistakes due to operator precedence issues.

**Recommended:**

```systemverilog
// Boolean or conditional expression
if ((A == B) && (B > (C * 2)) || (B > ((D ** 2) + 1))) begin
  ...
end
```

**Not Recommended:**

```systemverilog
// Boolean or conditional expression
if (A == B && B > C * 2 || B > D ** 2 + 1) begin
  ...
end
```

### 1.5 Guideline: Keep your code simple

Avoid writing tricky and hard to understand code, keep it simple so that it is clear what it does and how so that others can quickly understand it in case a modification is required.

### 1.6 Guideline: Keep your lines to a reasonable length

Long lines are difficult to read and understand, especially if you need to scroll the editor to the right to read the end of the line. As a guideline, keep your line length to around 80 characters, break the line and indent at logical places.

**Recommended:**

```systemverilog
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  mbus_seq_item rhs_;

  if (!$cast(rhs_, rhs)) begin
    `uvm_error("do_compare", "cast failed, check type compatibility")
    return 0;
  end

  do_compare = super.do_compare(rhs, comparer) &&
               (MADDR == rhs_.MADDR) &&
               (MWDATA == rhs_.MWDATA) &&
               (MREAD == rhs_.MREAD) &&
               (MOPCODE == rhs_.MOPCODE) &&
               (MPHASE == rhs_.MPHASE) &&
               (MRESP == rhs_.MRESP) &&
               (MRDATA == rhs_.MRDATA);
endfunction: do_compare
```

**Not Recommended:**

```systemverilog
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  mbus_seq_item rhs_;

  if (!$cast(rhs_, rhs)) begin
    `uvm_error("do_compare", "cast failed, check type compatibility")
    return 0;
  end

  do_compare = super.do_compare(rhs, comparer) && (MADDR == rhs_.MADDR) && (MWDATA == rhs_.MWDATA) && (MREAD == rhs_.MREAD) && (MOPCODE == rhs_.MOPCODE) && (MPHASE == rhs_.MPHASE) && (MRESP == rhs_.MRESP) && (MRDATA == rhs_.MRDATA);
endfunction: do_compare
```

### 1.7 Guideline: Use lowercase for names, using underscores to separate fields

This makes it clearer what the name is, as opposed to other naming styles such as CamelCase which are harder to read.

**Recommended:**

```
axi_fabric_scoreboard_error
```

**Not Recommended:**

```
AxiFabricScoreboardError
```

### 1.8 Guideline: Use prefix_ and _postfix to delineate name types

Use prefixes and postfixes for name types to help differentiate between variables. Pre and post fixes for some common variable types are summarized in the following table:

| Prefix/Postfix | Purpose |
|---|---|
| `_t` | Used for a type created via a typedef |
| `_e` | Used to indicate an enumerated type |
| `_h` | Used for a class handle |
| `_m` | Used for a protected class member (See guideline 2.2) |
| `_cfg` | Used for a configuration object handle |
| `_ap` | Used for an analysis port handle |
| `_group` | Used for a covergroup handle |

### 1.9 Guideline: Use a descriptive typedef when declaring a variable instead of a built-in type

This makes the code clearer and easier to understand as well as easier to maintain. An exception is when the built-in type keyword best describes the purpose of the variable's type.

```systemverilog
// Descriptive typedef for a 24 bit audio sample:
typedef bit [23:0] audio_sample_t;
```

### 1.10 Guideline: Use the end label for classes, functions, tasks, and packages

This forces the compiler to check that the name of the item matches the end label which can trap cut and paste errors. It is also useful to a person reading the code.

```systemverilog
// Using end labels
package my_pkg;

  //...
  class my_class;

    // ...
    function void my_function();
      //...
    endfunction: my_function

    task my_task;
      // ...
    endtask: my_task

  endclass: my_class

endpackage: my_pkg
```

### 1.11 Guideline: Comment the intent of your code

Add comments to define the intent of your code, don't rely on the users interpretation. For instance, each method in a class should have a comment block that specifies its input arguments, its function and its return arguments.

This principle can be extended to automatically generate html documentation for your code using documentation tools such as Natural Docs.

---

## Class Names and Members

### 2.1 Guideline: Name classes after the functionality they encapsulate

Use classes to encapsulate related functionality. Name the class after the functionality, for instance a scoreboard for an Ethernet router would be named `router_scoreboard`.

### 2.2 Guideline: Private class members should have a m_ prefix

Any member that is meant to be private should be named with a `m_` prefix, and should be made `local` or `protected`. Any member that will be randomized should not be local or protected.

### 2.3 Guideline: Declare class methods using extern

This means that the class body contains the method prototypes and so users only have to look at this section of the class definition to understand its functionality.

```systemverilog
// Descriptive typedefs:
typedef logic [31:0] raw_sample_t;
typedef logic [15:0] processed_sample_t;

// Class definition illustrating the use of externally defined methods:
class audio_compress;

  rand int iteration_limit;
  rand bit valid;
  rand raw_sample_t raw_audio_sample;
  rand processed_sample_t processed_sample;

  // function: new
  // Constructor - initializes valid
  extern function new();

  // function: compress_sample
  // Applies compression algorithm to raw sample
  // inputs: none
  // returns: void
  extern function void compress_sample();

  // function: set_new_sample
  // Set a new raw sample value
  // inputs:
  //   raw_sample_t new_sample
  // returns: void
  extern function void set_new_sample(raw_sample_t new_sample);

endclass: audio_compress

function audio_compress::new();
  valid = 0;
  iteration_limit = $bits(processed_sample_t);
endfunction

function void audio_compress::compress_sample();
  for (int i = 0; i < iteration_limit; i++) begin
    processed_sample[i] = raw_audio_sample[((i*2)-1):(i*2)];
  end
  valid = 1;
endfunction: compress_sample

function void audio_compress::set_new_sample(raw_sample_t new_sample);
  raw_audio_sample = new_sample;
  valid = 0;
endfunction: set_new_sample
```

---

## Files and Directories

The following guidelines concern best practices for SystemVerilog files and directories.

### File Naming

#### 3.1 Guideline: Use lower case for file and directory names

Lower case names are easier to type.

#### 3.2 Guideline: Use .sv extensions for compile files, .svh for `include files

The convention of using the `.sv` extension for files that are compiled and `.svh` for files that get included makes it easier to sort through files in a directory and also to write compilation scripts.

For instance, a package definition would have a `.sv` extension, but would reference `` `included `` `.svh` files.

#### 3.3 Guideline: `include .svh class files should only contain one class and be named after that class

This makes it easier to maintain the code, since it is obvious where the code is for each class.

#### 3.4 Guideline: Use descriptive names that reflect functionality

File names should match their content. The names should be descriptive and use postfixes to help describe the intent - e.g. `_pkg`, `_env`, `_agent`, etc.

### `include versus import

#### 3.5 Rule: Only use `include to include a file in one place

The `` `include `` construct should only be used to include a file in just one place. `` `include `` is typically used to include `.svh` files when creating a package file.

If you need to reference a type or other definition, then use `import` to bring the definition into scope. Do not use `` `include ``. The reason for this is that type definitions are scope specific.

A type defined in two scopes using the same `` `include `` file are not recognized as being the same. If the type is defined in one place, inside a package, then it can be properly referenced by importing that package.

An exception to this would be a macro definition file such as the `uvm_macros.svh` file.

### Directory Names

Testbenches are constructed of SystemVerilog UVM code organized as packages, collections of verification IP organized as packages and a description of the hardware to be tested. Other files such as C models and documentation may also be required. Packages should be organized in a hierarchy.

#### 3.6 Guideline: Each package should have its own directory

Each package should exist in its own directory. Each of these package directories should have one file that gets compiled - a file with the extension `.sv`

Each package should have at most one file that may be included in other code. This file may define macros.

```
abc_pkg.sv
abc_macros.svh
```

For a complex package (such as a UVC) that may contain tests, examples and documentation, create subdirectories:

```
abc_pkg/examples
abc_pkg/docs
abc_pkg/tests
abc_pkg/src/abc_pkg.sv
```

For a simple package the subdirectories may be omitted:

```
abc_pkg/abc_pkg.sv
```

#### Sample File Listing

```
./abc_pkg/src
./abc_pkg/src/abc_pkg.sv

./abc_pkg/src/abc_macros.svh

./abc_pkg/src/abc_env.svh
./abc_pkg/src/abc_interface.sv

./abc_pkg/src/abc_driver.svh
./abc_pkg/src/abc_monitor.svh
./abc_pkg/src/abc_scoreboard.svh

./abc_pkg/src/abc_sequence_item.svh
./abc_pkg/src/abc_sequencer.svh
./abc_pkg/src/abc_sequences.svh

./abc_pkg/docs/
./abc_pkg/docs/abc_user_guide.docx

./abc_pkg/tests/
./abc_pkg/tests/......

./abc_pkg/examples/
./abc_pkg/examples/a/....
./abc_pkg/examples/b/....
./abc_pkg/examples/c/....

./testbench1/makefile
./testbench1/tb_env.sv
./testbench1/tb_top.sv
./testbench1/test.sv
```

### Using Packages

#### 3.7 Rule: Import packages to reference their contents

When you use a function or a class from a package, you import it, and `` `include `` any macro definitions.

If you `` `include `` the package source, then you will be creating a new namespace for that package in every file that you `` `include `` it into, this will result in type matching issues.

```systemverilog
import abc_pkg::*;
`include "abc_macros.svh"
```

#### 3.8 Rule: When compiling a package, use +incdir+ to reference its source directory

To compile the package itself, you use a `+incdir` to reference the source directory. Make sure that there are no hard coded paths in the path string for the `` `included `` file.

```
vlog +incdir+$ABC_PKG/src abc_pkg.sv
```

To compile code that uses the package, you also use a `+incdir` to reference the source directory if a macro file needs to be `` `included ``.

```
vlog +incdir+$ABC_PKG/src tb_top.sv
```

To compile the packages, and the testbench for the example:

```bash
vlib work

# Compile the Questa UVM Package (for UVM Debug integration)
vlog +incdir+$QUESTA_UVM_HOME/src \
  $QUESTA_UVM_HOME/src/questa_uvm_pkg.sv

# Compile the VIP (abc and xyz)
vlog +incdir+../abc_pkg/src \
  ../abc_pkg/src/abc_pkg.sv
vlog +incdir+../xyz_pkg/src \
  ../xyz_pkg/src/xyz_pkg.sv

# Compile the DUT (RTL)
vlog ../dut/dut.sv

# Compile the test
vlog +incdir+../test_pkg/src \
  ../test_pkg/src/test_pkg.sv

# Compile the top
vlog tb_top.sv

# Simulate
vsim -uvm=debug -coverage +UVM_TESTNAME=test \
  -c tb_top -do "run -all; quit -f"
```

---

## SystemVerilog Language Guidelines

### 4.1 Rule: Check that $cast() has succeeded

If you are going to use the result of the cast operation, then you should check the status returned by the `$cast` call and deal with it gracefully, otherwise the simulation may crash with a null pointer.

Note that it is not enough to check the result of the cast method, you should also check that the handle to which the cast is made is not null. A cast operation will succeed if the handle from which the cast is being done is null.

```systemverilog
// How to check that a $cast has worked correctly
function my_object get_a_clone(uvm_object to_be_cloned);
  my_object t;

  if (!$cast(t, to_be_cloned.clone())) begin
    `uvm_error("get_a_clone", "$cast failed for to_be_cloned")
  end
  if (t == null) begin
    `uvm_fatal("get_a_clone",
      "$cast operation resulted in a null handle, check to_be_cloned handle")
  end

  return t;
endfunction: get_a_clone
```

### 4.2 Rule: Check that randomize() has succeeded

If no check is made the randomization may be failing, meaning that the stimulus generation is not working correctly.

```systemverilog
// Using if() to check randomization result
if (!seq_item.randomize() with {
  address inside {[0:32'hF000_FC00]};
}) begin
  `uvm_error("seq_name", "randomization failure, please check constraints")
end
```

### 4.3 Rule: Use if rather than assert to check the status of method calls

Assert results in the code check appearing in the coverage database, which is undesired. Incorrectly turning off the action blocks of assertions may also produce undesired results.

### Constructs to be Avoided

The SystemVerilog language has been a collaborative effort with a long history of constructs borrowed from other languages. Some constructs have been improved upon with newer constructs, but the old constructs remain for backward compatibility and should be avoided. Other constructs were added before being proven out and in practice cause more problems than they solve.

#### 4.4 Rule: Do not place any code in $unit, place it in a package

The compilation unit, `$unit`, is the scope outside of a design element (package, module, interface, program). There are a number of problems with timescales, visibility, and re-usability when you place code in `$unit`. Always place this code in a package.

#### 4.5 Guideline: Do not use associative arrays with a wildcard index [*]

A wildcard index on an associative array is an un-sized integral index. SystemVerilog places severe restrictions on other constructs that cannot be used with associative arrays having a wildcard index. In most cases, an index type of `[int]` is sufficient. For example, a `foreach` loop requires a fixed type to declare its iterator variable.

```systemverilog
string names[*];   // cannot be used with foreach, find_index, ...
string names[int];
...
foreach (names[i])
  $display("element %0d: %s", i, names[i]);
```

#### 4.6 Guideline: Do not use #0 procedural delays

Using a `#0` procedural delay, sometimes called a delta delay, is a sure sign that you have coded incorrectly. Adding a `#0` just to get your code working usually avoids one race condition and creates another one later. Often, using a non-blocking assignment (`<=`) solves this class of problem.

#### 4.7 Guideline: Avoid the use of the following language constructs

A number of SystemVerilog language constructs should be avoided altogether:

| Construct | Reason to avoid |
|---|---|
| `checker` | Ill defined, not supported by Questa |
| `final` | Only gets called when a simulation completes |
| `program` | Legacy from Vera, alters timing of sampling, not necessary and potentially confusing |

### Coding Patterns

Some pieces of code fall into well recognized patterns that are known to cause problems.

#### 4.8 Rule: Do not rely on static variable initialization order, initialize on first instance

The ordering of static variable initialization is undefined. If one static variable initialization requires the non-default initialized value of another static variable, this is a race condition. This can be avoided by creating a static function that initializes the variable on the first reference, then returns the value of the static variable, instead of directly referencing the variable.

```systemverilog
typedef class A;
typedef class B;

A a_top = A::get_a();
B b_top = B::get_b();

class A;
  static function A get_a();
    if (a_top == null) a_top = new();
    return a_h;
  endfunction
endclass: A

class B;
  A a_h;
  protected function new;
    a_h = get_a();
  endfunction
  static function B get_b();
    if (b_top == null) b_top = new();
    return b_top;
  endfunction
endclass: B
```

---

## Covergroups

### 4.9 Guideline: Create covergroups within wrapper classes

Covergroups have to be constructed within the constructor of a class. In order to make the inclusion of a covergroup within a testbench conditional, it should be wrapped within a wrapper class.

### 4.10 Guideline: Covergroup sampling should be conditional

Build your covergroups so that their sample can be turned on or off. For example use the `iff` clause of covergroups.

```systemverilog
// Wrapped covergroup with sample control:
class cg_wrapper extends uvm_component;

  logic [31:0] address;
  bit coverage_enabled;

  covergroup detail_group;
    ADDRESS: coverpoint addr iff (coverage_enabled) {
      bins low_range  = {[0:32'h0000_FFFF]};
      bins med_range  = {[32'h0001_0000:32'h0200_FFFF]};
      bins high_range = {[32'h0201_0000:32'h0220_FFFF]};
    }
    // ....
  endgroup: detail_group

  function new(string name = "cg_wrapper", uvm_component parent = null);
    super.new(name, parent);
    // Construct covergroup and enable sampling
    detail_group = new();
    coverage_enabled = 1;
  endfunction

  // Set coverage enable bit - allowing coverage to be enabled/disabled
  function void set_coverage_enabled(bit enable);
    coverage_enabled = enable;
  endfunction: set_coverage_enabled

  // Get current state of coverage enabled bit
  function bit get_coverage_enabled();
    return coverage_enabled;
  endfunction: get_coverage_enabled

  // Sample the coverage group:
  function void sample(logic [31:0] new_address);
    address = new_address;
    detail_group.sample();
  endfunction: sample

endclass: cg_wrapper
```

Coverpoint sampling may not be valid in certain situations, for instance during reset.

```systemverilog
// Using iff to turn off unnecessary sampling:

// Only sample if reset is not active
coverpoint data iff (reset_n != 0) {
  // Only interested in high_end values if high pass is enabled:
  bins high_end = {[10000:20000]} iff (high_pass);
  bins low_end  = {[1:300]};
}
```

---

## Collecting Coverage

### 4.11 Guideline: Use the covergroup sample() method to collect coverage

Sample a covergroup by calling the `sample()` routine, this allows precise control on when the sampling takes place.

### 4.12 Rule: Label coverpoints and crosses

Labelling coverpoints allows them to be referenced in crosses and easily identified in reports and viewers.

```systemverilog
payload_size_cvpt: coverpoint ...
```

Labelling crosses allows them to be easily identified.

```systemverilog
payload_size_X_parity: cross payload_size_cvpt, parity;
```

### 4.13 Guideline: Name your bins

Name your bins, do not rely on auto-naming.

```systemverilog
bin minimum_val = {min};
```

### 4.14 Guideline: Minimize the size of the sample

It is very easy to specify large numbers of bins in covergroups through auto generation without realizing it. You can minimise the impact of a covergroup on simulation performance by thinking carefully about the number and size of the bins required, and by reducing the cross bins to only those required.
