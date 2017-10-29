pushd %~dp0

del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.2012.dll" /F
del C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.2012.dll" /F

del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Vcs.Ssis.*.dll" /F
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Vcs.Ssis.*.dll" /F

gacutil /uf "Varigence.Ssis.2012"
gacutil /uf "Vcs.SSIS.2012"

gacutil /uf "Vcs.Ssis.AuditRow.2012"
gacutil /uf "Vcs.Ssis.RowCount.2012"
gacutil /uf "Vcs.Ssis.Hash.2012"
gacutil /uf "Vcs.Ssis.HashDual.2012"
gacutil /uf "Vcs.Ssis.ErrorDescription.2012"

gacutil /uf "Vcs.Ssis.AuditRow"
gacutil /uf "Vcs.Ssis.RowCount"
gacutil /uf "Vcs.Ssis.Hash"
gacutil /uf "Vcs.Ssis.HashDual"
gacutil /uf "Vcs.Ssis.ErrorDescription"

PAUSE