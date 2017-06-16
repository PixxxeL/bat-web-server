@echo off

chcp 1251
cls

where /Q python
if %ERRORLEVEL% NEQ 0 (
    set py_error=ERROR: You must install Python first
) else (
    set py_error=
)

where /Q php
if %ERRORLEVEL% NEQ 0 (
    set php_error=ERROR: You must install PHP first
) else (
    set php_error=
)

set cuurent_dir=%cd%
set index_file=%cuurent_dir%\index.html

if /I "%1" == "py" (
    if defined py_error (
        echo %py_error%
        goto EOF
    )
    echo Run Python web server...
    start /B python -m SimpleHTTPServer 8888
    goto CREATEINDEXFILE
) else if /I "%1" == "php" (
    if defined php_error (
        echo %php_error%
        goto EOF
    )
    echo Run PHP web server...
    start /B php -S localhost:8888
    goto CREATEINDEXFILE
) else (
    echo You is not defined py or php argument
    echo Calling example: serve.bat py
    goto EOF
)

:CREATEINDEXFILE
    if not exist %index_file% (
        echo ^<h1^>Server is running^</h1^>>%index_file%
    )
    goto RUNBROWSER

:RUNBROWSER
    start http://localhost:8888/
    echo Use CTRL+BREAK to stop web server

:EOF
    cd %cuurent_dir%
