pushd %~dp0

gacutil /uf "Varigence.Ssis.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=4453eb433c6b118e"

copy "Varigence.Ssis.2014.dll" "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Varigence.Ssis.2014.dll" "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y

gacutil /if "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Varigence.Ssis.2014.dll"

PAUSE
