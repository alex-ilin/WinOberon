@echo off

rem echo param0 = "%~f0" param1 = "%~1" param2 = "%~2"
rem For some reason Factor's output can't be redirected away from the console window. 2>&1 doesn't help.
rem Same goes for cat.exe, but not type.exe. It's probably a Git for Windows issue.
rem In any case, as a workaround, the output is dumped to a temp-file instead of stdout, then the file
rem is output by type.exe.
rem If this gets fixed in Git for Windows, then in the oberon.factor script one line has to be changed
rem to direct output to stdout, and *this* script should become a one-liner.

del d:\Programs\Dev\git\cmd\temp 2>nul
d:\Programs\Dev\factor\factor.com d:\Programs\Dev\factor\work\oberon\oberon.factor "%~f1"
if exist d:\Programs\Dev\git\cmd\temp (
  echo "%~f1">>%~dpn0.log
  type d:\Programs\Dev\git\cmd\temp
) else (
  echo failed: "%~f1">>%~dpn0.log
  copy "%~f1" d:\Programs\Dev\git\cmd\last-fail
)
