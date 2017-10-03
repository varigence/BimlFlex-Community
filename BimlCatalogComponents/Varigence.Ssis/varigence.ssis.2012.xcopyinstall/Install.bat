pushd %~dp0

gacutil /uf "Varigence.Ssis.2012"

copy "Varigence.Ssis.2012.dll" "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\" /Y
copy "Varigence.Ssis.2012.dll" "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\" /Y

gacutil /if "Varigence.Ssis.2012.dll"

PAUSE