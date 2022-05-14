
set arg1=%1
set arg2=%2
echo %arg1%, %arg2%
set DIRECTORY=%arg1%

%arg1%\plink -telnet %arg2% < %arg1%\commands.txt