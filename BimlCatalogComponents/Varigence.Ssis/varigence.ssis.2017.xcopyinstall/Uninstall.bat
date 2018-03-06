pushd %~dp0

del "C:\Program Files (x86)\Microsoft SQL Server\140\DTS\PipelineComponents\Varigence.Ssis.2017.dll" /F
del C:\Program Files\Microsoft SQL Server\140\DTS\PipelineComponents\Varigence.Ssis.2017.dll" /F

del "C:\Program Files (x86)\Microsoft SQL Server\140\DTS\PipelineComponents\Vcs.Ssis.*.dll" /F
del "C:\Program Files\Microsoft SQL Server\140\DTS\PipelineComponents\Vcs.Ssis.*.dll" /F

gacutil /uf "Varigence.Ssis.2017"
gacutil /uf "Vcs.SSIS.2017"

gacutil /uf "Vcs.Ssis.AuditRow.2017"
gacutil /uf "Vcs.Ssis.RowCount.2017"
gacutil /uf "Vcs.Ssis.Hash.2017"
gacutil /uf "Vcs.Ssis.HashDual.2017"
gacutil /uf "Vcs.Ssis.ErrorDescription.2017"

gacutil /uf "Vcs.Ssis.AuditRow"
gacutil /uf "Vcs.Ssis.RowCount"
gacutil /uf "Vcs.Ssis.Hash"
gacutil /uf "Vcs.Ssis.HashDual"
gacutil /uf "Vcs.Ssis.ErrorDescription"

PAUSE