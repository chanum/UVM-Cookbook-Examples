@echo off
REM===============================================================================
REM UVM Test Runner - Interactive test selection for QuestaSim (Windows)
REM 
REM Usage: run_test.bat [testbench [testcase]]
REM   If no arguments, shows interactive menu
REM===============================================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "TB_ROOT=%SCRIPT_DIR%src\tb"

set "RED=[0;31m"
set "GREEN=[0;32m"
set "YELLOW=[1;33m"
set "BLUE=[0;34m"
set "NC=[0m"

REM Check if vsim is available
where vsim >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: vsim not found in PATH
    echo Please ensure QuestaSim is installed and in your PATH
    exit /b 1
)

REM Function to list testcases
:list_testcases
set "TB_PATH=%~1"
set "TEST_DIR=%TB_PATH%\test"

if not exist "%TEST_DIR%" (
    echo No test directory found
    exit /b 1
)

echo Available testcases:
echo.

set /a count=1
set "testcases="

for %%f in ("%TEST_DIR%\*_test.svh") do (
    set "test_name=%%~nf"
    echo   [!count!] !test_name!
    set "testcases=!testcases! !test_name!"
    set /a count+=1
)

if "%testcases%"=="" (
    echo No testcases found!
    exit /b 1
)

echo.
set /p selection="Select testcase: "

REM Run the selected test
goto run_selected_test

REM Function to run test
:run_test
set "TB_PATH=%~1"
set "TEST_NAME=%~2"
set "SIM_DIR=%TB_PATH%\sim"

if not exist "%SIM_DIR%" (
    echo No sim directory found
    exit /b 1
)

echo Running test: %TEST_NAME%
echo.

cd /d "%SIM_DIR%"

if exist "Makefile" (
    set TEST=%TEST_NAME%
    make run
) else if exist "sim.do" (
    vsim -c -do "do sim.do; set TEST %TEST_NAME%; run -all; quit -f" +UVM_TESTNAME=%TEST_NAME%
) else (
    echo No Makefile or sim.do found
    exit /b 1
)

exit /b 0

REM Function to show testbench menu
:show_testbench_menu
echo ======================================
echo   UVM Test Runner - Select Testbench
echo ======================================
echo.

set /a count=1
set "testbenches="

for /d %%d in ("%TB_ROOT%\block_level_tbs\*") do (
    set "tb_name=%%~nd"
    echo   [!count!] !tb_name!
    set "testbenches=!testbenches! %%d"
    set /a count+=1
)

for /d %%d in ("%TB_ROOT%\sub_system_tbs\*") do (
    set "tb_name=%%~nd"
    echo   [!count!] !tb_name!
    set "testbenches=!testbenches! %%d"
    set /a count+=1
)

echo.
set /p selection="Select testbench: "

if "%selection%"=="" exit /b 1

REM Show testcase menu for selected testbench
:show_testcase_menu
echo.
echo ======================================
echo   Testbench: %1
echo ======================================
echo.

set "TB_PATH=%~1"
set "TEST_DIR=%TB_PATH%\test"

set /a count=1
set "testcases="

for %%f in ("%TEST_DIR%\*_test.svh") do (
    set "test_name=%%~nf"
    echo   [!count!] !test_name!
    set "testcases=!testcases! !test_name!"
    set /a count+=1
)

if "%testcases%"=="" (
    echo No testcases found!
    exit /b 1
)

echo.
set /p selection="Select testcase: "

if "%selection%"=="" exit /b 1

REM Run the selected test
set /a idx=0
for %%t in %testcases% do (
    set /a idx+=1
    if !idx!==%selection% (
        call :run_test "%TB_PATH%" "%%t"
        exit /b !errorlevel!
    )
)

echo Invalid selection!
exit /b 1

REM Main
:main
if "%~1"=="" (
    call :show_testbench_menu
    exit /b %errorlevel%
)

set "TB_NAME=%~1"
set "TB_PATH="

if exist "%TB_ROOT%\block_level_tbs\%TB_NAME%" (
    set "TB_PATH=%TB_ROOT%\block_level_tbs\%TB_NAME%"
) else if exist "%TB_ROOT%\sub_system_tbs\%TB_NAME%" (
    set "TB_PATH=%TB_ROOT%\sub_system_tbs\%TB_NAME%"
) else (
    echo Testbench not found: %TB_NAME%
    echo.
    echo Available testbenches:
    for /d %%d in ("%TB_ROOT%\block_level_tbs\*") do echo   - %%~nd
    for /d %%d in ("%TB_ROOT%\sub_system_tbs\*") do echo   - %%~nd
    exit /b 1
)

if not "%~2"=="" (
    call :run_test "%TB_PATH%" "%~2"
) else (
    call :show_testcase_menu "%TB_PATH%"
)

exit /b %errorlevel%

:main
call :main %*
