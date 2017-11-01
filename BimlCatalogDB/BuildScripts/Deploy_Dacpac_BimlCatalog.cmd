pushd %~dp0

"OSQL\osql.exe" -E -S localhost -d BimlCatalog -i "BimlCatalog_PreDacpac_Deployment.sql"
"DAC\bin\SqlPackage.exe" /TargetServerName:localhost /TargetDatabaseName:BimlCatalog /action:Publish /SourceFile:"..\bin\Output\BimlCatalog.dacpac"

PAUSE