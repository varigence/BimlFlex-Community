pushd %~dp0

del "C:\Program Files (x86)\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.Ssis.*.dll" /F
del "C:\Program Files\Microsoft SQL Server\120\DTS\PipelineComponents\Vcs.Ssis.*.dll" /F

gacutil /uf "Vcs.Ssis.AuditRow.2014"
gacutil /uf "Vcs.Ssis.RowCount.2014"
gacutil /uf "Vcs.Ssis.Hash.2014"
gacutil /uf "Vcs.Ssis.HashDual.2014"
gacutil /uf "Vcs.Ssis.ErrorDescription.2014"


gacutil /uf "Vcs.Ssis.AuditRow"
gacutil /uf "Vcs.Ssis.RowCount"
gacutil /uf "Vcs.Ssis.Hash"
gacutil /uf "Vcs.Ssis.HashDual"
gacutil /uf "Vcs.Ssis.ErrorDescription"

PAUSE