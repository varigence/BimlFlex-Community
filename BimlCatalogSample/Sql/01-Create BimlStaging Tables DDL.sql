IF NOT EXISTS (
		SELECT *
		FROM sys.databases
		WHERE NAME = N'BimlStaging'
		)
	CREATE DATABASE [BimlStaging]
GO

USE [BimlStaging]
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.schemas
		WHERE NAME = N'stg'
		)
	EXEC ('CREATE SCHEMA [stg] AUTHORIZATION [dbo]')
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_Address]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_Address]
GO

CREATE TABLE [stg].[SalesLT_Address] (
	-- Columns Definition
	[AddressID] INT NOT NULL
	,[AddressLine1] NVARCHAR(60) NOT NULL
	,[AddressLine2] NVARCHAR(60)
	,[City] NVARCHAR(30) NOT NULL
	,[StateProvince] NVARCHAR(50) NOT NULL
	,[CountryRegion] NVARCHAR(50) NOT NULL
	,[PostalCode] NVARCHAR(15) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_Customer]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_Customer]
GO

CREATE TABLE [stg].[SalesLT_Customer] (
	-- Columns Definition
	[CustomerID] INT NOT NULL
	,[NameStyle] BIT NOT NULL
	,[Title] NVARCHAR(8)
	,[FirstName] NVARCHAR(50) NOT NULL
	,[MiddleName] NVARCHAR(50)
	,[LastName] NVARCHAR(50) NOT NULL
	,[Suffix] NVARCHAR(10)
	,[CompanyName] NVARCHAR(128)
	,[SalesPerson] NVARCHAR(256)
	,[EmailAddress] NVARCHAR(50)
	,[Phone] NVARCHAR(25)
	,[PasswordHash] VARCHAR(128) NOT NULL
	,[PasswordSalt] VARCHAR(10) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_CustomerAddress]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_CustomerAddress]
GO

CREATE TABLE [stg].[SalesLT_CustomerAddress] (
	-- Columns Definition
	[CustomerID] INT NOT NULL
	,[AddressID] INT NOT NULL
	,[AddressType] NVARCHAR(50) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_Product]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_Product]
GO

CREATE TABLE [stg].[SalesLT_Product] (
	-- Columns Definition
	[ProductID] INT NOT NULL
	,[Name] NVARCHAR(50) NOT NULL
	,[ProductNumber] NVARCHAR(25) NOT NULL
	,[Color] NVARCHAR(15)
	,[StandardCost] MONEY NOT NULL
	,[ListPrice] MONEY NOT NULL
	,[Size] NVARCHAR(5)
	,[Weight] DECIMAL(8, 2)
	,[ProductCategoryID] INT
	,[ProductModelID] INT
	,[SellStartDate] DATETIME NOT NULL
	,[SellEndDate] DATETIME
	,[DiscontinuedDate] DATETIME
	,[ThumbNailPhoto] VARBINARY(max)
	,[ThumbnailPhotoFileName] NVARCHAR(50)
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_ProductCategory]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_ProductCategory]
GO

CREATE TABLE [stg].[SalesLT_ProductCategory] (
	-- Columns Definition
	[ProductCategoryID] INT NOT NULL
	,[ParentProductCategoryID] INT
	,[Name] NVARCHAR(50) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_ProductDescription]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_ProductDescription]
GO

CREATE TABLE [stg].[SalesLT_ProductDescription] (
	-- Columns Definition
	[ProductDescriptionID] INT NOT NULL
	,[Description] NVARCHAR(400) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_ProductModel]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_ProductModel]
GO

CREATE TABLE [stg].[SalesLT_ProductModel] (
	-- Columns Definition
	[ProductModelID] INT NOT NULL
	,[Name] NVARCHAR(50) NOT NULL
	,[CatalogDescription] XML
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_ProductModelProductDescription]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_ProductModelProductDescription]
GO

CREATE TABLE [stg].[SalesLT_ProductModelProductDescription] (
	-- Columns Definition
	[ProductModelID] INT NOT NULL
	,[ProductDescriptionID] INT NOT NULL
	,[Culture] NCHAR(6) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_SalesOrderDetail]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_SalesOrderDetail]
GO

CREATE TABLE [stg].[SalesLT_SalesOrderDetail] (
	-- Columns Definition
	[SalesOrderID] INT NOT NULL
	,[SalesOrderDetailID] INT NOT NULL
	,[OrderQty] SMALLINT NOT NULL
	,[ProductID] INT NOT NULL
	,[UnitPrice] MONEY NOT NULL
	,[UnitPriceDiscount] MONEY NOT NULL
	,[LineTotal] DECIMAL(38, 6) NOT NULL
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[stg].[SalesLT_SalesOrderHeader]')
			AND type IN (N'U')
		)
	DROP TABLE [stg].[SalesLT_SalesOrderHeader]
GO

CREATE TABLE [stg].[SalesLT_SalesOrderHeader] (
	-- Columns Definition
	[SalesOrderID] INT NOT NULL
	,[RevisionNumber] TINYINT NOT NULL
	,[OrderDate] DATETIME NOT NULL
	,[DueDate] DATETIME NOT NULL
	,[ShipDate] DATETIME
	,[Status] TINYINT NOT NULL
	,[OnlineOrderFlag] BIT NOT NULL
	,[SalesOrderNumber] NVARCHAR(25) NOT NULL
	,[PurchaseOrderNumber] NVARCHAR(25)
	,[AccountNumber] NVARCHAR(15)
	,[CustomerID] INT NOT NULL
	,[ShipToAddressID] INT
	,[BillToAddressID] INT
	,[ShipMethod] NVARCHAR(50) NOT NULL
	,[CreditCardApprovalCode] VARCHAR(15)
	,[SubTotal] MONEY NOT NULL
	,[TaxAmt] MONEY NOT NULL
	,[Freight] MONEY NOT NULL
	,[TotalDue] MONEY NOT NULL
	,[Comment] NVARCHAR(max)
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[RowStringKey] NVARCHAR(100) NULL
	,[BimlDualRowHash] CHAR(80) NULL
	,[BimlRowHashKey] CHAR(40) NULL
	,[BimlRowSqlHashKey] CHAR(40) NULL
	-- Constraints
	) ON "default"
	WITH (DATA_COMPRESSION = NONE)
GO

-------------------------------------------------------------------
