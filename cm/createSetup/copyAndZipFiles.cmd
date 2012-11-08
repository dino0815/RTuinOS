@echo off
:: Compose file tree, call ZIP and create the installation package.
:: Run this batch from the directory cm/createSetup only!

if "%1" == "" goto LUsage
if "%1" == "-h" goto LUsage
if "%1" == "-?" goto LUsage
if "%1" == "/?" goto LUsage
if "%1" == "/h" goto LUsage

setlocal

rmdir /S/Q tmp > nul 2> nul

:: Create the directory tree as aimed on the destination system.

mkdir tmp
mkdir tmp\RTuinOS

:: Pathes used for collecting the file are relative to the root of the project.
pushd ..\..
set output=cm\createSetup\tmp\RTuinOS

:: Global documentation
copy doc\readMe.forSetup.txt %output%\readMe.txt
mkdir %output%\doc
mkdir %output%\doc\doxygen
xcopy /S doc\doxygen\* %output%\doc\doxygen
mkdir %output%\doc\manual
xcopy /S doc\manual\GNUmakefile %output%\doc\manual
xcopy /S doc\manual\manual.pdf %output%\doc\manual
xcopy /S doc\manual\*.tex %output%\doc\manual
xcopy /S doc\manual\*.jpg %output%\doc\manual

:: The source code
mkdir %output%\code
xcopy /S code\* %output%\code

:: To soften the problems of the makefile with the creation of the output directories, we
:: distribute RTuinOS with the (empty) directories in place.
mkdir %output%\bin
mkdir %output%\bin\core
mkdir %output%\bin\core\obj
mkdir %output%\bin\DEBUG
mkdir %output%\bin\DEBUG\obj
mkdir %output%\bin\PRODUCTION
mkdir %output%\bin\PRODUCTION\obj

:: The makefile, license. The version file needs to be supplied by the caller of this script.
copy lgpl.txt %output%
copy GNUmakefile %output%
copy cm\createSetup\version.txt %output%

:: Protect files
attrib +R %output%\*

:: Replace the current archive with the zipped temporary directory tree.
popd
del /F/Q %1 > nul 2> nul
7za a -tzip %1 .\tmp\* -r
if ERRORLEVEL 1 (
    echo Error: Files could not be archived completely
    exit /B 1
)

:: Remove the temporary directory tree again.
rmdir /S/Q tmp

goto LEnd

:LUsage
echo usage: copyAndZipFiles archive
echo archive designates the name of the aimed archive file.
goto LEnd

:LEnd
