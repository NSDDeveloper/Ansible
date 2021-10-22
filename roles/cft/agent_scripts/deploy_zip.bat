"C:\eclipse\IDE-latest\cft-platform-ide\eclipsec.exe" -clean -nosplash -nl ru_RU -application ru.cft.platform.deployment.bootstrap.Deployment ^
-deploy -server %srv% -owner IBS -username IBS -pass %pwd% -projectpath %3 -pckpath %4 -data %files_dir%\workspace ^
-log %files_dir%\deploy%log_name% --launcher.suppressErrors
if not %ERRORLEVEL% equ 0 set DD_LVL=%ERRORLEVEL%