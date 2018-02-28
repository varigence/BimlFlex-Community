# BimlCatalog

In any SSIS solution you will need to extend the default auditing and logging behavior to capture meaningful audit and debug information.
Of course, you can invest time and effort to build your own, but why not just reuse our free open source framework with provided BimlCatalog database, custom components, documentation, and extensive Biml samples?

This framework is robust and able to restart from the last failure skipping already loaded packages. 
As an example, if one of your 50 parallelized table load packages fails, the following execution will skip the packages that succeeded and resume at the next package.

BimlCatalog is a framework that can be integrated into your solution and includes features for:
* Row Counts
* Row Errors
* Persist Variables and Parameters
* Package and Task Execution Duration
* Package and Task Execution Errors

The BimlCatalog solution includes a database as well as several custom SSIS components

Custom SSIS components:
* Biml Error Description
* Biml Hash
* Biml Hash Dual
* Biml Row Audit
* Biml Row Count

The components are available for Microsoft SQL Server versions 2008r2-2016

## Dashboard and Reporting

A Power BI file is provided to support reporting requirements on events logged in the BimlCatalog.

[Read more about the Power BI dashboard here](BimlCatalogReporting/PowerBI)
