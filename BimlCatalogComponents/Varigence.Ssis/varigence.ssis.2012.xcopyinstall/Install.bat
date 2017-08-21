pushd %~dp0

gacutil /uf "Varigence.Ssis.2012,Version=2.0.0.0,Culture=neutral,PublicKeyToken=4453eb433c6b118e"

copy "Varigence.Ssis.2012.dll" "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\" /Y
copy "Varigence.Ssis.2012.dll" "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\" /Y

gacutil /if "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.2012.dll"

PAUSE