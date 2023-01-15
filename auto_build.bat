:: github.com/Kinuseka
@ECHO off

:: Define Binaries
set goRC=".\binary\GoRC\GoRC.exe"
set wget=".\binary\Wget\wget.exe"
set ResHacker=".\binary\ResourceHacker\ResourceHacker.exe"
set python_path="python"
set Cpython_path="Python"

:: File Location
set F_PlinkLocation=".\binary\plink"
set F_FullPlinkLocation=".\binary\plink\plink.exe"
call :GETARCHITECTURE

:: Static Values
set V_FileName=HIC_%OS%.exe
set V_RequirementLink="https://raw.githubusercontent.com/brentvollebregt/auto-py-to-exe/master/requirements.txt"
set V_Plink64="https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe"
set V_Plink32="https://the.earth.li/~sgtatham/putty/latest/w32/plink.exe"
set V_Plinkarm64="https://the.earth.li/~sgtatham/putty/latest/wa64/plink.exe"

:: Binary Resources
set B_Name=start_execution.exe
set B_BinOut=.\dist\
:: ===
set B_ComResource=.\Resources\Resources.res

:: Files Requirement
set B_IcoRes=."/Resources/Huawei.ico"
set File_Plink="./binary/plink/plink.exe;."
set File_Script="./src/setimei.vbs;."
set File_Wrapper="./src/wrapper.bat;."
set File_MainSRC="./src/start_execution.py"




if exist binary\ (
  if not exist %goRC% ( goto :STARTUPFAIL )
  if not exist %wget% ( goto :STARTUPFAIL )
  if not exist %ResHacker% ( goto :STARTUPFAIL )
  if not exist %F_PlinkLocation% ( mkdir ".\binary\plink" )
) else (
  echo binary folder not found
  goto :STARTUPFAIL
)

echo Downloading 1 required binary
call :INITPLINK
IF %ERRORLEVEL% NEQ 0 ( 
   pause
   goto :EOF
)
call :DOES_PYTHON_EXIST
IF %ERRORLEVEL% NEQ 0 ( 
   pause
   goto :EOF
)

echo Getting requirements
%wget% -qO- %V_RequirementLink% > requirements.txt

echo Compiling resources

%goRC% /fo Resources\Resources.res Resources\Resources.rc

echo installing requirements

%python_path% -m pip install -r requirements.txt

python3 -m PyInstaller --noconfirm --onefile --windowed --icon %B_IcoRes% --add-data %File_Plink% --add-data %File_Script% --add-data %File_Wrapper%  %File_MainSRC%
IF %ERRORLEVEL% NEQ 0 (
   pause
   goto :EOF
)

call :BINARYRENAME

IF %ERRORLEVEL% NEQ 0 (
   pause
   goto :EOF
)

echo Building successful

PowerShell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('ATTENTION USER!!!! THE APP MAY GET REPORTED AS A MALWARE, THIS IS A FALSE POSITIVE. REST ASSURED THERE ARE NO MALWARES IN THIS PROGRAM. THANKS FOR TRUSTING! -Kinuseka')"
IF %ERRORLEVEL% NEQ 0 (
   echo No powershell/window support reverting to cli 
   echo -------
   echo ATTENTION USER!!! THE APP MAY GET REPORTED AS A MALWARE, THIS IS A FALSE POSITIVE. 
   echo REST ASSURED THERE ARE NO MALWARES IN THIS PROGRAM. THANKS FOR TRUSTING! 
   echo -Kinuseka
   echo -------
)

pause
goto :EOF

:: ================

:GETARCHITECTURE
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64

EXIT /B 

:INITPLINK
echo Downloading PLINK
if %OS% == x64 ( call :PLINK64 )
if %OS% == x86 ( call :PLINK32 )

EXIT /B %ERRORLEVEL%

:PLINK64 
%wget% %V_Plink64% -c -P %F_PlinkLocation%

EXIT /B %ERRORLEVEL%

:PLINK32
%wget% %V_Plink32% -c -P %F_PlinkLocation%

EXIT /B %ERRORLEVEL%


:BUILDFAILED
echo Build Failed 

:STARTUPFAIL
echo Some file requirements are not found. Please reclone the repository and try again
pause
goto :EOF 1


:BINARYRENAME
echo Rebuilding app with Resources

%ResHacker% -open "%B_BinOut%%B_Name%" -save "%B_BinOut%%V_FileName%" -action addoverwrite -resource %B_ComResource%

echo Removing old binary file 

del "%B_BinOut%%B_Name%"


IF %ERRORLEVEL% NEQ 0 (
    echo Delete error: Binary file not found
)

EXIT /B 


:DOES_PYTHON_EXIST
%python_path% -V | find /v %Cpython_path% >NUL 2>NUL && (call :PYTHON_DOES_NOT_EXIST)
%python_path% -V | find %Cpython_path%    >NUL 2>NUL && (call :PYTHON_DOES_EXIST)
EXIT /B 

:PYTHON_DOES_NOT_EXIST
echo Python is not installed on your system.
echo Opening the download URL in 3seconds.
PING localhost -n 3 >NUL
start "" "https://www.python.org/downloads/windows/"
EXIT /B 1

:PYTHON_DOES_EXIST
:: This will retrieve Python 3.8.0 for example.
for /f "delims=" %%V in ('%python_path% -V') do @set ver=%%V
echo Congrats, %ver% is installed...
EXIT /B 0
:: github.com/Kinuseka
