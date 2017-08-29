pushd %~dp0

gacutil /uf "Varigence.Ssis.2016"

copy "Varigence.Ssis.2016.dll" "C:\Program Files (x86)\Microsoft SQL Server\130\DTS\PipelineComponents\" /Y
copy "Varigence.Ssis.2016.dll" "C:\Program Files\Microsoft SQL Server\130\DTS\PipelineComponents\" /Y

gacutil /if "C:\Program Files\Microsoft SQL Server\130\DTS\PipelineComponents\Varigence.Ssis.2016.dll"

PAUSE
