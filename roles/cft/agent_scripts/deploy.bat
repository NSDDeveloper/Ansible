set files_dir=%1%
@echo off
chcp 1251
set srv=%3%
For /F "tokens=1-5 Delims=@" %%a In ("%srv%") Do set srv=%%b
if "%srv%"=="" set srv=%3%
echo srv=%srv%
set pwd=%2%
set pwd_fs=%4%

set log_name=_20%date:~-2%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log
set log_name=%log_name: =0%

findstr /C:"property name=\"release_num_before\"" %files_dir%\Source\IBSO\setup\version.xml >%files_dir%\release_num_before
For /F "tokens=1-5 Delims=/ " %%a In (%files_dir%\release_num_before) Do (
echo %%c >%files_dir%\release_num_before
)
For /F "tokens=1-5 Delims= " %%a In (%files_dir%\release_num_before) Do (
set %%a
)
set r1=r%value:"=%

findstr /C:"property name=\"release_num\"" %files_dir%\Source\IBSO\setup\version.xml >%files_dir%\release_num
For /F "tokens=1-5 Delims=/ " %%a In (%files_dir%\release_num) Do (
echo %%c >%files_dir%\release_num
)
For /F "tokens=1-5 Delims= " %%a In (%files_dir%\release_num) Do (
set %%a
)
set r2=r%value:"=%
set fio_dir=%files_dir%\Source\IBSO\setup\%r2%\fio

findstr /C:"property name=\"version\"" %files_dir%\Source\IBSO\setup\version.xml >%files_dir%\version
For /F "tokens=1-5 Delims=/ " %%a In (%files_dir%\version) Do (
echo %%c >%files_dir%\version
)
For /F "tokens=1-5 Delims= " %%a In (%files_dir%\version) Do (
set %%a
)
set build_no=%value:"=%
set conv_file=%files_dir%\Source\IBSO\setup\%r2%\convert.sql
set distr_dir=%files_dir%\Source\IBSO\setup\%r2%\DISTR

echo.
echo  --- СОХРАНЕНИЕ PATCH.ZIP --- %r1% - %r2%
echo.
"C:\eclipse\IDE-latest\cft-platform-ide\eclipsec.exe" -clean -nosplash -nl ru_RU -application ru.cft.platform.team.Patch ^
-filePath "%files_dir%\patch.zip" ^
-repositoryPath "%files_dir%\.git" ^
-data "%files_dir%\workspace" ^
-branch "%r2%" -branchTarget "%r1%" ^
-project "Source/IBSO" --launcher.suppressErrors
echo.
echo  --- СОХРАНЕНИЕ PATCH.ZIP --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\licence.sql
echo  --- ПРОВЕРКА НАЛИЧИЯ ДЕЙСТВУЮЩЕЙ ЛИЦЕНЗИИ НА ДИСТРИБУТИВНУЮ ЧАСТЬ ЦФТ --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\fio.sql
echo  --- ПРОВЕРКА РАБОТОСПОСОБНОСТИ FIO --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end

set DD_LVL=0
if not exist %distr_dir%\inst_distr.bat goto deploy_local
echo.
echo  --- DEPLOY1 ИЗ ДИСТРИБУТИВНЫХ ОБНОВЛЕНИЙ ---
echo.
echo подключение к сетевой папке \\fsoffice.nsd.ru\depo
net use \\fsoffice.nsd.ru\depo %pwd_fs% /user:ta_cft_developer@nsd.ru
if not %ERRORLEVEL% equ 0 goto end
copy /Y c:\eclipse\deploy_zip.bat %distr_dir%
set last_dir=%cd%
cd %distr_dir%
call inst_distr.bat %srv% %pwd%
cd %last_dir%
echo.
echo  --- DEPLOY1 ИЗ ДИСТРИБУТИВНЫХ ОБНОВЛЕНИЙ --- код возврата %DD_LVL%
set ERRORLEVEL=%DD_LVL%
if not %ERRORLEVEL% equ 0 if not exist %conv_file% goto end

:deploy_local
echo.
echo  --- DEPLOY1 PATCH.ZIP ---
echo.
"C:\eclipse\IDE-latest\cft-platform-ide\eclipsec.exe" -clean -nosplash -nl ru_RU -application ru.cft.platform.deployment.bootstrap.Deployment ^
-deploy -server %srv% -owner IBS -username IBS -pass %pwd% -projectpath "%files_dir%\patch.zip" -data %files_dir%\workspace ^
-poolconfig "C:\eclipse\pool-settings.xml" -log %files_dir%\deploy%log_name% ^
--launcher.suppressErrors
echo.
echo  --- DEPLOY1 PATCH.ZIP --- код возврата %ERRORLEVEL%
if not %ERRORLEVEL% equ 0 if not exist %conv_file% goto end
set ERRLEV=%ERRORLEVEL%

echo.
echo  --- УДАЛЕНИЕ ЭЛЕМЕНТОВ ---
echo.
if exist "%files_dir%\patch_delete.pck" "C:\eclipse\IDE-latest\cft-platform-ide\eclipsec.exe" -clean -nosplash -nl ru_RU ^
-application ru.cft.platform.deployment.bootstrap.Deployment ^
-delete -server %srv% -owner IBS -username IBS -pass %pwd% -pckpath "%files_dir%\patch_delete.pck" -data %files_dir%\workspace ^
-poolconfig "C:\eclipse\pool-settings.xml" -log %files_dir%\delete%log_name% ^
--launcher.suppressErrors
echo.
echo  --- УДАЛЕНИЕ ЭЛЕМЕНТОВ --- код возврата %ERRORLEVEL% (игнорируется)

if not exist %fio_dir% goto conv
echo.
echo  --- КОПИРОВАНИЕ ФАЙЛОВ ИМПОРТА НА СЕРВЕР ---
echo.
cscript //B C:\eclipse\oxch.vbs %srv% %pwd% %files_dir% %fio_dir%
type %files_dir%\oxch.log
echo.
echo  --- КОПИРОВАНИЕ ФАЙЛОВ ИМПОРТА НА СЕРВЕР --- завершено

:conv
if not exist %conv_file% goto ver
echo.
echo  --- ВЫПОЛНЕНИЕ ОПЕРАЦИЙ КОНВЕРТАЦИИ ---
echo.
set sc=%files_dir%\conv.sql
echo declare l_debug_name varchar2(128); >%sc%
echo begin >>%sc%
echo    l_debug_name:=executor.lock_open(); >>%sc%
echo end; >>%sc%
echo / >>%sc%
echo set heading off >>%sc%
echo set newpage 0 >>%sc%
echo set pagesize 0 >>%sc%
echo spool %files_dir%\pipename.txt >>%sc%
echo select concat('DEBUG$',userenv('client_info')) from dual; >>%sc%
echo spool off >>%sc% 
echo host cscript //B c:\eclipse\oramon_start.vbs ibs/%pwd%@%srv% %files_dir%\pipename.txt %files_dir%\procid.txt %files_dir%\conv.log >>%sc%
echo / >>%sc%
type %conv_file% >>%sc%
echo / >>%sc%
echo host cscript //B c:\eclipse\oramon_stop.vbs %files_dir%\procid.txt >>%sc%
echo exit >>%sc%
sqlplus ibs/%pwd%@%srv% @%sc%
type %files_dir%\conv.log
sqlplus ibs/%pwd%@%srv% @c:\eclipse\recomp.sql
sqlplus ibs/%pwd%@%srv% @c:\eclipse\c_obj.sql
echo.
echo  --- ВЫПОЛНЕНИЕ ОПЕРАЦИЙ КОНВЕРТАЦИИ --- завершено

if not %DD_LVL% equ 0 (
set DD_LVL=0
echo.
echo  --- DEPLOY2 ИЗ ДИСТРИБУТИВНЫХ ОБНОВЛЕНИЙ ---
echo.
cd %distr_dir%
call inst_distr.bat %srv% %pwd%
cd %last_dir%
echo.
echo  --- DEPLOY2 ИЗ ДИСТРИБУТИВНЫХ ОБНОВЛЕНИЙ --- код возврата %DD_LVL%
set ERRORLEVEL=%DD_LVL%
if not %ERRORLEVEL% equ 0 goto end
set DD_LVL=1
)

if not %ERRLEV%%DD_LVL% equ 00 (
echo.
echo  --- DEPLOY2 PATCH.ZIP ---
echo.
"C:\eclipse\IDE-latest\cft-platform-ide\eclipsec.exe" -clean -nosplash -nl ru_RU -application ru.cft.platform.deployment.bootstrap.Deployment ^
-deploy -server %srv% -owner IBS -username IBS -pass %pwd% -projectpath "%files_dir%\patch.zip" -data %files_dir%\workspace ^
-poolconfig "C:\eclipse\pool-settings.xml" -log %files_dir%\deploy%log_name% ^
--launcher.suppressErrors
echo.
echo  --- DEPLOY2 PATCH.ZIP --- код возврата %ERRORLEVEL%
if not %ERRORLEVEL% equ 0 goto end
)

:ver
echo.
echo  --- УСТАНОВКА НОМЕРА ВЕРСИИ --- %build_no%

set n=0
:bstart
set /a n=n+1
set bld=%str%
call set str=%%build_no:~-%n%%%
set sm=%str:~0,1%
if %n% equ 6 (
set sm=.
set bld=1
)
if not %sm% equ . goto bstart
set /a bld=bld-1
echo call data_from_cft.ver_cft.Set_Ver('ARM_VER=6.0.120.03;RELEASE=%r2:~1,2%;PATCH=%r2:~-1%;MODIFY=%bld%;SET=+;DATEASSEMBLY=%date%;TIMEASSEMBLY=%time:~0,5%;SUCCESS=1'); | sqlplus ibs/%pwd%@%srv%

echo  --- ПРОВЕРКИ ПОСЛЕ УСТАНОВКИ ---
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\xmlparser.sql
echo  --- ПРОВЕРКА РАБОТОСПОСОБНОСТИ БИБЛИОТЕКИ XMLPARSER --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\webpdf.sql
echo  --- ПРОВЕРКА ДОСТУПНОСТИ СЕРВИСА WEBPDF --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\gis_gmp.sql
echo  --- ПРОВЕРКА РАБОТОСПОСОБНОСТИ ОБРАБОТЧИКОВ СООБЩЕНИЙ ГИС ГМП --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\fns.sql
echo  --- ПРОВЕРКА РАБОТОСПОСОБНОСТИ ОБРАБОТЧИКОВ СООБЩЕНИЙ ФНС --- код возврата %ERRORLEVEL%

if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\soa.sql
echo  --- ПРОВЕРКА ОТСУТСТВИЯ ЗАВИСШИХ СООБЩЕНИЙ В ОЧЕРЕДЯХ ШИНЫ --- код возврата %ERRORLEVEL%

if %srv:~0,2% equ t6 goto skip1
if %srv:~0,3% equ dev goto skip1
if not %ERRORLEVEL% equ 0 goto end
sqlplus ibs/%pwd%@%srv% @c:\eclipse\cft-server-checks\reportsever.sql
echo  --- ПРОВЕРКА НАЛИЧИЯ СЕССИЙ ОТ СЕРВЕРА ОТЧЕТОВ --- код возврата %ERRORLEVEL%
:skip1

if not %ERRORLEVEL% equ 0 goto end
echo  --- ПРОВЕРКИ ПОСЛЕ УСТАНОВКИ УСПЕШНО ЗАВЕРШЕНЫ ---

set ERRORLEVEL=0

:end

echo %ERRORLEVEL% >"%files_dir%/../deploy_log.txt.el"
exit 0
