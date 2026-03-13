#!/bin/bash

#===============================================================================
# UVM Test Runner - Interactive test selection for QuestaSim
# 
# Usage: ./run_test.sh [testbench]
#   If testbench is not provided, shows testbench selection menu
#===============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TB_ROOT="$SCRIPT_DIR/src/tb"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to list testcases in a testbench
list_testcases() {
    local tb_path="$1"
    local test_dir="$tb_path/test"
    
    if [ ! -d "$test_dir" ]; then
        echo -e "${RED}No test directory found in $tb_path${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Available testcases:${NC}"
    echo ""
    
    local count=1
    local testcases=()
    
    # Find all test files (*_test.svh)
    for test_file in "$test_dir"/*_test.svh; do
        if [ -f "$test_file" ]; then
            local test_name=$(basename "$test_file" .svh)
            echo "  [$count] $test_name"
            testcases+=("$test_name")
            ((count++))
        fi
    done
    
    if [ ${#testcases[@]} -eq 0 ]; then
        echo -e "${RED}No testcases found!${NC}"
        return 1
    fi
    
    echo ""
    local num_tests=${#testcases[@]}
    echo -e "${YELLOW}Select testcase [1-$num_tests]: ${NC}"
    
    return 0
}

# Function to get testcases as array
get_testcases() {
    local tb_path="$1"
    local test_dir="$tb_path/test"
    local testcases=()
    
    for test_file in "$test_dir"/*_test.svh; do
        if [ -f "$test_file" ]; then
            testcases+=($(basename "$test_file" .svh))
        fi
    done
    
    echo "${testcases[@]}"
}

# Function to run test
run_test() {
    local tb_path="$1"
    local test_name="$2"
    local sim_dir="$tb_path/sim"
    
    if [ ! -d "$sim_dir" ]; then
        echo -e "${RED}No sim directory found in $tb_path${NC}"
        return 1
    fi
    
    # Check if Makefile exists
    if [ -f "$sim_dir/Makefile" ]; then
        echo -e "${GREEN}Running test: $test_name using Makefile...${NC}"
        echo ""
        cd "$sim_dir"
        TEST="$test_name" make run
    # Check if sim.do exists
    elif [ -f "$sim_dir/sim.do" ]; then
        echo -e "${GREEN}Running test: $test_name using sim.do...${NC}"
        echo ""
        cd "$sim_dir"
        
        # Check if vsim is available
        if ! command -v vsim &> /dev/null; then
            echo -e "${RED}Error: vsim not found in PATH${NC}"
            echo "Please ensure QuestaSim is installed and in your PATH"
            return 1
        fi
        
        vsim -c -do "do sim.do; set TEST $test_name; run -all; quit -f" +UVM_TESTNAME="$test_name"
    else
        echo -e "${RED}No Makefile or sim.do found in $sim_dir${NC}"
        return 1
    fi
}

# Function to show testbench menu
show_testbench_menu() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}  UVM Test Runner - Select Testbench${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    
    local count=1
    local testbenches=()
    
    # Block level testbenches
    for tb_dir in "$TB_ROOT/block_level_tbs"/*; do
        if [ -d "$tb_dir" ]; then
            local tb_name=$(basename "$tb_dir")
            echo "  [$count] $tb_name"
            testbenches+=("$tb_dir")
            ((count++))
        fi
    done
    
    # Sub-system testbenches
    for tb_dir in "$TB_ROOT/sub_system_tbs"/*; do
        if [ -d "$tb_dir" ]; then
            local tb_name=$(basename "$tb_dir")
            echo "  [$count] $tb_name"
            testbenches+=("$tb_dir")
            ((count++))
        fi
    done
    
    echo ""
    local num_tbs=${#testbenches[@]}
    echo -e "${YELLOW}Select testbench [1-$num_tbs]: ${NC}"
    
    # Read selection
    local selection
    read -r selection
    
    # Validate selection
    local num_tbs=${#testbenches[@]}
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $num_tbs ]; then
        echo -e "${RED}Invalid selection!${NC}"
        return 1
    fi
    
    local selected_tb="${testbenches[$((selection-1))]}"
    show_testcase_menu "$selected_tb"
}

# Function to show testcase menu
show_testcase_menu() {
    local tb_path="$1"
    local tb_name=$(basename "$tb_path")
    local test_dir="$tb_path/test"
    
    echo ""
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}  Testbench: $tb_name${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    
    # Get testcases
    local testcases=()
    for test_file in "$test_dir"/*_test.svh; do
        if [ -f "$test_file" ]; then
            testcases+=($(basename "$test_file" .svh))
        fi
    done
    
    if [ ${#testcases[@]} -eq 0 ]; then
        echo -e "${RED}No testcases found!${NC}"
        return 1
    fi
    
    # Display testcases
    local count=1
    for test in "${testcases[@]}"; do
        echo "  [$count] $test"
        ((count++))
    done
    
    echo ""
    local num_tests=${#testcases[@]}
    echo -e "${YELLOW}Select testcase [1-$num_tests]: ${NC}"
    
    # Read selection
    local selection
    read -r selection
    
    # Validate selection
    local num_tests=${#testcases[@]}
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $num_tests ]; then
        echo -e "${RED}Invalid selection!${NC}"
        return 1
    fi
    
    local selected_test="${testcases[$((selection-1))]}"
    
    echo ""
    run_test "$tb_path" "$selected_test"
}

# Main
main() {
    # Check for testbench argument
    if [ $# -eq 0 ]; then
        # Show interactive menu
        show_testbench_menu
    else
        # Use provided testbench and show its testcases
        local tb_name="$1"
        local tb_path=""
        
        # Search in block_level_tbs
        if [ -d "$TB_ROOT/block_level_tbs/$tb_name" ]; then
            tb_path="$TB_ROOT/block_level_tbs/$tb_name"
        # Search in sub_system_tbs
        elif [ -d "$TB_ROOT/sub_system_tbs/$tb_name" ]; then
            tb_path="$TB_ROOT/sub_system_tbs/$tb_name"
        else
            echo -e "${RED}Testbench not found: $tb_name${NC}"
            echo ""
            echo "Available testbenches:"
            for tb_dir in "$TB_ROOT/block_level_tbs"/*; do
                [ -d "$tb_dir" ] && echo "  - $(basename "$tb_dir")"
            done
            for tb_dir in "$TB_ROOT/sub_system_tbs"/*; do
                [ -d "$tb_dir" ] && echo "  - $(basename "$tb_dir")"
            done
            exit 1
        fi
        
        if [ $# -eq 2 ]; then
            # Run specific test
            run_test "$tb_path" "$2"
        else
            # Show testcase menu
            show_testcase_menu "$tb_path"
        fi
    fi
}

main "$@"
