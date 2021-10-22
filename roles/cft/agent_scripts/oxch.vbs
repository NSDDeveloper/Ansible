On Error Resume Next
Set Oxch = CreateObject("Oxch.CInterfaces")
If Oxch Is Nothing Then
	WScript.Echo "Не удалось создать Oxch.CInterfaces"
Else
	Oxch.Schema = WScript.Arguments(0)
	Oxch.Owner = "IBS"
	Oxch.User = "IBS"
	Oxch.Password = WScript.Arguments(1)
	Oxch.App.LogPath = WScript.Arguments(2)
	Oxch.App.LogFile = "oxch.log"
	Set TaskConfigurator1 = Oxch.CreateTaskConfigurator
	If Not (TaskConfigurator1 Is Nothing) Then
		TaskConfigurator1.FromServer = False
		TaskConfigurator1.SourceFolder = WScript.Arguments(3)
		TaskConfigurator1.TargetFolder = ""
		TaskConfigurator1.FileMask = ""
		TaskConfigurator1.MoveSubfolders = False
		TaskConfigurator1.AppendMode = False
		TaskConfigurator1.OverwriteMode = "Replace"
		Oxch.StartProcessByConfigurator(TaskConfigurator1)
		'If Oxch.StartProcessByConfigurator(TaskConfigurator1) Then
		'	WScript.Echo "Задание 1 выполнено успешно"
		'Else
		'	Set ErrorStack = Oxch.ErrorStack
		'	If ErrorStack Is Nothing Then
		'		WScript.Echo "Не удалось взять ErrorStack"
		'	Else
		'		ErrorsList = ""
		'		For i = 0 To ErrorStack.Count - 1
		'			ErrorsList = ErrorsList + "Ошибка (" + CStr(ErrorStack(i).Number) + "): " + ErrorStack(i).Description & vbCrLf
		'		Next
		'		WScript.Echo ErrorsList
		'	End If
		'End If
	End If
End If