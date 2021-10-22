Set FSO = CreateObject("Scripting.FileSystemObject")
Set f = FSO.OpenTextFile(WScript.Arguments(1), 1)
pipename=f.ReadLine
f.Close
Set shell1 = CreateObject("WScript.Shell")
Set oramon1 = shell1.Exec("c:\progra~2\cft\oramon.exe "+WScript.Arguments(0)+" owner=ibs /LoginMode=2L pipe="+pipename+" /LogFile="+WScript.Arguments(3))
Set f = FSO.CreateTextFile(WScript.Arguments(2), True)
f.WriteLine(oramon1.ProcessID)
f.Close
