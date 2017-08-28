pushd %~dp0

del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.AuditRow.2012.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.RowCount.2012.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.Hash.2012.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.HashDual.2012.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.ErrorDescription.2012.dll" 

del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.AuditRow.2012.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.RowCount.2012.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.Hash.2012.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.HashDual.2012.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.ErrorDescription.2012.dll" 

gacutil /uf "Varigence.Ssis.AuditRow.2012,Version=2.0.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Varigence.Ssis.RowCount.2012,Version=2.0.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Varigence.Ssis.Hash.2012,Version=2.0.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Varigence.Ssis.HashDual.2012,Version=2.0.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"
gacutil /uf "Varigence.Ssis.ErrorDescription.2012,Version=2.0.0.0,Culture=neutral,PublicKeyToken=ef6661b0957024a3"


del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.AuditRow.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.RowCount.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.Hash.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.HashDual.dll" 
del "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.ErrorDescription.dll" 

del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.AuditRow.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.RowCount.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.Hash.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.HashDual.dll" 
del "C:\Program Files\Microsoft SQL Server\110\DTS\PipelineComponents\Varigence.Ssis.ErrorDescription.dll" 

gacutil /uf "Varigence.Ssis.AuditRow,Version=2.0.0.0,Culture=neutral,PublicKeyToken=58b55622b332e5d2"
gacutil /uf "Varigence.Ssis.RowCount,Version=2.0.0.0,Culture=neutral,PublicKeyToken=362514cb8c3caca8"
gacutil /uf "Varigence.Ssis.Hash,Version=2.0.0.0,Culture=neutral,PublicKeyToken=d976e30bc066892c"
gacutil /uf "Varigence.Ssis.HashDual,Version=2.0.0.0,Culture=neutral,PublicKeyToken=d77e942095cbed6c"
gacutil /uf "Varigence.Ssis.ErrorDescription,Version=2.0.0.0,Culture=neutral,PublicKeyToken=ef6661b0957024a3"

PAUSE