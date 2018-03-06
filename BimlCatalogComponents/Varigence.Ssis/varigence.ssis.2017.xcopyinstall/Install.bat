pushd %~dp0

gacutil /uf "Varigence.Ssis.2017"
gacutil /uf "Vcs.SSIS.2017"

del "C:\Program Files (x86)\Microsoft SQL Server\140\DTS\PipelineComponents\Vcs.Ssis.2017.dll" /F
del C:\Program Files\Microsoft SQL Server\140\DTS\PipelineComponents\Vcs.Ssis.2017.dll" /F

copy "Varigence.Ssis.2017.dll" "C:\Program Files (x86)\Microsoft SQL Server\140\DTS\PipelineComponents\" /Y
copy "Varigence.Ssis.2017.dll" "C:\Program Files\Microsoft SQL Server\140\DTS\PipelineComponents\" /Y

gacutil /if "Varigence.Ssis.2017.dll"

PAUSE
