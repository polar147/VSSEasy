cd "%~dp0"
del VSSEasy64.exe /f
:CheckOS
IF EXIST "%PROGRAMFILES(X86)%" (GOTO 64BIT) ELSE (GOTO 32BIT)

:64BIT
"%PROGRAMFILES(X86)%\AutoIt3\Aut2Exe\Aut2exe_x64.exe" /In VSSEasy.au3 /out VSSEasy64.exe /x64 /console
GOTO END

:32BIT
"%PROGRAMFILES%\AutoIt3\Aut2Exe\Aut2exe_x64.exe" /In VSSEasy.au3 /out VSSEasy64.exe /x64 /console
GOTO END

:END
