pushd %~dp0

set HR=%time:~0,2%
set HR=%Hr: =0% 
set HR=%HR: =%

for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G

set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set /a buildmonth = ((%year%-2016)*12)+%month%
set buildnum=6%buildmonth%%day%

echo UPDATE [admin].[Configurations] SET [ConfigurationValue] = '%buildnum%' WHERE [ConfigurationCode] = 'BimlCatalog' AND [ConfigurationKey] = 'DatabaseVersion' > "..\StaticData\Entities\DatabaseVersion.sql"

del ..\bin\output\bimlcatalog.*.version
echo ^<BundleRoot xmlns="http://schemas.varigence.com/Bundle.xsd" VersionBuild="%buildnum%" /^> > "..\bin\output\bimlcatalog.%buildnum%.version"
