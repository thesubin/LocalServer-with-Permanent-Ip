@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------   
@echo off
set "ip="
for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get DefaultIPGateway /value | find "I" "') do if not defined ip set ip=%%~a

for /f "tokens=2,* delims=:" %%A in ('ipconfig ^| find "Subnet"') do set subnet=%%A
set subnet=%subnet:~1%

echo "Please enter Static IP Address Information"
echo "Static IP Address:"
set IP_Addr="192.168.1.111"

echo "Default Gateway:"
set  D_Gate= %ip%
echo %D_Gate%
echo "Subnet Mask:" 
set Sub_Mask=%subnet%
echo %Sub_Mask%
FOR /F "tokens=3,*" %%A IN ('netsh interface show interface^|find "Connected"') DO netsh interface ip set address %%B static %IP_Addr% %Sub_Mask% %D_Gate% 1
FOR /F "tokens=3,*" %%A IN ('netsh interface show interface^|find "Connected"') DO netsh interface ipv4 set dns name=%%B static 8.8.8.8

echo "Setting Static IP Information"
netsh int ip show config
pause
:end