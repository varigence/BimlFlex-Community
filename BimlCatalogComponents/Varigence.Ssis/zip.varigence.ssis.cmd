pushd %~dp0

del varigence.ssis.2008.xcopyinstall.zip /F
del varigence.ssis.2012.xcopyinstall.zip /F
del varigence.ssis.2014.xcopyinstall.zip /F
del varigence.ssis.2016.xcopyinstall.zip /F
del varigence.ssis.2017.xcopyinstall.zip /F
del varigence.ssis.2008.xcopyinstall\Microsoft.SqlServer*.* /F
del varigence.ssis.2012.xcopyinstall\Microsoft.SqlServer*.* /F
del varigence.ssis.2014.xcopyinstall\Microsoft.SqlServer*.* /F
del varigence.ssis.2016.xcopyinstall\Microsoft.SqlServer*.* /F
del varigence.ssis.2017.xcopyinstall\Microsoft.SqlServer*.* /F
del varigence.ssis.2008.xcopyinstall\*.pdb /F
del varigence.ssis.2012.xcopyinstall\*.pdb /F
del varigence.ssis.2014.xcopyinstall\*.pdb /F
del varigence.ssis.2016.xcopyinstall\*.pdb /F
del varigence.ssis.2017.xcopyinstall\*.pdb /F

7z.exe a -aoa -tzip varigence.ssis.2008.xcopyinstall.zip varigence.ssis.2008.xcopyinstall\*.* varigence.ssis.2008.xcopyinstall\1033\*.*
7z.exe a -aoa -tzip varigence.ssis.2012.xcopyinstall.zip varigence.ssis.2012.xcopyinstall\*.* varigence.ssis.2012.xcopyinstall\1033\*.*
7z.exe a -aoa -tzip varigence.ssis.2014.xcopyinstall.zip varigence.ssis.2014.xcopyinstall\*.* varigence.ssis.2014.xcopyinstall\1033\*.*
7z.exe a -aoa -tzip varigence.ssis.2016.xcopyinstall.zip varigence.ssis.2016.xcopyinstall\*.* varigence.ssis.2016.xcopyinstall\1033\*.*
7z.exe a -aoa -tzip varigence.ssis.2017.xcopyinstall.zip varigence.ssis.2017.xcopyinstall\*.* varigence.ssis.2017.xcopyinstall\1033\*.*

PAUSE
