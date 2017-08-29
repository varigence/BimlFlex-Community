pushd %~dp0

gacutil /uf "Varigence.Ssis.2008"

copy "Varigence.Ssis.2008.dll" "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\" /Y
copy "Varigence.Ssis.2008.dll" "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\" /Y

gacutil /if "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Varigence.Ssis.2008.dll"

PAUSE