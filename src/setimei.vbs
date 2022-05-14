' github.com/Kinuseka

Option explicit

Dim IPADDRESS
IPADDRESS = "192.168.8.1"

Dim Arg, DIRECTORY,objShell
Set Arg = WScript.Arguments

Dim WshShell, strCurDir, objFSO
Set WshShell = CreateObject("WScript.Shell")
Set objShell = WScript.CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

if Arg.Count > 0 then
    DIRECTORY = Arg(0)
end if 

Dim oShell
Dim diffShell
set oShell= CreateObject("WScript.Shell")

Dim UserIMEI

Dim DefaultValue
Dim result 
Dim X
X = 0
DefaultValue = "Default_user_value"
' Extended Utils
function CLonger(number)
    Dim i 
    For i=1 To Len(number)
        If NOT(IsNumeric(Mid(number,i,1))) Then
            CLonger = False   
            Exit For
        End If
        CLonger = True
    Next 
end function

function TestGateway(target)
    Dim shell, shellexec
    Set shell = WScript.CreateObject("WScript.Shell")

    Set shellexec = shell.Exec("ping -n 4 -w 1000 " & target ) 

    result = LCase(shellexec.StdOut.ReadAll)

    If InStr(result , "reply from") Then
        TestGateway = True  
    Else
        TestGateway = False 
    End If
end function

' Main processes
function Main()
    dim IPTEMP
    IPTEMP = InputBox("Enter your current local IP ","Huawei B315s-936, IMEI Changer Script", IPADDRESS)
    If IsEmpty(IPTEMP) Then
        result = msgbox("Are you sure you want to cancel?", 4 , "Select yes or no")
        If result=6 then
            Wscript.Quit
        end if
    else
        result = msgbox("Are you sure? "&IPTEMP, 4 , "Select yes or no")
            If result=6 then             
                if NOT(TestGateway(IPTEMP)) then
                    msgbox "Gateway could not be contacted! Please check if it is a valid IP address",48,"IP Could not be reached"
                else
                    IPADDRESS = IPTEMP
                    ImeiChange()
                end if
            end if
    end if
end function
function ImeiChange()
    Do While X = 0
        UserIMEI = InputBox("Enter a valid Imei ","Huawei B315s-936, IMEI Changer Script")
        If IsEmpty(UserIMEI) Then
            result = msgbox("Are you sure you want to cancel?", 4 , "Select yes or no")
            If result=6 then
                Wscript.Quit
            end if
        Else
            If UserIMEI = "" Then
                Wscript.Echo "You must enter an IMEI!!"
            else
                result = msgbox("Are you sure? "&UserIMEI, 4 , "Select yes or no")
                If result=6 then
                    If IsNumeric(UserIMEI) Then
                        ' IsNumeric adds exception to dots and commas due to the fact they are whole/floating point values. github.com/Kinuseka
                        ' Then the final goal is to check if the string has any characters at ALL. github.com/Kinuseka
                        If CLonger(UserIMEI) Then
                            If NOT Len(UserIMEI) = 15 then 
                                msgbox "Your input only contains: " & Len(UserIMEI) & " digits." & vbCrLf & "IMEI requires 15 digits",48,"Lacking digits"
                            else
                                ' MakeScript
                                ImeiCall
                                exit do
                            End If

                        Else
                            msgbox "Your input is invalid and contains characters",48,"Invalid characters found"
                        End If
                    else 
                        msgbox "Your input is not numerical",48,"Invalid input"
                    End If
                else
                    Wscript.Quit
                end if
            end if
        End If
    Loop
end function


function MakeScript(opt) 
    Dim CommandFull, Command2, Command3, outFile,objFile
    CommandFull = "atc AT^PHYNUM=IMEI,"& UserIMEI
    Command2 = "atc AT^INFORBU"
    Command3 = "atc AT^RESET" 
    outFile=DIRECTORY&"\commands.txt"
    Set objFile = objFSO.CreateTextFile(outFile,True)
    if opt = 1 then
        objFile.Write CommandFull & vbCrLf
        ' objFile.Write "ping -c 1 127.0.0.1 >NUL" & vbCrLf
    Elseif opt = 2 then
        objFile.Write Command2 & vbCrLf
        ' objFile.Write "ping -c 1 127.0.0.1 >NUL" & vbCrLf
    Elseif opt = 3 then
        objFile.Write Command3 & vbCrLf
        ' objFile.Write "ping -c 1 127.0.0.1 >NUL" & vbCrLf 
    End if
    objFile.Close


end function

function ImeiCall()
    Dim ApplicationSession
    Dim CommandFull, Command2, Command3, outFile,objFile
    Dim Full_dir
    CommandFull = "atc AT{^}PHYNUM=IMEI,"& UserIMEI
    Command2 = "atc AT{^}INFORBU"
    Command3 = "atc AT{^}RESET" 
    
    const DontWaitUntilFinished = false, ShowWindow = 1, DontShowWindow = 0, WaitUntilFinished = true
    ' oShell.Run """"&DIRECTORY&"\wrapper.bat""" & IPADDRESS & " " & DIRECTORY, DontShowWindow, WaitUntilFinished
    MakeScript(1)
    ApplicationSession = oShell.run(""""&DIRECTORY&"\wrapper.bat """ & """"&DIRECTORY&"""" & " " & IPADDRESS, DontShowWindow)
    objShell.Popup "Step 1 Finished", 1, "Stage 1/3", vbInformation
    MakeScript(2)
    ApplicationSession = oShell.run(""""&DIRECTORY&"\wrapper.bat """ & """"&DIRECTORY&"""" & " " & IPADDRESS, DontShowWindow)
    objShell.Popup "Step 2 Finished", 1, "Stage 2/3", vbInformation
    WScript.Sleep 1000
    MakeScript(3)
    ApplicationSession = oShell.run(""""&DIRECTORY&"\wrapper.bat """ & """"&DIRECTORY&"""" & " " & IPADDRESS, DontShowWindow)
    objShell.Popup "Step 3 Finished", 1, "Stage 3/3", vbInformation
    WScript.Sleep 1000
    msgbox "Imei has successfully changed, Your modem should reboot automatically and successfully change your imei"& vbCrLf& vbCrLf & "PuttyTelnet will now close click Ok to completely close it", 64, "INFO"
    Wscript.Quit
end function

Main()
' github.com/Kinuseka