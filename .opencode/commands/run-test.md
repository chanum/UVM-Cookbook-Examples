---
description: Run QuestaSim UVM test (batch mode)
arg: testbench [testcase]
---

Run UVM test with QuestaSim in batch mode using sim.do.

The testbench is "$1" and testcase is "$2".

First, find the testbench path:
!`TB="$1"; for dir in src/tb/block_level_tbs/$TB src/tb/sub_system_tbs/$TB; do [ -d "$dir" ] && echo "$dir" && break; done`

If no testcase is provided ("$2" is empty), list available testcases:
!`TB_PATH=$(for dir in src/tb/block_level_tbs/$1 src/tb/sub_system_tbs/$1; do [ -d "$dir" ] && echo "$dir" && break; done); if [ -d "$TB_PATH/test" ]; then ls -1 "$TB_PATH/test/"*_test.svh 2>/dev/null | xargs -n1 basename | sed 's/.svh$//' || echo "No testcases found"; fi`

Run the simulation using sim.do:
!`TB_PATH=$(for dir in src/tb/block_level_tbs/$1 src/tb/sub_system_tbs/$1; do [ -d "$dir" ] && echo "$dir" && break; done); SIM_DIR="$TB_PATH/sim"; if [ -d "$SIM_DIR" ] && [ -f "$SIM_DIR/sim.do" ]; then cd "$SIM_DIR" && vsim -c -do "do sim.do" +UVM_TESTNAME=$2 2>&1; else echo "No sim.do found in $SIM_DIR"; fi`

Report the simulation results including:
- UVM test status (PASSED/FAILED)
- Any UVM warnings or errors
- Test execution time
