pushd %~dp0

set HR=%time:~0,2%
set HR=%Hr: =0% 
set HR=%HR: =%

for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G

set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set buildnum=%year:~3,4%%month%%day%

echo UPDATE [admin].[Configurations] SET [ConfigurationValue] = '%buildnum%' WHERE [ConfigurationCode] = 'BimlCatalog' AND [ConfigurationKey] = 'DatabaseVersion' > "..\StaticData\Entities\DatabaseVersion.sql"

