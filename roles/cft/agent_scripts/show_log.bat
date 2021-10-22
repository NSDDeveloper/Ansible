@echo off
powershell -Command "(gc '%1') | out-file -encoding Unicode %1.unicode"
type %1.unicode
set /p ERRORLEVEL=<%1.el
exit %ERRORLEVEL%
