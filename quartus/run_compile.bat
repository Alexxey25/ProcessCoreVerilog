@echo off
REM Быстрая полная компиляция top_cpu (Quartus Prime 25.1)
REM Запуск: двойной щелчок или из cmd из папки quartus\

setlocal
cd /d "%~dp0top_cpu_quartus"

set QSH=
if exist "C:\intelFPGA_lite\25.1\quartus\bin64\quartus_sh.exe" set QSH=C:\intelFPGA_lite\25.1\quartus\bin64\quartus_sh.exe
if exist "C:\intelFPGA\25.1\quartus\bin64\quartus_sh.exe" set QSH=C:\intelFPGA\25.1\quartus\bin64\quartus_sh.exe

if "%QSH%"=="" (
    echo Quartus 25.1 not found. Install Lite or edit path in run_compile.bat
    exit /b 1
)

echo === Compiling top_cpu_quartus ===
"%QSH%" --flow compile top_cpu_quartus
if errorlevel 1 (
    echo FAILED
    exit /b 1
)

echo.
echo === Reports ===
echo   Resources: output_files\top_cpu_quartus.fit.summary
echo   Timing:    output_files\top_cpu_quartus.sta.summary
echo   Fmax:      output_files\top_cpu_quartus.sta.rpt  (search Fmax Summary)
echo.
type output_files\top_cpu_quartus.fit.summary
echo.
type output_files\top_cpu_quartus.sta.summary
endlocal
