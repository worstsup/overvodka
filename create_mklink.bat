@echo off
@REM Благодарность dark123us
@REM гит папка вашего аддона
set PATHGIT=C:\github\overvodka12
@REM путь к доте
set PATHGAME=C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta
@REM название аддона
set NAMECUSTOM=overvodka
@REM прочее
set SUFFIX=\content\dota_addons\
set SUFFIX2=\game\dota_addons\
set SUFFIX_GIT=\content\
set SUFFIX2_GIT=\game\
@REM вывод инфо
echo %PATHGIT%
echo %PATHGAME%
echo -----------
echo %PATHGAME%%SUFFIX%%NAMECUSTOM%
echo %PATHGAME%%SUFFIX2%%NAMECUSTOM%
echo -----------
@REM создаем структуру в гит папке
mkdir "%PATHGIT%%SUFFIX_GIT%
mkdir "%PATHGIT%%SUFFIX2_GIT%
@REM связываем папку гит и аддон
mklink /J "%PATHGIT%%SUFFIX_GIT%%NAMECUSTOM%" "%PATHGAME%%SUFFIX%%NAMECUSTOM%"
mklink /J "%PATHGIT%%SUFFIX2_GIT%%NAMECUSTOM%" "%PATHGAME%%SUFFIX2%%NAMECUSTOM%"

pause
