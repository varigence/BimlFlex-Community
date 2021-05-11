# BimlCatalog Power BI Execution Monitoring Dashboard

The `BimlCatalogExecutionMonitoring.pbix` Power BI file provides a dashboard for executions logged in the BimlCatalog database.

This Power BI Dashboard was provided to the BimlCatalog project by:

> **BitQ**  
> Transforming Business Data into Intelligent Data  
> [www.bitq.com.au](https://www.bitq.com.au)

It provides three tabs for reviewing execution data:

* Data Logistics executions
* Execution trends
* Error details

## Data Logistics executions

Shows an overview and drill through options for executions.

![Package Executions](images/ss-PackageExecutions.png)

## Execution trends

Shows trends for executions.

![Execution Trends](images/ss-ExecutionTrends.png)

## Error details

Shows details for errors.

![Error Details](images/ss-ErrorDetails.png)

## Connecting to a BimlCatalog instance

The Power BI file has an embedded connection to the BimlCatalog database to localhost.

Update the connection to point to the BimlCatalog from where reporting data should be extracted and refresh the data:

* For Power BI (desktop) this can be done by navigating to query editor, by right-clicking the table on the right hand pane ('edit query'). In the next screen there is a 'data source settings' option where you can modify the connection. 
* You can also navigate to File -> Options and settings -> Data source settings to make this change. 
