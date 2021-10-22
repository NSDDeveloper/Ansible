Set FSO = CreateObject("Scripting.FileSystemObject")
Set f = FSO.OpenTextFile(WScript.Arguments(0), 1)
procid=f.ReadLine
f.Close
WScript.Sleep(6000)
Set shell1 = CreateObject("WScript.Shell")
shell1.Run "taskkill.exe /PID "+procid+" /F", 0
'shell1.AppActivate(procid)
'shell1.SendKeys("%{F4}")

