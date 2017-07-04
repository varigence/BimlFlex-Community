pushd %~dp0

del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.AuditRow.2014.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.RowCount.2014.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.Hash.2014.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.HashDual.2014.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.2014.dll" /F

del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.AuditRow.2014.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.RowCount.2014.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.Hash.2014.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.HashDual.2014.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.2014.dll" /F

gacutil /uf "Vcs.SSIS.AuditRow.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Vcs.SSIS.RowCount.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Vcs.SSIS.Hash.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Vcs.SSIS.HashDual.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"
gacutil /uf "Vcs.SSIS.ErrorDescription.2014,Version=3.0.0.0,Culture=neutral,PublicKeyToken=ef6661b0957024a3"

del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.AuditRow.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.RowCount.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.Hash.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.HashDual.dll" /F
del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.dll" /F

del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.AuditRow.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.RowCount.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.Hash.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.HashDual.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.dll" /F

gacutil /uf "Vcs.SSIS.AuditRow,Version=3.0.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Vcs.SSIS.RowCount,Version=3.0.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Vcs.SSIS.Hash,Version=3.0.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Vcs.SSIS.HashDual,Version=3.0.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"
gacutil /uf "Vcs.SSIS.ErrorDescription,Version=3.0.0.0,Culture=neutral,PublicKeyToken=ef6661b0957024a3"

PAUSE