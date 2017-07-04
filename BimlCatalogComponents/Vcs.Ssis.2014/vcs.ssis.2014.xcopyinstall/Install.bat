pushd %~dp0

gacutil /uf "Vcs.SSIS.AuditRow.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Vcs.SSIS.RowCount.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Vcs.SSIS.Hash.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Vcs.SSIS.HashDual.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"

copy "Vcs.SSIS.AuditRow.2014.dll" "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Vcs.SSIS.RowCount.2014.dll" "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Vcs.SSIS.Hash.2014.dll" "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Vcs.SSIS.HashDual.2014.dll" "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y

copy "Vcs.SSIS.AuditRow.2014.dll" "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Vcs.SSIS.RowCount.2014.dll" "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Vcs.SSIS.Hash.2014.dll" "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y
copy "Vcs.SSIS.HashDual.2014.dll" "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\" /Y

gacutil /if "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.AuditRow.2014.dll"
gacutil /if "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.RowCount.2014.dll"
gacutil /if "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.Hash.2014.dll"
gacutil /if "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.HashDual.2014.dll"

PAUSE