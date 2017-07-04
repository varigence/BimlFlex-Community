pushd %~dp0

del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.AuditRow.2008.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.RowCount.2008.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.Hash.2008.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.HashDual.2008.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.2008.dll" /Y

del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.AuditRow.2008.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.RowCount.2008.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.Hash.2008.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.HashDual.2008.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.2008.dll" /Y

gacutil /uf "Vcs.SSIS.AuditRow.2008,Version=1.5.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Vcs.SSIS.RowCount.2008,Version=1.5.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Vcs.SSIS.Hash.2008,Version=1.5.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Vcs.SSIS.HashDual.2008,Version=1.5.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"
gacutil /uf "Vcs.SSIS.ErrorDescription.2008,Version=1.5.0.0,Culture=neutral,PublicKeyToken=ef6661b0957024a3"

del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.AuditRow.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.RowCount.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.Hash.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.HashDual.dll" /Y
del "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.dll" /Y

del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.AuditRow.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.RowCount.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.Hash.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.HashDual.dll" /Y
del "C:\Program Files\Microsoft SQL Server\100\DTS\PipelineComponents\Vcs.SSIS.ErrorDescription.dll" /Y

gacutil /uf "Vcs.SSIS.AuditRow,Version=1.5.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Vcs.SSIS.RowCount,Version=1.5.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Vcs.SSIS.Hash,Version=1.5.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Vcs.SSIS.HashDual,Version=1.5.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"
gacutil /uf "Vcs.SSIS.ErrorDescription,Version=1.5.0.0,Culture=neutral,PublicKeyToken=ef6661b0957024a3"

PAUSE