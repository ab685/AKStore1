USE [master]
GO
/****** Object:  Database [AKStore]    Script Date: 20-11-2022 20:41:39 ******/
CREATE DATABASE [AKStore]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AKStore', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\AKStore.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AKStore_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\AKStore_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [AKStore] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AKStore].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AKStore] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AKStore] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AKStore] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AKStore] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AKStore] SET ARITHABORT OFF 
GO
ALTER DATABASE [AKStore] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [AKStore] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AKStore] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AKStore] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AKStore] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AKStore] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AKStore] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AKStore] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AKStore] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AKStore] SET  DISABLE_BROKER 
GO
ALTER DATABASE [AKStore] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AKStore] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AKStore] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AKStore] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AKStore] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AKStore] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AKStore] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AKStore] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [AKStore] SET  MULTI_USER 
GO
ALTER DATABASE [AKStore] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AKStore] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AKStore] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AKStore] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [AKStore] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [AKStore] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [AKStore] SET QUERY_STORE = OFF
GO
USE [AKStore]
GO
/****** Object:  UserDefinedTableType [dbo].[BillDetailstype]    Script Date: 20-11-2022 20:41:40 ******/
CREATE TYPE [dbo].[BillDetailstype] AS TABLE(
	[ProductName] [varchar](250) NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 6) NULL,
	[Amount] [decimal](18, 6) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[IntList]    Script Date: 20-11-2022 20:41:40 ******/
CREATE TYPE [dbo].[IntList] AS TABLE(
	[Item] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[StringList]    Script Date: 20-11-2022 20:41:40 ******/
CREATE TYPE [dbo].[StringList] AS TABLE(
	[Item] [varchar](500) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[ProductPurchaseBatchNo]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ProductPurchaseBatchNo](
@ProductId int
)  
RETURNS Varchar(100)  

BEGIN
Declare @LatestBatchNo varchar(100)='';

Declare @LastBatchIndex int  =0;

Declare @LastBatchNo varchar(100)=( SELECT TOP 1
		BatchNo
	FROM [AKStore].dbo.[ProductPurchase]
	WHERE ProductId = @ProductId
	ORDER BY Id DESC)

DECLARE @BatchList TABLE (
	Item VARCHAR(100)
)

INSERT INTO @BatchList
	SELECT
		value
	FROM STRING_SPLIT(@LastBatchNo, '_');
SET @LastBatchIndex = (SELECT
		TRY_CAST(T.Item AS INT)
	FROM (SELECT
			Item
		   ,ROW_NUMBER() OVER (ORDER BY (SELECT
					1)
			) RN
		FROM @BatchList) T
	WHERE T.RN = 2)

SET @LatestBatchNo = (SELECT
		CONCAT('Batch_', (COALESCE(@LastBatchIndex, 0) + 1),'_', 'Prod_', @ProductId, '_', FORMAT(GETDATE(), 'dd_MMM_yyyy_hh_mm_ss')));

RETURN @LatestBatchNo;
END
GO
/****** Object:  UserDefinedFunction [dbo].[StockDetailBatchNo]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[StockDetailBatchNo](
@ProductId int,
@PurchasePrice Decimal(18,2)
)  
RETURNS Varchar(100)  

BEGIN
Declare @LatestBatchNo varchar(100)='';

Declare @LastBatchIndex int  =0;

Declare @LastBatchNo varchar(100)=( SELECT TOP 1
		BatchNo
	FROM [AKStore].dbo.[StockDetail]
	WHERE ProductId = @ProductId
	AND PurchasePrice = @PurchasePrice
	ORDER BY Id DESC)

DECLARE @BatchList TABLE (
	Item VARCHAR(100)
)

INSERT INTO @BatchList
	SELECT
		value
	FROM STRING_SPLIT(@LastBatchNo, '_');
SET @LastBatchIndex = (SELECT
		TRY_CAST(T.Item AS INT)
	FROM (SELECT
			Item
		   ,ROW_NUMBER() OVER (ORDER BY (SELECT
					1)
			) RN
		FROM @BatchList) T
	WHERE T.RN = 2)

SET @LatestBatchNo = (SELECT
		CONCAT('Batch_', (COALESCE(@LastBatchIndex, 0) + 1), '_', 'Prod_', @ProductId, '_', 'Price_', TRY_CAST(@PurchasePrice AS VARCHAR(10)), '_', FORMAT(GETDATE(), 'dd_MMM_yyyy_hh_mm_ss')));

RETURN @LatestBatchNo;
END
GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Admin]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Admin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[InsertedDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.Admin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillDetails]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BillId] [int] NULL,
	[ProductName] [varchar](250) NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 6) NULL,
	[Amount] [decimal](18, 6) NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_BillDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bills]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bills](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[DistributorId] [int] NULL,
	[BillNo] [int] NULL,
	[BillTotal] [decimal](18, 6) NULL,
	[FileName] [varchar](100) NULL,
	[BillDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Bills] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DistributorId] [int] NULL,
	[Name] [nvarchar](200) NULL,
	[FilePath] [varchar](400) NULL,
	[Description] [nvarchar](500) NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Company]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NULL,
	[DistributorId] [int] NULL,
	[Name] [nvarchar](100) NULL,
	[FilePath] [varchar](400) NULL,
	[Description] [nvarchar](500) NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[DistributorId] [int] NOT NULL,
	[SerialNo] [int] NOT NULL,
	[StoreName] [nvarchar](max) NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.Customer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerDetails]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[ProductId] [int] NULL,
	[Quantity] [int] NULL,
	[BasePrice] [int] NULL,
 CONSTRAINT [PK_CustomerDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Distributor]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Distributor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[UserId] [int] NOT NULL,
	[AdminId] [int] NOT NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
 CONSTRAINT [PK_dbo.Distributor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NULL,
	[StockDetailId] [int] NULL,
	[QuantityDeliverd] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderMaster]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DistributorId] [int] NOT NULL,
	[OrderStatusId] [int] NULL,
	[ProductId] [int] NULL,
	[CustomerId] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
	[OrderDate] [datetime] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_dbo.OrderMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderStatus]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
 CONSTRAINT [PK_OrderStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductMaster]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NULL,
	[CompanyId] [int] NULL,
	[DistributorId] [int] NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[SellPrice] [decimal](18, 2) NULL,
	[Quantity] [int] NULL,
	[FilePath] [varchar](300) NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
	[HasDiscount] [bit] NULL,
 CONSTRAINT [PK_dbo.ProductMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductPurchase]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductPurchase](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NULL,
	[PurchasePrice] [decimal](18, 2) NULL,
	[Quantity] [int] NULL,
	[BatchNo] [varchar](100) NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_ProductPurchase] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Retailer]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Retailer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[DistributorId] [int] NOT NULL,
	[InsertedDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
 CONSTRAINT [PK_dbo.Retailer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RetailerDetails]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RetailerDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RetailerId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[InsertedDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
 CONSTRAINT [PK_dbo.RetailerDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RouteMaster]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DistributorId] [int] NOT NULL,
	[RouteName] [nvarchar](max) NULL,
	[AreaName] [nvarchar](max) NULL,
	[SocietyName] [nvarchar](max) NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[InsertedByUserId] [int] NULL,
 CONSTRAINT [PK_dbo.RouteMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockDetail]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NULL,
	[BatchNo] [varchar](100) NULL,
	[AvailableQuantity] [int] NULL,
	[PurchasePrice] [decimal](18, 2) NULL,
	[IsActive] [bit] NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_StockDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stocks]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stocks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NULL,
	[ProductStock] [int] NULL,
	[InsertedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Stocks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionMaster]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DistributorId] [int] NULL,
	[CustomerId] [int] NULL,
	[Amount] [decimal](18, 6) NULL,
	[Notes] [nvarchar](500) NULL,
	[TransactionDate] [datetime] NULL,
	[InsertedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[UserName] [nvarchar](max) NULL,
	[Password] [nvarchar](max) NULL,
	[RoleId] [int] NOT NULL,
	[PhNo1] [nvarchar](max) NULL,
	[PhNo2] [nvarchar](max) NULL,
	[LoggedInCount] [int] NOT NULL,
	[LastLoggedInTime] [datetime] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[Address] [nvarchar](max) NULL,
	[PostalCode] [varchar](50) NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Admin] ON 

INSERT [dbo].[Admin] ([Id], [UserId], [InsertedDate], [InsertedByUserId], [UpdatedByUserId], [UpdatedDate]) VALUES (1, 2, CAST(N'2021-08-11T16:53:01.007' AS DateTime), 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Admin] OFF
GO
SET IDENTITY_INSERT [dbo].[BillDetails] ON 

INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (1, 1, N'Coca Cola 1.75 LTR', 3, CAST(8.000000 AS Decimal(18, 6)), CAST(24.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-11T17:49:29.300' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (2, 1, N'Coca Cola 1.5 LTR', 3, CAST(7.000000 AS Decimal(18, 6)), CAST(21.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-11T17:49:29.300' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (3, 2, N'Coca Cola 1.75 LTR', 2, CAST(8.000000 AS Decimal(18, 6)), CAST(16.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-11T17:49:53.800' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (4, 2, N'Coca Cola 1.5 LTR', 2, CAST(7.000000 AS Decimal(18, 6)), CAST(14.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-11T17:49:53.800' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (5, 3, N'Coca Cola 1.5 LTR', 3, CAST(7.000000 AS Decimal(18, 6)), CAST(21.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-12T14:43:01.600' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (6, 4, N'Coca Cola 1.75 LTR', 4, CAST(8.000000 AS Decimal(18, 6)), CAST(32.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-14T11:00:41.910' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (7, 5, N'Coca Cola 1.75 LTR', 4, CAST(8.000000 AS Decimal(18, 6)), CAST(32.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-15T14:09:13.263' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (8, 5, N'Coca Cola 1.75 LTR', 40, CAST(7.500000 AS Decimal(18, 6)), CAST(300.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-15T14:09:13.263' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (9, 6, N'Coca Cola 1.75 LTR', 5, CAST(8.000000 AS Decimal(18, 6)), CAST(40.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:19:09.983' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (10, 7, N'Mirinda Strawberry Can', 5, CAST(7.500000 AS Decimal(18, 6)), CAST(37.500000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:20:43.937' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (11, 8, N'Coca Cola 1.75 LTR', 2, CAST(8.000000 AS Decimal(18, 6)), CAST(16.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (12, 8, N'Coca Cola 1.5 LTR', 2, CAST(7.000000 AS Decimal(18, 6)), CAST(14.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (13, 8, N'Coca Cola 1.5 LTR', 3, CAST(7.000000 AS Decimal(18, 6)), CAST(21.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (14, 8, N'Coca Cola 1.75 LTR', 4, CAST(8.000000 AS Decimal(18, 6)), CAST(32.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (15, 8, N'Coca Cola 1.75 LTR', 40, CAST(7.500000 AS Decimal(18, 6)), CAST(300.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (16, 8, N'Redbull Can', 40, CAST(8.000000 AS Decimal(18, 6)), CAST(320.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (17, 8, N'Coca Cola 1.75 LTR', 5, CAST(8.000000 AS Decimal(18, 6)), CAST(40.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (18, 8, N'Mirinda Strawberry Can', 5, CAST(7.500000 AS Decimal(18, 6)), CAST(37.500000 AS Decimal(18, 6)), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (19, 9, N'Redbull Can', 5, CAST(8.000000 AS Decimal(18, 6)), CAST(40.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-17T15:57:30.907' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (20, 10, N'Kit Kat 4 Finger Milk Chocolate Bar 24*41.5g', 1, CAST(9.500000 AS Decimal(18, 6)), CAST(9.500000 AS Decimal(18, 6)), 3, CAST(N'2021-08-18T01:38:28.353' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (21, 10, N'Snickers Duo Chocolate Bars 32*83.4g', 1, CAST(18.000000 AS Decimal(18, 6)), CAST(18.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-18T01:38:28.353' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (22, 11, N'Cadbury Wispa Chocolate Bar - 48*36g', 1, CAST(22.000000 AS Decimal(18, 6)), CAST(22.000000 AS Decimal(18, 6)), 3, CAST(N'2021-08-18T01:40:51.820' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (23, 11, N'Ferrero Rocher Raffaello 4 Pack', 1, CAST(11.500000 AS Decimal(18, 6)), CAST(11.500000 AS Decimal(18, 6)), 3, CAST(N'2021-08-18T01:40:51.820' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (24, 12, N'Picnic Standard Bar - 36*48.4g', 5, CAST(19.000000 AS Decimal(18, 6)), CAST(95.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-01T19:52:54.613' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (25, 13, N'Skittles Fruits Bag £1 PMP - 12*125g', 1, CAST(8.000000 AS Decimal(18, 6)), CAST(8.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-01T19:55:05.850' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (26, 14, N'Kit Kat 4 Finger Milk Chocolate Bar 24*41.5g', 1, CAST(9.500000 AS Decimal(18, 6)), CAST(9.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (27, 14, N'Snickers Duo Chocolate Bars 32*83.4g', 1, CAST(18.000000 AS Decimal(18, 6)), CAST(18.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (28, 14, N'Cadbury Wispa Chocolate Bar - 48*36g', 1, CAST(22.000000 AS Decimal(18, 6)), CAST(22.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (29, 14, N'Ferrero Rocher Raffaello 4 Pack', 1, CAST(11.500000 AS Decimal(18, 6)), CAST(11.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (30, 14, N'Ferrero Rocher Raffaello 4 Pack', 4, CAST(11.500000 AS Decimal(18, 6)), CAST(46.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (31, 14, N'Cadbury Flake Chocolate Bar 48*32g', 6, CAST(22.500000 AS Decimal(18, 6)), CAST(135.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (32, 14, N'Skittles Crazy Sours Bags £1 PMP - 12*125g', 5, CAST(8.500000 AS Decimal(18, 6)), CAST(42.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (33, 14, N'Skittles Wild Berry Bags £1 PMP - 12*125g', 5, CAST(8.500000 AS Decimal(18, 6)), CAST(42.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (34, 14, N'Cheetos Crunchy Flamin'' Hot - 10 Pack', 3, CAST(32.000000 AS Decimal(18, 6)), CAST(96.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (35, 14, N'Polo Original Mints 32*34g', 3, CAST(11.500000 AS Decimal(18, 6)), CAST(34.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (36, 14, N'Hershey’s Sprinkles ‘N’ Creme Birthday Cake Bar - 24*39g', 4, CAST(14.500000 AS Decimal(18, 6)), CAST(58.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (37, 14, N'Skittles Crazy Sours Bags £1 PMP - 12*125g', 3, CAST(8.500000 AS Decimal(18, 6)), CAST(25.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (38, 14, N'Skittles Fruits Bag £1 PMP - 12*125g', 1, CAST(8.000000 AS Decimal(18, 6)), CAST(8.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (39, 14, N'Kit Kat Chunky Milk Chocolate Bar 40g', 4, CAST(13.500000 AS Decimal(18, 6)), CAST(54.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (40, 14, N'Picnic Standard Bar - 36*48.4g', 5, CAST(19.000000 AS Decimal(18, 6)), CAST(95.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (41, 14, N'Topic Chocolate Bar', 5, CAST(0.300000 AS Decimal(18, 6)), CAST(1.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (42, 14, N'Snickers White - 32*49g', 4, CAST(14.500000 AS Decimal(18, 6)), CAST(58.000000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (43, 15, N'Maltesers 25*37g', 5, CAST(11.500000 AS Decimal(18, 6)), CAST(57.500000 AS Decimal(18, 6)), 3, CAST(N'2021-09-10T15:20:45.563' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (67, 20, N'Milky Way Duo Chocolate Bars 28*43g', 3, CAST(11.500000 AS Decimal(18, 6)), CAST(34.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T18:36:14.420' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (68, 20, N'7up Soft Drink - 6 x 2.25L', 5, CAST(8.500000 AS Decimal(18, 6)), CAST(42.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T18:36:14.420' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (69, 21, N'Milky Way Duo Chocolate Bars 28*43g', 3, CAST(11.500000 AS Decimal(18, 6)), CAST(34.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T18:47:50.600' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (70, 21, N'7up Soft Drink - 6 x 2.25L', 5, CAST(8.500000 AS Decimal(18, 6)), CAST(42.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T18:47:50.600' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (71, 22, N'Milky Way Duo Chocolate Bars 28*43g', 3, CAST(11.500000 AS Decimal(18, 6)), CAST(34.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T19:29:47.203' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (72, 22, N'7up Soft Drink - 6 x 2.25L', 5, CAST(8.500000 AS Decimal(18, 6)), CAST(42.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T19:29:47.203' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (73, 23, N'Milky Way Duo Chocolate Bars 28*43g', 3, CAST(11.500000 AS Decimal(18, 6)), CAST(34.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T19:34:12.103' AS DateTime), NULL, NULL)
INSERT [dbo].[BillDetails] ([Id], [BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (74, 23, N'7up Soft Drink - 6 x 2.25L', 5, CAST(8.500000 AS Decimal(18, 6)), CAST(42.500000 AS Decimal(18, 6)), 3, CAST(N'2022-10-29T19:34:12.103' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[BillDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[Bills] ON 

INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (1, 2, 1, 5001, CAST(45.000000 AS Decimal(18, 6)), N'Brixton_5001_11/08/2021 05:49:29 PM', CAST(N'2021-08-11T17:49:29.550' AS DateTime), 3, CAST(N'2021-08-11T17:49:29.300' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (2, 1, 1, 5001, CAST(30.000000 AS Decimal(18, 6)), N'Croydon_5001_11/08/2021 05:49:54 PM', CAST(N'2021-08-11T17:49:54.087' AS DateTime), 3, CAST(N'2021-08-11T17:49:53.800' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (3, 1, 1, 5002, CAST(21.000000 AS Decimal(18, 6)), N'Croydon_5002_12/08/2021 02:43:01 PM', CAST(N'2021-08-12T14:43:01.593' AS DateTime), 3, CAST(N'2021-08-12T14:43:01.600' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (4, 1, 1, 5003, CAST(32.000000 AS Decimal(18, 6)), N'Croydon_5003_14/08/2021 11:00:40 AM', CAST(N'2021-08-14T11:00:40.240' AS DateTime), 3, CAST(N'2021-08-14T11:00:41.863' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (5, 1, 1, 5004, CAST(332.000000 AS Decimal(18, 6)), N'Croydon_5004_15/08/2021 03:09:13 PM', CAST(N'2021-08-15T15:09:13.260' AS DateTime), 3, CAST(N'2021-08-15T14:09:13.250' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (6, 1, 1, 5005, CAST(40.000000 AS Decimal(18, 6)), N'Croydon_5005_16/08/2021 06:19:10 PM', CAST(N'2021-08-16T18:19:10.063' AS DateTime), 3, CAST(N'2021-08-16T17:19:09.970' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (7, 1, 1, 5006, CAST(37.500000 AS Decimal(18, 6)), N'Croydon_5006_16/08/2021 06:20:44 PM', CAST(N'2021-08-16T18:20:44.170' AS DateTime), 3, CAST(N'2021-08-16T17:20:43.937' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (8, 1, 1, 5007, CAST(780.500000 AS Decimal(18, 6)), N'Croydon_5007_16/08/2021 06:40:04 PM', CAST(N'2021-08-16T18:40:04.147' AS DateTime), 3, CAST(N'2021-08-16T17:40:04.177' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (9, 1, 1, 5008, CAST(40.000000 AS Decimal(18, 6)), N'Customer1_5008_17/08/2021 04:57:30 PM', CAST(N'2021-08-17T16:57:30.957' AS DateTime), 3, CAST(N'2021-08-17T15:57:30.907' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (10, 3, 1, 5001, CAST(27.500000 AS Decimal(18, 6)), N'Customer1_5001_18/08/2021 02:38:28 AM', CAST(N'2021-08-18T02:38:28.543' AS DateTime), 3, CAST(N'2021-08-18T01:38:28.340' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (11, 3, 1, 5002, CAST(33.500000 AS Decimal(18, 6)), N'Customer1_5002_18/08/2021 02:40:52 AM', CAST(N'2021-08-18T02:40:52.090' AS DateTime), 3, CAST(N'2021-08-18T01:40:51.820' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (12, 3, 1, 5003, CAST(95.000000 AS Decimal(18, 6)), N'Customer01_5003_01/09/2021 08:52:54 PM', CAST(N'2021-09-01T20:52:54.800' AS DateTime), 3, CAST(N'2021-09-01T19:52:54.613' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (13, 3, 1, 5004, CAST(8.000000 AS Decimal(18, 6)), N'Customer01_5004_01/09/2021 08:55:06 PM', CAST(N'2021-09-01T20:55:06.137' AS DateTime), 3, CAST(N'2021-09-01T19:55:05.850' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (14, 3, 1, 5005, CAST(757.500000 AS Decimal(18, 6)), N'Customer01_5005_10/09/2021 04:18:27 PM', CAST(N'2021-09-10T16:18:27.017' AS DateTime), 3, CAST(N'2021-09-10T15:18:27.050' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (15, 3, 1, 5006, CAST(57.500000 AS Decimal(18, 6)), N'Customer01_5006_10/09/2021 04:20:45 PM', CAST(N'2021-09-10T16:20:45.667' AS DateTime), 3, CAST(N'2021-09-10T15:20:45.547' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (20, 3, 1, 5007, CAST(77.000000 AS Decimal(18, 6)), N'Customer01_5007_29/10/2022 02:06:14 PM', CAST(N'2022-10-29T14:06:14.657' AS DateTime), 3, CAST(N'2022-10-29T18:36:14.377' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (21, 3, 1, 5008, CAST(77.000000 AS Decimal(18, 6)), N'Customer01_5008_29/10/2022 02:17:51 PM', CAST(N'2022-10-29T14:17:51.277' AS DateTime), 3, CAST(N'2022-10-29T18:47:50.593' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (22, 3, 1, 5009, CAST(77.000000 AS Decimal(18, 6)), N'Customer01_5009_29/10/2022 02:59:47 PM', CAST(N'2022-10-29T14:59:47.913' AS DateTime), 3, CAST(N'2022-10-29T19:29:47.200' AS DateTime), NULL, NULL)
INSERT [dbo].[Bills] ([Id], [CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (23, 3, 1, 5010, CAST(77.000000 AS Decimal(18, 6)), N'Customer01_5010_29/10/2022 03:04:12 PM', CAST(N'2022-10-29T15:04:12.860' AS DateTime), 3, CAST(N'2022-10-29T19:34:12.100' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Bills] OFF
GO
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (1, 1, N'Drinks', N'', NULL, 2, CAST(N'2021-08-11T17:06:20.683' AS DateTime), NULL, NULL)
INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (2, 1, N'Sweet', N'', NULL, 2, CAST(N'2021-08-11T17:06:30.807' AS DateTime), NULL, NULL)
INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (3, 1, N'American Sweet', N'', NULL, 2, CAST(N'2021-08-18T22:10:24.773' AS DateTime), NULL, NULL)
INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (4, 1, N'American Drink', N'', NULL, 2, CAST(N'2021-08-18T22:10:32.990' AS DateTime), 2, CAST(N'2021-08-19T19:38:54.133' AS DateTime))
INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (5, 1, N'Lighter', N'', NULL, 2, CAST(N'2021-08-18T23:28:48.933' AS DateTime), NULL, NULL)
INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (6, 1, N'Filters', N'', NULL, 2, CAST(N'2021-08-18T23:35:07.123' AS DateTime), NULL, NULL)
INSERT [dbo].[Category] ([Id], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (7, 1, N'Rolling Papers', N'', NULL, 2, CAST(N'2021-08-18T23:38:47.653' AS DateTime), 2, CAST(N'2021-08-18T23:55:25.723' AS DateTime))
SET IDENTITY_INSERT [dbo].[Category] OFF
GO
SET IDENTITY_INSERT [dbo].[Company] ON 

INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (1, 1, 1, N'Coca Cola', N'', NULL, 2, CAST(N'2021-08-11T17:07:27.917' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (2, 1, 1, N'Pepsi', N'', NULL, 2, CAST(N'2021-08-11T22:04:50.493' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (3, 1, 1, N'Monten Dew', N'', NULL, 2, CAST(N'2021-08-11T22:05:07.633' AS DateTime), 2, CAST(N'2021-08-11T22:30:11.183' AS DateTime))
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (4, 1, 1, N'Mirinda', N'', NULL, 2, CAST(N'2021-08-11T22:05:45.823' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (5, 1, 1, N'Fanta', N'', NULL, 2, CAST(N'2021-08-11T22:07:10.247' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (6, 1, 1, N'7up', N'', NULL, 2, CAST(N'2021-08-11T22:10:37.677' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (7, 1, 1, N'Sprite', N'', NULL, 2, CAST(N'2021-08-11T22:11:26.770' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (8, 1, 1, N'Shani', N'', NULL, 2, CAST(N'2021-08-11T22:25:46.147' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (9, 4, 1, N'Calypso', N'', NULL, 2, CAST(N'2021-08-11T22:47:17.557' AS DateTime), 2, CAST(N'2022-10-16T00:45:25.363' AS DateTime))
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (10, 1, 1, N'Redbull', N'', NULL, 2, CAST(N'2021-08-11T22:54:56.270' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (11, 2, 1, N'Halls', N'', NULL, 2, CAST(N'2021-08-17T20:17:29.733' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (12, 2, 1, N'Mars', N'', NULL, 2, CAST(N'2021-08-17T20:57:29.020' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (13, 2, 1, N'Topic', N'', NULL, 2, CAST(N'2021-08-17T21:09:02.980' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (14, 2, 1, N'Snickers', N'', NULL, 2, CAST(N'2021-08-17T21:20:04.387' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (15, 2, 1, N'Kinder', N'', NULL, 2, CAST(N'2021-08-17T21:24:11.370' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (16, 2, 1, N'Cadbury', N'', NULL, 2, CAST(N'2021-08-17T21:30:26.697' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (17, 2, 1, N'Maltesers', N'', NULL, 2, CAST(N'2021-08-17T21:56:39.393' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (18, 2, 1, N'Galaxy', N'', NULL, 2, CAST(N'2021-08-17T22:00:59.733' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (19, 2, 1, N'Nestle', N'', NULL, 2, CAST(N'2021-08-17T22:40:47.220' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (20, 2, 1, N'Mars', N'', NULL, 2, CAST(N'2021-08-17T22:44:18.533' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (21, 2, 1, N'Reese''s', N'', NULL, 2, CAST(N'2021-08-17T22:46:26.147' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (22, 2, 1, N'Orbit', N'', NULL, 2, CAST(N'2021-08-17T23:00:14.450' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (23, 2, 1, N'Hershey''s', N'', NULL, 2, CAST(N'2021-08-17T23:30:29.630' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (24, 2, 1, N'Milky Way', N'', NULL, 2, CAST(N'2021-08-17T23:43:38.330' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (25, 2, 1, N'Starburst', N'', NULL, 2, CAST(N'2021-08-17T23:53:03.780' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (26, 2, 1, N'Trebor', N'', NULL, 2, CAST(N'2021-08-17T23:57:35.833' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (27, 2, 1, N'Daim', N'', NULL, 2, CAST(N'2021-08-18T00:00:45.010' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (28, 2, 1, N'Kit Kat', N'', NULL, 2, CAST(N'2021-08-18T00:16:43.073' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (29, 2, 1, N'Fruittella', N'', NULL, 2, CAST(N'2021-08-18T00:29:33.560' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (30, 2, 1, N'Chupa Chups', N'', NULL, 2, CAST(N'2021-08-18T00:36:07.857' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (31, 2, 1, N'Bounty', N'', NULL, 2, CAST(N'2021-08-18T00:40:46.967' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (32, 2, 1, N'M&M''s', N'', NULL, 2, CAST(N'2021-08-18T00:48:48.963' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (33, 2, 1, N'Skittles', N'', NULL, 2, CAST(N'2021-08-18T00:58:08.647' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (34, 2, 1, N'Eazy Pop', N'', NULL, 2, CAST(N'2021-08-18T01:08:11.053' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (35, 2, 1, N'Ferrero', N'', NULL, 2, CAST(N'2021-08-18T01:13:59.660' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (36, 2, 1, N'Cadbury', N'', NULL, 2, CAST(N'2021-08-18T01:17:22.293' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (37, 3, 1, N'Sour Patch', N'', NULL, 2, CAST(N'2021-08-18T22:20:14.093' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (38, 3, 1, N'Mike And Ike', N'', NULL, 2, CAST(N'2021-08-18T22:32:35.303' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (39, 3, 1, N'Nerds', N'', NULL, 2, CAST(N'2021-08-18T22:56:24.073' AS DateTime), 2, CAST(N'2021-08-19T19:39:21.807' AS DateTime))
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (40, 3, 1, N'Jolly Rancher', N'', NULL, 2, CAST(N'2021-08-18T22:57:52.777' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (41, 3, 1, N'Warheads', N'', NULL, 2, CAST(N'2021-08-18T23:01:17.010' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (42, 3, 1, N'Cheetos', N'', NULL, 2, CAST(N'2021-08-18T23:13:17.830' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (43, 3, 1, N'Hostess', N'', NULL, 2, CAST(N'2021-08-18T23:19:12.140' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (44, 5, 1, N'Clipper', N'Clipper Lighter x1.jpg', NULL, 2, CAST(N'2021-08-18T23:29:10.463' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (45, 6, 1, N'Swan', N'', NULL, 2, CAST(N'2021-08-18T23:35:25.183' AS DateTime), 2, CAST(N'2021-08-18T23:35:58.343' AS DateTime))
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (46, 7, 1, N'Raw', N'', NULL, 2, CAST(N'2021-08-18T23:39:00.293' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (47, 7, 1, N'OCB', N'', NULL, 2, CAST(N'2021-08-18T23:55:12.777' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (48, 7, 1, N'Rizla', N'', NULL, 2, CAST(N'2021-08-19T00:08:41.050' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (50, 4, 1, N'Dr Pepper', N'', NULL, 2, CAST(N'2021-08-19T20:17:26.213' AS DateTime), NULL, NULL)
INSERT [dbo].[Company] ([Id], [CategoryId], [DistributorId], [Name], [FilePath], [Description], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (51, 4, 1, N'C&C', N'', NULL, 2, CAST(N'2022-10-16T06:16:32.710' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Company] OFF
GO
SET IDENTITY_INSERT [dbo].[Customer] ON 

INSERT [dbo].[Customer] ([Id], [UserId], [DistributorId], [SerialNo], [StoreName], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (3, 6, 1, 1, N'Customer01', 2, 2, CAST(N'2021-08-17T20:23:59.557' AS DateTime), CAST(N'2021-08-19T22:24:25.020' AS DateTime))
INSERT [dbo].[Customer] ([Id], [UserId], [DistributorId], [SerialNo], [StoreName], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (4, 7, 1, 2, N'Customer02', 2, NULL, CAST(N'2021-08-17T20:24:24.870' AS DateTime), NULL)
INSERT [dbo].[Customer] ([Id], [UserId], [DistributorId], [SerialNo], [StoreName], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (5, 8, 1, 3, N'Latin food', 2, NULL, CAST(N'2021-09-10T15:31:52.670' AS DateTime), NULL)
INSERT [dbo].[Customer] ([Id], [UserId], [DistributorId], [SerialNo], [StoreName], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (6, 9, 1, 4, N'Latin food', 2, NULL, CAST(N'2021-09-10T15:32:23.733' AS DateTime), NULL)
INSERT [dbo].[Customer] ([Id], [UserId], [DistributorId], [SerialNo], [StoreName], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (7, 10, 1, 5, N'Yaso', 2, NULL, CAST(N'2022-10-16T10:47:41.230' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[Customer] OFF
GO
SET IDENTITY_INSERT [dbo].[Distributor] ON 

INSERT [dbo].[Distributor] ([Id], [Name], [UserId], [AdminId], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId]) VALUES (1, N'Invoice', 3, 1, CAST(N'2021-08-11T16:58:18.790' AS DateTime), NULL, 2, NULL)
SET IDENTITY_INSERT [dbo].[Distributor] OFF
GO
SET IDENTITY_INSERT [dbo].[OrderDetails] ON 

INSERT [dbo].[OrderDetails] ([Id], [OrderId], [StockDetailId], [QuantityDeliverd], [InsertedDate], [UpdatedDate]) VALUES (1, 4, 2, 30, CAST(N'2022-11-20T16:54:24.440' AS DateTime), CAST(N'2022-11-20T16:54:24.440' AS DateTime))
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [StockDetailId], [QuantityDeliverd], [InsertedDate], [UpdatedDate]) VALUES (2, 3, 1, 30, CAST(N'2022-11-20T16:54:24.440' AS DateTime), CAST(N'2022-11-20T16:54:24.440' AS DateTime))
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [StockDetailId], [QuantityDeliverd], [InsertedDate], [UpdatedDate]) VALUES (3, 1, 1, 10, CAST(N'2022-11-20T16:55:06.853' AS DateTime), CAST(N'2022-11-20T16:55:06.853' AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[OrderMaster] ON 

INSERT [dbo].[OrderMaster] ([Id], [DistributorId], [OrderStatusId], [ProductId], [CustomerId], [Quantity], [Price], [Total], [OrderDate], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [IsActive]) VALUES (1, 1, 3, 54, 4, 10, CAST(50.00 AS Decimal(18, 2)), CAST(500.00 AS Decimal(18, 2)), CAST(N'2022-11-20T16:53:42.133' AS DateTime), CAST(N'2022-11-20T16:53:42.143' AS DateTime), CAST(N'2022-11-20T16:55:06.853' AS DateTime), 7, 3, 1)
INSERT [dbo].[OrderMaster] ([Id], [DistributorId], [OrderStatusId], [ProductId], [CustomerId], [Quantity], [Price], [Total], [OrderDate], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [IsActive]) VALUES (2, 1, 1, 55, 4, 30, CAST(50.00 AS Decimal(18, 2)), CAST(1500.00 AS Decimal(18, 2)), CAST(N'2022-11-20T16:53:44.973' AS DateTime), CAST(N'2022-11-20T16:53:44.980' AS DateTime), CAST(N'2022-11-20T17:12:01.107' AS DateTime), 7, 3, 1)
INSERT [dbo].[OrderMaster] ([Id], [DistributorId], [OrderStatusId], [ProductId], [CustomerId], [Quantity], [Price], [Total], [OrderDate], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [IsActive]) VALUES (3, 1, 3, 54, 3, 30, CAST(50.00 AS Decimal(18, 2)), CAST(1500.00 AS Decimal(18, 2)), CAST(N'2022-11-20T16:54:02.747' AS DateTime), CAST(N'2022-11-20T16:54:02.743' AS DateTime), CAST(N'2022-11-20T16:54:24.440' AS DateTime), 6, 3, 1)
INSERT [dbo].[OrderMaster] ([Id], [DistributorId], [OrderStatusId], [ProductId], [CustomerId], [Quantity], [Price], [Total], [OrderDate], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [IsActive]) VALUES (4, 1, 3, 55, 3, 30, CAST(50.00 AS Decimal(18, 2)), CAST(1500.00 AS Decimal(18, 2)), CAST(N'2022-11-20T16:54:06.860' AS DateTime), CAST(N'2022-11-20T16:54:06.860' AS DateTime), CAST(N'2022-11-20T16:54:24.437' AS DateTime), 6, 3, 1)
INSERT [dbo].[OrderMaster] ([Id], [DistributorId], [OrderStatusId], [ProductId], [CustomerId], [Quantity], [Price], [Total], [OrderDate], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [IsActive]) VALUES (5, 1, 4, 54, 3, 10, CAST(50.00 AS Decimal(18, 2)), CAST(500.00 AS Decimal(18, 2)), CAST(N'2022-11-20T16:59:34.040' AS DateTime), CAST(N'2022-11-20T16:59:34.050' AS DateTime), CAST(N'2022-11-20T16:59:38.413' AS DateTime), 6, 6, 1)
INSERT [dbo].[OrderMaster] ([Id], [DistributorId], [OrderStatusId], [ProductId], [CustomerId], [Quantity], [Price], [Total], [OrderDate], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [IsActive]) VALUES (6, 1, 1, 54, 3, 10, CAST(50.00 AS Decimal(18, 2)), CAST(500.00 AS Decimal(18, 2)), CAST(N'2022-11-20T17:02:15.957' AS DateTime), CAST(N'2022-11-20T17:02:15.970' AS DateTime), NULL, 6, NULL, 1)
SET IDENTITY_INSERT [dbo].[OrderMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductMaster] ON 

INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (40, NULL, 11, 1, N'Halls Extra Strong - 20*33.5g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Halls_Extra_Strong.jpg', CAST(N'2021-08-17T20:25:03.277' AS DateTime), CAST(N'2021-08-19T22:01:50.603' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (41, NULL, 11, 1, N'Halls Coolwave - 20*33.5g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Halls_Coolwave.jpg', CAST(N'2021-08-17T20:43:07.187' AS DateTime), CAST(N'2021-08-19T22:01:57.103' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (42, NULL, 11, 1, N'Halls Honey & Lemon - 20*33.5g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Halls_Honey_&_Lemon.jpg', CAST(N'2021-08-17T20:44:10.437' AS DateTime), CAST(N'2021-08-19T22:02:02.900' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (43, NULL, 11, 1, N'Halls Lime Fresh - 20*33.5g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Halls_Lime_Fresh.jpg', CAST(N'2021-08-17T20:45:16.733' AS DateTime), CAST(N'2021-08-19T22:01:44.557' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (44, NULL, 12, 1, N'Mars Duo - 32*78.8g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mars_Duo.jpg', CAST(N'2021-08-17T21:06:11.560' AS DateTime), CAST(N'2021-08-19T22:02:07.917' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (46, NULL, 14, 1, N'Snickers White - 32*49g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Snickers_White.jpg', CAST(N'2021-08-17T21:21:32.900' AS DateTime), CAST(N'2021-09-10T15:18:12.253' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (47, NULL, 15, 1, N'Kinder Bueno White - 30*39g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Kinder_Bueno_White.jpg', CAST(N'2021-08-17T21:24:39.230' AS DateTime), CAST(N'2021-08-19T21:58:59.603' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (48, NULL, 16, 1, N'Picnic Standard Bar - 36*48.4g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Picnic_Standard_Bar.jpg', CAST(N'2021-08-17T21:31:29.640' AS DateTime), CAST(N'2021-09-01T19:58:19.327' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (50, NULL, 18, 1, N'Galaxy Smooth Milk Chocolate Bar - 24*42g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Galaxy_Smooth_Milk_Chocolate_Bar.jpg', CAST(N'2021-08-17T22:01:59.787' AS DateTime), CAST(N'2021-08-19T22:02:51.917' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (51, NULL, 18, 1, N'Galaxy Caramel Bar - 24*42g	', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Galaxy_Caramel.jpg', CAST(N'2021-08-17T22:37:18.127' AS DateTime), CAST(N'2021-08-19T22:01:36.760' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (52, NULL, 18, 1, N'Galaxy Cookie Crumble - 24*42g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'galaxy_cookie_crumble.jpg', CAST(N'2021-08-17T22:38:13.910' AS DateTime), CAST(N'2021-08-19T22:01:30.947' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (53, NULL, 19, 1, N'Yorkie Milk Chocolate Bars - 24*46g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Yorkie_46g.jpg', CAST(N'2021-08-17T22:41:41.573' AS DateTime), CAST(N'2021-08-19T22:01:25.603' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (54, NULL, 20, 1, N'Mars Chocolate Bars 40*51g', NULL, CAST(50.00 AS Decimal(18, 2)), 13, N'Mars_Chocolate_Bars_51g.jpg', CAST(N'2021-08-17T22:45:09.093' AS DateTime), CAST(N'2022-11-06T19:54:43.027' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (55, NULL, 21, 1, N'Reeses Nutrageous Bar 18*47g', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Reeses_Nutrageous_Bar_47g.jpg', CAST(N'2021-08-17T22:46:48.743' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (56, NULL, 22, 1, N'Orbit Blueberry 30*14g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'orbit_blueberry_14g.jpg', CAST(N'2021-08-17T23:00:32.137' AS DateTime), CAST(N'2021-08-19T22:00:42.117' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (57, NULL, 22, 1, N'Orbit Bubblemint 30*14g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'orbit_bubblemint_14g.jpeg', CAST(N'2021-08-17T23:01:23.763' AS DateTime), CAST(N'2021-08-19T22:00:21.557' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (58, NULL, 22, 1, N'Orbit Strawberry 30*14g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'orbit_strawberry_14g.jpg', CAST(N'2021-08-17T23:01:57.030' AS DateTime), CAST(N'2021-08-19T22:00:13.773' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (59, NULL, 22, 1, N'Orbit Orange 30*14g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'orbit_orange_14g.jpg', CAST(N'2021-08-17T23:02:18.560' AS DateTime), CAST(N'2021-08-19T22:00:07.790' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (60, NULL, 22, 1, N'Orbit Watermelon 30*14g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'orbit_watermelon_14g.jpeg', CAST(N'2021-08-17T23:02:40.620' AS DateTime), CAST(N'2021-08-19T22:00:01.867' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (61, NULL, 23, 1, N'Hershey''s Cookies ''N'' Creme Bars - 24*40g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Hersheys_Cookies_N_Creme_Bars_40g.jpg', CAST(N'2021-08-17T23:38:01.793' AS DateTime), CAST(N'2021-08-19T21:58:51.743' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (62, NULL, 23, 1, N'Hershey’s Sprinkles ‘N’ Creme Birthday Cake Bar - 24*39g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Hershey’s_Sprinkles_‘N’_Creme_Birthday_Cake_Bar_39g.jpg', CAST(N'2021-08-17T23:39:17.110' AS DateTime), CAST(N'2021-08-19T17:04:49.603' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (63, NULL, 23, 1, N'Hershey’s Strawberries ‘N’ Creme Bar - 24*39g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Hershey’s_Strawberries_‘N’_Creme_Bar_39g.jpg', CAST(N'2021-08-17T23:39:39.000' AS DateTime), CAST(N'2021-08-19T21:58:42.883' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (64, NULL, 23, 1, N'Hershey’s Cookies ‘N’ Mint Bar - 24*39g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Hershey’s_Cookies_‘N’_Mint_Bar_39g.jpg', CAST(N'2021-08-17T23:39:55.220' AS DateTime), CAST(N'2021-08-19T21:58:34.807' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (65, NULL, 23, 1, N'Hershey''s Milk Chocolate Bars - 24*40g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Hersheys_Milk_Chocolate_Bars_40g.jpg', CAST(N'2021-08-17T23:40:25.100' AS DateTime), CAST(N'2021-08-19T21:58:26.463' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (66, NULL, 24, 1, N'Milky Way Duo Chocolate Bars 28*43g', NULL, CAST(50.00 AS Decimal(18, 2)), 13, N'Milky_Way_Twin_Chocolate_Bars_43g.jpg', CAST(N'2021-08-17T23:44:15.580' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (67, NULL, 19, 1, N'Milkybar White Chocolate Bar 40*25g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Milkybar_White_Chocolate_Bar_25g.jpg', CAST(N'2021-08-17T23:47:02.833' AS DateTime), CAST(N'2021-08-19T21:58:02.707' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (68, NULL, 25, 1, N'Starburst Original Fruit Chews Bags 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Starburst_Original_Fruit_Chews_45g.jpg', CAST(N'2021-08-17T23:53:52.380' AS DateTime), CAST(N'2021-08-19T21:55:36.240' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (69, NULL, 25, 1, N'Starburst Fave Reds Fruit Chews 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Starburst_Fave_Reds_Fruit_Chews_45g.jpg', CAST(N'2021-08-17T23:54:54.600' AS DateTime), CAST(N'2021-08-19T21:55:26.083' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (70, NULL, 26, 1, N'Trebor Softmints Spearmint Mints Roll - 40*44.9g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Trebor_Softmints_Spearmint_Mints_Roll_44.9g.jpg', CAST(N'2021-08-17T23:58:08.603' AS DateTime), CAST(N'2021-08-19T21:55:04.193' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (71, NULL, 26, 1, N'Trebor Softmints Peppermint Mints Rolls - 40*44.9g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Trebor_Softmints_Peppermint_Mints_Rolls_44.9g.jpg', CAST(N'2021-08-17T23:58:39.057' AS DateTime), CAST(N'2021-08-19T21:54:54.130' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (72, NULL, 27, 1, N'Daim Bar 36*28g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'daim_bar_28g.jpg', CAST(N'2021-08-18T00:01:33.623' AS DateTime), CAST(N'2021-08-19T21:54:42.490' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (73, NULL, 11, 1, N'Halls Soothers Strawberry Flavour - 20*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Halls_Soothers_Strawberry_Flavour_45g.jpg', CAST(N'2021-08-18T00:04:23.977' AS DateTime), CAST(N'2021-08-19T21:54:34.490' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (74, NULL, 11, 1, N'Halls Soothers Honey & Lemon 20*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Halls_Soothers_Honey_&_Lemon_45g.jpg', CAST(N'2021-08-18T00:04:48.350' AS DateTime), CAST(N'2021-08-19T21:54:24.287' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (75, NULL, 19, 1, N'Aero Peppermint Mint Chocolate Bar - 24*36g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Aero_Peppermint_Mint_Chocolate_Bar_36g.jpg', CAST(N'2021-08-18T00:07:42.520' AS DateTime), CAST(N'2021-08-19T21:53:25.910' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (76, NULL, 19, 1, N'Aero Milk Chocolate Bar - 24*36g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Aero_Milk_Chocolate_Bar_36g.jpg', CAST(N'2021-08-18T00:08:26.740' AS DateTime), CAST(N'2021-08-19T21:53:08.707' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (77, NULL, 14, 1, N'Snickers Duo Chocolate Bars 32*83.4g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Snickers_Duo_Chocolate_Bars_83.4g.jpg', CAST(N'2021-08-18T00:10:23.317' AS DateTime), CAST(N'2021-08-19T21:46:06.157' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (78, NULL, 28, 1, N'Kit Kat 4 Finger Milk Chocolate Bar 24*41.5g', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Kit_Kat_4_Finger_Milk_Chocolate_Bar_41.5g.jpg', CAST(N'2021-08-18T00:19:40.927' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (79, NULL, 28, 1, N'Kit Kat 4 Finger White Chocolate Bar 24*41.5g', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Kit_Kat_4_Finger_White_Chocolate_Bar_41.5g.jpg', CAST(N'2021-08-18T00:20:14.817' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (80, NULL, 28, 1, N'Kit Kat Chunky Milk Chocolate Bar 40g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Kit_Kat_Chunky_Milk_Chocolate_Bar_40g.jpg', CAST(N'2021-08-18T00:21:45.413' AS DateTime), CAST(N'2021-09-10T15:18:12.253' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (81, NULL, 28, 1, N'Kit Kat Chunky Peanut Butter Chocolate Bar 36*42g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Kit_Kat_Chunky_Peanut_Butter_Chocolate_Bar_42g.jpg', CAST(N'2021-08-18T00:22:27.990' AS DateTime), CAST(N'2021-08-19T21:52:34.323' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (82, NULL, 28, 1, N'Kit Kat Chunky White Chocolate Bar 36*40g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'kit_kat_chunky_white_40g.png', CAST(N'2021-08-18T00:23:06.630' AS DateTime), CAST(N'2021-08-19T21:52:21.573' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (83, NULL, 29, 1, N'Fruittella Sour Stick - 40*41g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fruittella_sour_41g.jpg', CAST(N'2021-08-18T00:29:58.040' AS DateTime), CAST(N'2021-08-19T21:52:03.680' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (84, NULL, 29, 1, N'Fruittella Blackcurrant Stick - 40*41g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'fruittella_Blackcurrant_Stick.jpg', CAST(N'2021-08-18T00:30:25.853' AS DateTime), CAST(N'2021-08-19T21:51:51.540' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (85, NULL, 29, 1, N'Fruittella Summer Fruits Stick - 40*41g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fruittella_Summer_Fruits_Stick_41g.jpg', CAST(N'2021-08-18T00:30:46.527' AS DateTime), CAST(N'2021-08-19T21:51:17.853' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (86, NULL, 30, 1, N'Chupa Chups Bag - 120p', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'chupa_chups_bag_120.jpg', CAST(N'2021-08-18T00:36:46.173' AS DateTime), CAST(N'2021-08-19T21:50:35.103' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (87, NULL, 31, 1, N'Bounty Coconut Milk Chocolate Twin Bar - 24*57g', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Bounty_Coconut_Milk_Chocolate_Twin_Bar_57g.jpg', CAST(N'2021-08-18T00:41:16.200' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (88, NULL, 31, 1, N'Bounty Coconut Milk Chocolate Trio Bar - 21*85g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Bounty_Coconut_Milk_Chocolate_Trio_Bar_85g.jpg', CAST(N'2021-08-18T00:41:47.497' AS DateTime), CAST(N'2021-08-19T21:50:15.400' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (89, NULL, 31, 1, N'Bounty Dark Chocolate Twin Bars - 24*57g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Bounty_Dark_Chocolate_Twin_Bars_57g.jpg', CAST(N'2021-08-18T00:42:13.560' AS DateTime), CAST(N'2021-08-19T21:50:00.147' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (90, NULL, 14, 1, N'Snickers Chocolate Bar - 40*50g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Snickers_Chocolate_Bar_50g.jpg', CAST(N'2021-08-18T00:42:47.043' AS DateTime), CAST(N'2021-08-19T21:49:51.180' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (91, NULL, 19, 1, N'Lion Milk Chocolate Duo Bar - 28*60g', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Lion_Milk_Chocolate_Duo_Bar_60g.jpg', CAST(N'2021-08-18T00:45:08.310' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (92, NULL, 15, 1, N'Kinder Bueno Bar', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Kinder_Bueno_Bar.jpg', CAST(N'2021-08-18T00:47:38.780' AS DateTime), CAST(N'2021-08-19T21:49:14.273' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (93, NULL, 32, 1, N'M&M''s Peanut Chocolate Bags - 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 12, N'M&Ms_Peanut_Chocolate_Bags_45g.jpg', CAST(N'2021-08-18T00:53:24.687' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (94, NULL, 32, 1, N'M&M''s Chocolate Bags - 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'M&Ms_Chocolate_Bags_45g.jpg', CAST(N'2021-08-18T00:53:47.547' AS DateTime), CAST(N'2021-08-19T21:48:51.757' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (95, NULL, 32, 1, N'M&M''s Crispy Chocolate Bag - 24*36g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'M&Ms_Crispy_Chocolate_Bag_36g.jpg', CAST(N'2021-08-18T00:54:10.437' AS DateTime), CAST(N'2021-08-19T21:48:39.380' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (96, NULL, 19, 1, N'Polo Original Mints 32*34g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Polo_Original_Mints_34g.jpg', CAST(N'2021-08-18T00:55:29.143' AS DateTime), CAST(N'2021-08-19T21:44:34.560' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (97, NULL, 33, 1, N'Skittles Fruit - 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Fruit_45g.jpg', CAST(N'2021-08-18T00:59:00.213' AS DateTime), CAST(N'2021-08-19T21:48:24.617' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (98, NULL, 33, 1, N'Skittles Tropical - 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Tropical_45g.jpg', CAST(N'2021-08-18T00:59:26.417' AS DateTime), CAST(N'2021-08-19T21:48:13.913' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (99, NULL, 33, 1, N'Skittles Crazy Sours - 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Crazy_Sours_45g.jpg', CAST(N'2021-08-18T00:59:46.557' AS DateTime), CAST(N'2021-08-19T21:47:45.770' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (100, NULL, 33, 1, N'Skittles Wild Berry - 24*45g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Wild_Berry_45g.jpg', CAST(N'2021-08-18T01:00:12.480' AS DateTime), CAST(N'2021-08-19T21:47:35.833' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (101, NULL, 33, 1, N'Skittles Fruits Bag £1 PMP - 12*125g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Fruits_Bag_£1_PMP.jpg', CAST(N'2021-08-18T01:03:40.117' AS DateTime), CAST(N'2021-08-19T21:07:29.783' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (102, NULL, 33, 1, N'Skittles Crazy Sours Bags £1 PMP - 12*125g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Crazy_Sours_Bags_£1_PMP.jpg', CAST(N'2021-08-18T01:04:03.790' AS DateTime), CAST(N'2021-08-19T21:08:33.643' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (103, NULL, 33, 1, N'Skittles Tropical Bags £1 PMP - 12*125g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Tropical_Bag_125g_PMP.png', CAST(N'2021-08-18T01:04:24.023' AS DateTime), CAST(N'2021-08-19T21:39:03.733' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (104, NULL, 33, 1, N'Skittles Wild Berry Bags £1 PMP - 12*125g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Skittles_Wild_Berry_Bags_£1_PMP.jpg', CAST(N'2021-08-18T01:04:48.147' AS DateTime), CAST(N'2021-08-19T21:45:19.673' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (105, NULL, 34, 1, N'Eazy Pop Salted Popcorn - 16*85g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'easy_pop_salted.jpg', CAST(N'2021-08-18T01:10:58.183' AS DateTime), CAST(N'2021-08-19T21:47:22.007' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (106, NULL, 34, 1, N'Easy Pop Sweet Popcorn - 16*85g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'easy_pop_sweet_popcorn.jpg', CAST(N'2021-08-18T01:11:40.837' AS DateTime), CAST(N'2021-08-19T21:47:11.207' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (107, NULL, 34, 1, N'Easy Pop Butter Popcorn - 16*85g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'easy_pop_butter_popcorn.jpg', CAST(N'2021-08-18T01:11:57.060' AS DateTime), CAST(N'2021-08-19T21:47:00.643' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (108, NULL, 35, 1, N'Ferrero Rocher Raffaello 4 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Ferrero_Rocher_Raffaello.jpg', CAST(N'2021-08-18T01:14:33.533' AS DateTime), CAST(N'2021-08-19T21:29:19.363' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (109, NULL, 36, 1, N'Cadbury Wispa Chocolate Bar - 48*36g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Cadbury_Wispa_Chocolate_Bar_36g.jpg', CAST(N'2021-08-18T01:17:45.787' AS DateTime), CAST(N'2021-08-19T21:45:31.627' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (110, NULL, 36, 1, N'Cadbury Flake Chocolate Bar 48*32g', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Cadbury_Flake_Chocolate_Bar_32g.jpg', CAST(N'2021-08-18T01:18:55.310' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (111, NULL, 19, 1, N'Smarties Milk Chocolate Tube 24*38g', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Smarties_Milk_Chocolate_Tube_38g.jpg', CAST(N'2021-08-18T01:20:15.693' AS DateTime), CAST(N'2021-08-19T21:46:48.767' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (112, NULL, 37, 1, N'Sour Patch Kids - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Sour_Patch_Kids_-_12_pack.png', CAST(N'2021-08-18T22:21:31.097' AS DateTime), CAST(N'2021-08-19T21:29:10.253' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (113, NULL, 37, 1, N'sour Patch Extreme - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Sour_Patch_Extreme_-_12_pack.jpg', CAST(N'2021-08-18T22:22:47.627' AS DateTime), CAST(N'2021-08-19T21:28:56.427' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (114, NULL, 37, 1, N'Sour Patch Tropical - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Sour_Patch_Topical_-_12_pack.jpg', CAST(N'2021-08-18T22:24:42.803' AS DateTime), CAST(N'2021-08-19T21:28:43.770' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (115, NULL, 37, 1, N'Sour Patch Watermelon - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Sour_Patch_Watermelon_-_12_pack.jpg', CAST(N'2021-08-18T22:25:00.617' AS DateTime), CAST(N'2021-08-19T21:28:18.630' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (116, NULL, 38, 1, N'Mike And Ike Original Fruits - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Original_Fruits_-_12_Pack.jpg', CAST(N'2021-08-18T22:34:07.607' AS DateTime), CAST(N'2021-08-19T21:33:50.723' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (117, NULL, 38, 1, N'Mike And Ike Jolly Joes Grape - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Jolly_Joes_Grape.jpg', CAST(N'2021-08-18T22:34:37.843' AS DateTime), CAST(N'2021-08-19T21:27:54.033' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (118, NULL, 38, 1, N'Mike And Ike Mega Mix Sour - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Mega_Mix_Sour.png', CAST(N'2021-08-18T22:34:59.157' AS DateTime), CAST(N'2021-08-19T17:03:32.497' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (119, NULL, 38, 1, N'Mike And Ike Berry Blast - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Berry_Blast.jpg', CAST(N'2021-08-18T22:35:16.453' AS DateTime), CAST(N'2021-08-19T21:27:45.753' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (120, NULL, 38, 1, N'Mike And Ike Root Beer - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Root_Beer.png', CAST(N'2021-08-18T22:35:39.563' AS DateTime), CAST(N'2021-08-19T21:27:35.723' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (121, NULL, 38, 1, N'Mike And Ike Red Rageous - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Red_Rageous.jpg', CAST(N'2021-08-18T22:36:01.393' AS DateTime), CAST(N'2021-08-19T21:27:23.377' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (122, NULL, 38, 1, N'Mike And Ike Mega Mix - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Mega_Mix.jpg', CAST(N'2021-08-18T22:36:21.080' AS DateTime), CAST(N'2021-08-19T21:26:54.503' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (123, NULL, 38, 1, N'Mike And Ike Tropical Typhoon - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Tropical_Typhoon.jpg', CAST(N'2021-08-18T22:36:41.033' AS DateTime), CAST(N'2021-08-19T21:26:37.127' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (124, NULL, 38, 1, N'Mike And Ike Cotton Candy - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mike_And_Ike_Cotton_Candy.jpg', CAST(N'2021-08-18T22:37:05.020' AS DateTime), CAST(N'2021-08-19T21:26:06.770' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (125, NULL, 38, 1, N'Swedish Fish Assorted - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Swedish_Fish_Assorted.jpg', CAST(N'2021-08-18T22:45:08.713' AS DateTime), CAST(N'2021-08-19T21:25:53.643' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (126, NULL, 39, 1, N'Nerds Rainbow - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Nerds_Rainbow.jpg', CAST(N'2021-08-18T22:56:43.143' AS DateTime), CAST(N'2021-08-19T21:25:36.793' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (127, NULL, 40, 1, N'Jolly Rancher Gummies Original - 11 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Jolly_Rancher_Gummies_Original.jpg', CAST(N'2021-08-18T22:58:32.813' AS DateTime), CAST(N'2021-08-19T21:25:09.073' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (128, NULL, 41, 1, N'Warheads Sour Jelly Beans - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Warheads_Sour_Jelly_Beans.jpg', CAST(N'2021-08-18T23:02:31.620' AS DateTime), CAST(N'2021-08-19T21:24:58.730' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (129, NULL, 41, 1, N'Warheads Sour Worms - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Warheads_Sour_Worms.jpg', CAST(N'2021-08-18T23:02:53.587' AS DateTime), CAST(N'2021-08-19T21:24:48.040' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (130, NULL, 41, 1, N'Warheads Sour Twists - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Warheads_Sour_Twists.jpg', CAST(N'2021-08-18T23:03:23.383' AS DateTime), CAST(N'2021-08-19T21:24:37.650' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (131, NULL, 42, 1, N'Cheetos Crunchy Flamin'' Hot - 44 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Cheetos_Crunchy_Flamin_Hot_Flavour_-_44_pack.jpg', CAST(N'2021-08-18T23:14:01.687' AS DateTime), CAST(N'2021-08-19T21:24:26.087' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (132, NULL, 42, 1, N'Cheetos Crunchy Flamin'' Hot - 10 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Cheetos_Crunchy_Flamin_Hot_-_10_Pack.png', CAST(N'2021-08-18T23:14:51.687' AS DateTime), CAST(N'2021-08-19T20:52:58.253' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (133, NULL, 43, 1, N'Hostess Twinkies Mixed Berry - 10 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'HOSTESS-_MIXED_BERRY_TWINKIES.png', CAST(N'2021-08-18T23:19:46.050' AS DateTime), CAST(N'2021-08-19T21:24:00.633' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (134, NULL, 43, 1, N'Hostess Twinkies Banana - 10 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'HOSTESS-BANANA_TWINKIES.jpg', CAST(N'2021-08-18T23:20:03.097' AS DateTime), CAST(N'2021-08-19T21:23:51.463' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (135, NULL, 43, 1, N'Hostess Twinkies Orginal - 10 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'HOSTESS_TWINKIES-_ORGINAL.png', CAST(N'2021-08-18T23:20:22.973' AS DateTime), CAST(N'2021-08-19T21:23:42.603' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (136, NULL, 40, 1, N'Jolly Rancher Lollipops - 50 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Jolly_Rancher_Lollipops_-_50_Count.jpg', CAST(N'2021-08-18T23:23:11.397' AS DateTime), CAST(N'2021-08-19T21:21:48.240' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (137, NULL, 44, 1, N'Clipper Printed Lighter x1', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Clipper_Lighter_x1.jpg', CAST(N'2021-08-18T23:29:27.570' AS DateTime), CAST(N'2021-08-19T21:21:38.663' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (138, NULL, 44, 1, N'Clipper Lighter x1', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Clipper_Lighter_Simple.jpg', CAST(N'2021-08-18T23:30:57.697' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (139, NULL, 45, 1, N'Swan Extra Slim Filters', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'SWAN_EXTRA_SLIM_POP-A-TIP_FILTERS.jpg', CAST(N'2021-08-18T23:36:35.860' AS DateTime), CAST(N'2021-08-19T21:20:42.740' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (140, NULL, 45, 1, N'Swan Slim Filters', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'SWAN_SLIM_POP-A-TIP_FILTERS.jpg', CAST(N'2021-08-18T23:37:29.783' AS DateTime), CAST(N'2021-08-19T21:22:31.743' AS DateTime), 2, 2, 0)
GO
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (141, NULL, 45, 1, N'Swan Extra Slim Menthol Filters', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'SWAN_EXTRA_SLIM_MENTHOL_POP-A-TIP_FILTERS.jpg', CAST(N'2021-08-18T23:37:54.500' AS DateTime), CAST(N'2021-08-19T21:18:37.123' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (142, NULL, 46, 1, N'Raw Authentic Original Tips', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'RAW_AUTHENTIC_ORIGINAL_TIPS.jpg', CAST(N'2021-08-18T23:47:21.453' AS DateTime), CAST(N'2021-08-19T21:18:01.857' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (143, NULL, 46, 1, N'Raw Classic Kingsize Slim Papers', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'RAW_CLASSIC_KINGSIZE_SLIM_PAPERS.jpg', CAST(N'2021-08-18T23:47:48.140' AS DateTime), CAST(N'2021-08-19T21:17:52.950' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (144, NULL, 46, 1, N'Raw Classic Connoisseur Kingsize Slim Papers + Tips', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'RAW_CLASSIC_KINGSIZE_SLIM_PAPERS_PLUS_TIPS.jpg', CAST(N'2021-08-18T23:48:57.813' AS DateTime), CAST(N'2021-08-19T21:17:43.577' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (145, NULL, 46, 1, N'Raw Organic Kingsize Slim Papers', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Raw_Organic_King_Sizeslim_Papers.jpg', CAST(N'2021-08-18T23:51:13.127' AS DateTime), CAST(N'2021-08-19T21:17:29.467' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (146, NULL, 46, 1, N'Raw Black Kingsize Slim Papers', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Raw_Black_Kingsize_Slim_Papers.jpg', CAST(N'2021-08-18T23:54:00.923' AS DateTime), CAST(N'2021-08-19T21:17:14.857' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (147, NULL, 47, 1, N'OCB Black Rolling Papers', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'OCB_Black_Rolling_Papers.jpg', CAST(N'2021-08-18T23:55:56.913' AS DateTime), CAST(N'2021-08-19T21:17:06.623' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (148, NULL, 48, 1, N'Rizla Blue Thin Rolling Papers - King Size', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Rizla_Blue_Thin_Rolling_Papers_32_Pack_-_King_Size.jpg', CAST(N'2021-08-19T00:09:35.590' AS DateTime), CAST(N'2021-08-19T21:16:39.183' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (149, NULL, 48, 1, N'Rizla Blue Thin Rolling Papers - Regular', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Rizla_Blue_Thin_Rolling_Papers_50_Pack_-_Regular.jpg', CAST(N'2021-08-19T00:09:55.903' AS DateTime), CAST(N'2021-08-19T21:16:30.013' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (150, NULL, 48, 1, N'Rizla Green Medium Thin Rolling Papers - King Size', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Rizla_Green_Medium_Thin_Rolling_Papers_50_Pack_-_King_Size.jpg', CAST(N'2021-08-19T00:10:20.890' AS DateTime), CAST(N'2021-08-19T21:16:20.010' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (151, NULL, 48, 1, N'Rizla Green Medium Thin Rolling Papers - Regular', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Rizla_Green_Medium_Thin_Rolling_Papers_50_Pack_-_Regular.jpg', CAST(N'2021-08-19T00:10:49.953' AS DateTime), CAST(N'2021-08-19T21:16:10.637' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (152, NULL, 48, 1, N'Rizla Silver Super Thin Rolling Papers - King Size', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Rizla_Silver_Super_Thin_Rolling_Papers_32_Pack_-_King_Size.jpg', CAST(N'2021-08-19T00:11:17.500' AS DateTime), CAST(N'2021-08-19T21:16:03.853' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (153, NULL, 48, 1, N'Rizla Silver Super Thin Rolling Papers - Regular', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Rizla_Silver_Super_Thin_Rolling_Papers_50_Pack_-_Regular.jpg', CAST(N'2021-08-19T00:11:41.873' AS DateTime), CAST(N'2021-08-19T21:15:55.417' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (154, NULL, 2, 1, N'Pepsi Soft Drink - 6 x 2.25L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(2).png', CAST(N'2021-08-19T00:30:05.577' AS DateTime), CAST(N'2022-10-15T22:13:36.550' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (155, NULL, 3, 1, N'Mountain Dew Soft Drink - 6 x 2.25L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(5).png', CAST(N'2021-08-19T00:30:33.437' AS DateTime), CAST(N'2022-10-15T22:13:06.000' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (156, NULL, 4, 1, N'Mirinda Orange Soft Drink - 6 x 2.25L', NULL, CAST(50.00 AS Decimal(18, 2)), 12, N'Products_(4).png', CAST(N'2021-08-19T00:30:51.767' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (157, NULL, 6, 1, N'7up Soft Drink - 6 x 2.25L', NULL, CAST(50.00 AS Decimal(18, 2)), 15, N'Products_(3).png', CAST(N'2021-08-19T00:31:11.093' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (158, NULL, 4, 1, N'Mirinda Strawberry Soft Drink - 6 x 2L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(6).png', CAST(N'2021-08-19T00:38:49.443' AS DateTime), CAST(N'2022-10-15T22:12:46.240' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (159, NULL, 1, 1, N'Coca Cola (Coke) Soft Drink - 6 x 1.75L', NULL, CAST(50.00 AS Decimal(18, 2)), 15, N'Products_(11).png', CAST(N'2021-08-19T00:46:59.727' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (160, NULL, 5, 1, N'Fanta Shokata - 6*1.75L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'fanta_shokata_1.75_liter.png', CAST(N'2021-08-19T00:47:41.553' AS DateTime), CAST(N'2021-08-19T21:14:15.357' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (161, NULL, 5, 1, N'Fanta Orange - 6*1.75L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'fanta_orange1.75_liter.png', CAST(N'2021-08-19T00:48:02.837' AS DateTime), CAST(N'2021-08-19T21:14:09.700' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (162, NULL, 5, 1, N'Fanta Lemon Soft Drink - 6 x 1.75L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(7).png', CAST(N'2021-08-19T00:48:26.447' AS DateTime), CAST(N'2022-10-15T22:12:34.590' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (163, NULL, 7, 1, N'Sprite Soft Drink - 6 x 2L', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Products_(9).png', CAST(N'2021-08-19T00:48:46.540' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (164, NULL, 1, 1, N'Coca Cola (Coke) Soft Drink - 6 x 1.50L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(12).png', CAST(N'2021-08-19T00:51:02.957' AS DateTime), CAST(N'2022-10-15T22:27:50.437' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (165, NULL, 5, 1, N'Fanta Blue Shokata Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(17).png', CAST(N'2021-08-19T01:04:03.620' AS DateTime), CAST(N'2022-10-15T22:40:15.370' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (166, NULL, 5, 1, N'Fanta Orange Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(18).png', CAST(N'2021-08-19T01:05:04.583' AS DateTime), CAST(N'2022-10-15T22:42:00.177' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (167, NULL, 5, 1, N'Fanta Lemon - 12*500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Lemon_500ml.jpg', CAST(N'2021-08-19T01:05:26.823' AS DateTime), CAST(N'2021-08-19T21:12:47.137' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (168, NULL, 4, 1, N'Mirinda Orange - 12*500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'mirinda_orange_500ml.jpg', CAST(N'2021-08-19T01:06:17.557' AS DateTime), CAST(N'2021-08-19T21:05:42.450' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (169, NULL, 4, 1, N'Mirinda Citrus - 12*500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'mirinda_Citrus_500ml.jpg', CAST(N'2021-08-19T01:06:43.727' AS DateTime), CAST(N'2021-08-19T21:04:47.933' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (170, NULL, 4, 1, N'Mirinda Orange - 24*500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'mirinda_orange_500ml.jpg', CAST(N'2021-08-19T01:07:15.803' AS DateTime), CAST(N'2021-08-19T21:05:03.433' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (171, NULL, 4, 1, N'Mirinda Citrus - 24*500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'mirinda_Citrus_500ml.jpg', CAST(N'2021-08-19T01:07:41.487' AS DateTime), CAST(N'2021-08-19T21:04:42.167' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (172, NULL, 3, 1, N'Mountain Dew Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(19).png', CAST(N'2021-08-19T01:08:01.557' AS DateTime), CAST(N'2022-10-15T22:43:56.420' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (173, NULL, 8, 1, N'Shani Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(16).png', CAST(N'2021-08-19T01:08:56.377' AS DateTime), CAST(N'2022-10-15T22:38:01.383' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (174, NULL, 7, 1, N'Sprite - 12*500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Sprite_500ml.jpg', CAST(N'2021-08-19T01:09:25.780' AS DateTime), CAST(N'2021-08-19T21:02:58.363' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (175, NULL, 1, 1, N'Coca Cola (Coke) Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 16, N'Products_(13).png', CAST(N'2021-08-19T01:09:55.227' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (176, NULL, 10, 1, N'Redbull Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 13, N'Products_(36).png', CAST(N'2021-08-19T01:23:50.460' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (177, NULL, 1, 1, N'Coca Cola (Coke) Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 13, N'Products_(26).png', CAST(N'2021-08-19T01:27:48.340' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (179, NULL, 5, 1, N'Fanta Orange Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Products_(32).png', CAST(N'2021-08-19T01:29:43.827' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (180, NULL, 5, 1, N'Fanta Lemon Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Products_(31).png', CAST(N'2021-08-19T01:30:08.110' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (181, NULL, 5, 1, N'Fanta Fruit Twist Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Products_(30).png', CAST(N'2021-08-19T01:31:00.767' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (182, NULL, 1, 1, N'Coca Cola (Diet Coke) Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(27).png', CAST(N'2021-08-19T01:32:43.433' AS DateTime), CAST(N'2022-10-15T23:27:07.377' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (183, NULL, 1, 1, N'Coca Cola (Zero Coke) Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 11, N'Products_(28).png', CAST(N'2021-08-19T01:33:01.963' AS DateTime), CAST(N'2022-11-06T19:33:48.787' AS DateTime), 2, 3, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (184, NULL, 2, 1, N'Pepsi Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(35).png', CAST(N'2021-08-19T01:33:35.967' AS DateTime), CAST(N'2022-10-16T00:06:57.867' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (185, NULL, 6, 1, N'7up Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(25).png', CAST(N'2021-08-19T01:33:59.733' AS DateTime), CAST(N'2022-10-15T23:24:47.393' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (186, NULL, 4, 1, N'Mirinda Orange Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(33).png', CAST(N'2021-08-19T01:34:30.437' AS DateTime), CAST(N'2022-10-16T00:01:18.123' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (187, NULL, 4, 1, N'Mirinda Strawberry Soft Drink Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(34).png', CAST(N'2021-08-19T01:35:07.720' AS DateTime), CAST(N'2022-10-16T00:03:19.140' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (188, NULL, 7, 1, N'Sprite Can - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Sprite_Can.jpg', CAST(N'2021-08-19T01:35:35.580' AS DateTime), CAST(N'2021-08-19T20:53:46.820' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (189, NULL, 9, 1, N'Calypso Ocean Blue Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(38).png', CAST(N'2021-08-19T19:36:40.160' AS DateTime), CAST(N'2022-10-16T00:44:30.287' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (190, NULL, 50, 1, N'Dr Pepper & Cream Soda Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Dr_Pepper_&_Cream_Soda_Can_-_12_Pack.png', CAST(N'2021-08-19T20:17:59.773' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (191, NULL, 50, 1, N'Dr Pepper Vanilla Float Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Dr_Pepper_Vanilla_Float.png', CAST(N'2021-08-19T20:18:31.430' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (192, NULL, 1, 1, N'Coca Cola (Coke) Cherry Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Coca-Cola_Cherry.jpg', CAST(N'2021-08-19T20:20:34.467' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (193, NULL, 1, 1, N'Coca Cola (Coke) Vanilla Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Coca_Cola_Vanilla.png', CAST(N'2021-08-19T20:21:33.577' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (194, NULL, 3, 1, N'Mountain Dew-S-A Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mountain_Dew-S-A.png', CAST(N'2021-08-19T20:22:09.187' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (195, NULL, 3, 1, N'Mountain Dew Major Melon Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Mountain_Dew_Major_Melon_Can_-_12_Pack.png', CAST(N'2021-08-19T20:23:35.813' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (196, NULL, 5, 1, N'Fanta Mango Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Mango.png', CAST(N'2021-08-19T20:24:10.830' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (197, NULL, 5, 1, N'Fanta Pineapple Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Pineapple.png', CAST(N'2021-08-19T20:24:29.300' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (198, NULL, 5, 1, N'Fanta Peach Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Peach.png', CAST(N'2021-08-19T20:24:46.407' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (199, NULL, 5, 1, N'Fanta Berry Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Berry.png', CAST(N'2021-08-19T20:25:04.643' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (200, NULL, 5, 1, N'Fanta Grapefruit Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Grapefruit_Can_355ml.jpg', CAST(N'2021-08-19T20:25:26.563' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (201, NULL, 5, 1, N'Fanta Grape Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Grape.png', CAST(N'2021-08-19T20:26:05.100' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (202, NULL, 5, 1, N'Fanta Strawberry Can - 12 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Fanta_Strawberry.png', CAST(N'2021-08-19T20:27:11.647' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (203, NULL, 2, 1, N'Pepsi Glass Bottle - 24x250ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Pepsi_Glass_Bottle.jpg', CAST(N'2021-08-19T20:47:16.410' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (205, NULL, 3, 1, N'Mountain Dew Glass Bottle Soft Drink - 24 x 250ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(21).png', CAST(N'2021-08-19T20:48:11.410' AS DateTime), CAST(N'2022-10-15T23:03:22.323' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (208, NULL, 5, 1, N'Fanta Twist Soft Drink - 6 x 2L', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(8).png', CAST(N'2022-10-15T22:12:20.843' AS DateTime), CAST(N'2022-10-15T22:17:02.193' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (209, NULL, 2, 1, N'Pepsi Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(14).png', CAST(N'2022-10-15T22:33:09.250' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (210, NULL, 4, 1, N'Mirinda Orange Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(15).png', CAST(N'2022-10-15T22:35:33.167' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (211, NULL, 6, 1, N'7up Soft Drink - 12 x 500ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(20).png', CAST(N'2022-10-15T22:58:22.567' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (212, NULL, 6, 1, N'7up Glass Bottle Soft Drink - 24 x 250ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(22).png', CAST(N'2022-10-15T23:10:55.317' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (213, NULL, 4, 1, N'Mirinda Orange Glass Bottle Soft Drink - 24 x 250ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(23).png', CAST(N'2022-10-15T23:13:43.720' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (214, NULL, 2, 1, N'Pepsi Glass Bottle Soft Drink - 24 x 250ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(24).png', CAST(N'2022-10-15T23:18:32.987' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (215, NULL, 9, 1, N'Calypso Kiwi Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(37).png', CAST(N'2022-10-16T00:16:01.037' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (216, NULL, 9, 1, N'Calypso Island Wave Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(39).png', CAST(N'2022-10-16T00:19:30.030' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (217, NULL, 9, 1, N'Calypso Grape Berry Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'Products_(40).png', CAST(N'2022-10-16T00:21:36.403' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (218, NULL, 9, 1, N'Calypso Original Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'37.png', CAST(N'2022-10-16T00:27:27.060' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (219, NULL, 9, 1, N'Calypso Tropical Mango Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'38.png', CAST(N'2022-10-16T00:29:25.413' AS DateTime), CAST(N'2022-10-16T00:30:11.787' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (220, NULL, 9, 1, N'Calypso Triple Melon Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'39.png', CAST(N'2022-10-16T00:31:14.103' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (221, NULL, 9, 1, N'Calypso Strawberry Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'40.png', CAST(N'2022-10-16T00:32:10.740' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (222, NULL, 9, 1, N'Calypso Southern Peach Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'41.png', CAST(N'2022-10-16T00:33:23.077' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (223, NULL, 9, 1, N'Calypso Pineapple Peach Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'42.png', CAST(N'2022-10-16T00:34:51.527' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (224, NULL, 9, 1, N'Calypso Paradise Punch Lemonade - 12 x 473ml', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'43.png', CAST(N'2022-10-16T00:35:55.430' AS DateTime), CAST(N'2022-10-16T00:43:55.050' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (225, NULL, 51, 1, N'C&C Cotton Candy Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'44.png', CAST(N'2022-10-16T01:02:20.450' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (226, NULL, 51, 1, N'C&C Watermelon Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'45.png', CAST(N'2022-10-16T01:02:55.260' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (227, NULL, 51, 1, N'C&C Blue Raspberry Soda  - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'46.png', CAST(N'2022-10-16T01:03:29.970' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (228, NULL, 51, 1, N'C&C Peach Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'47.png', CAST(N'2022-10-16T01:04:08.650' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (229, NULL, 51, 1, N'C&C Strawberry Soda', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'48.png', CAST(N'2022-10-16T01:04:55.880' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (230, NULL, 51, 1, N'C&C Pineapple Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'49.png', CAST(N'2022-10-16T01:05:28.850' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (231, NULL, 51, 1, N'C&C Orange Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'50.png', CAST(N'2022-10-16T01:06:08.227' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (232, NULL, 51, 1, N'C&C Vanilla Cream Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'51.png', CAST(N'2022-10-16T01:06:42.220' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (233, NULL, 51, 1, N'C&C Black Cherry Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'55.png', CAST(N'2022-10-16T01:07:14.517' AS DateTime), CAST(N'2022-10-16T01:07:37.263' AS DateTime), 2, 2, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (234, NULL, 51, 1, N'C&C Cola - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'54.png', CAST(N'2022-10-16T01:08:02.853' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (235, NULL, 51, 1, N'C&C Fruit Punch Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'52.png', CAST(N'2022-10-16T01:08:33.240' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (236, NULL, 51, 1, N'C&C Grape Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'53.png', CAST(N'2022-10-16T01:09:07.657' AS DateTime), NULL, 2, NULL, 0)
INSERT [dbo].[ProductMaster] ([Id], [CategoryId], [CompanyId], [DistributorId], [Name], [Description], [SellPrice], [Quantity], [FilePath], [InsertedDate], [UpdatedDate], [InsertedByUserId], [UpdatedByUserId], [HasDiscount]) VALUES (237, NULL, 51, 1, N'C&C Red Candy Apple Soda - 24 Pack', NULL, CAST(50.00 AS Decimal(18, 2)), 10, N'57.png', CAST(N'2022-10-16T01:09:54.983' AS DateTime), NULL, 2, NULL, 0)
SET IDENTITY_INSERT [dbo].[ProductMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductPurchase] ON 

INSERT [dbo].[ProductPurchase] ([Id], [ProductId], [PurchasePrice], [Quantity], [BatchNo], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate], [IsActive]) VALUES (1, 54, CAST(10.00 AS Decimal(18, 2)), 50, N'Batch_1_Prod_54_20_Nov_2022_04_53_07', 3, CAST(N'2022-11-20T16:53:07.627' AS DateTime), 3, CAST(N'2022-11-20T16:53:07.627' AS DateTime), 1)
INSERT [dbo].[ProductPurchase] ([Id], [ProductId], [PurchasePrice], [Quantity], [BatchNo], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate], [IsActive]) VALUES (2, 55, CAST(20.00 AS Decimal(18, 2)), 50, N'Batch_1_Prod_55_20_Nov_2022_04_53_14', 3, CAST(N'2022-11-20T16:53:14.417' AS DateTime), 3, CAST(N'2022-11-20T16:53:14.417' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[ProductPurchase] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([Id], [Name], [InsertedDate], [UpdatedDate]) VALUES (1, N'SuperAdmin', NULL, NULL)
INSERT [dbo].[Roles] ([Id], [Name], [InsertedDate], [UpdatedDate]) VALUES (2, N'Admin', NULL, NULL)
INSERT [dbo].[Roles] ([Id], [Name], [InsertedDate], [UpdatedDate]) VALUES (3, N'Distributor', NULL, NULL)
INSERT [dbo].[Roles] ([Id], [Name], [InsertedDate], [UpdatedDate]) VALUES (4, N'Retailer', NULL, NULL)
INSERT [dbo].[Roles] ([Id], [Name], [InsertedDate], [UpdatedDate]) VALUES (5, N'Dealer', NULL, NULL)
INSERT [dbo].[Roles] ([Id], [Name], [InsertedDate], [UpdatedDate]) VALUES (6, N'Customer', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[StockDetail] ON 

INSERT [dbo].[StockDetail] ([Id], [ProductId], [BatchNo], [AvailableQuantity], [PurchasePrice], [IsActive], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (1, 54, N'Batch_1_Prod_54_Price_10.00_20_Nov_2022_04_53_07', 10, CAST(10.00 AS Decimal(18, 2)), 1, 3, CAST(N'2022-11-20T16:53:07.633' AS DateTime), 3, CAST(N'2022-11-20T16:53:07.633' AS DateTime))
INSERT [dbo].[StockDetail] ([Id], [ProductId], [BatchNo], [AvailableQuantity], [PurchasePrice], [IsActive], [InsertedByUserId], [InsertedDate], [UpdatedByUserId], [UpdatedDate]) VALUES (2, 55, N'Batch_1_Prod_55_Price_20.00_20_Nov_2022_04_53_14', 20, CAST(20.00 AS Decimal(18, 2)), 1, 3, CAST(N'2022-11-20T16:53:14.423' AS DateTime), 3, CAST(N'2022-11-20T16:53:14.423' AS DateTime))
SET IDENTITY_INSERT [dbo].[StockDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[TransactionMaster] ON 

INSERT [dbo].[TransactionMaster] ([Id], [DistributorId], [CustomerId], [Amount], [Notes], [TransactionDate], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (5, 1, 1, CAST(500.000000 AS Decimal(18, 6)), NULL, CAST(N'2021-08-16T00:00:00.000' AS DateTime), 3, NULL, CAST(N'2021-08-16T17:42:34.017' AS DateTime), NULL)
INSERT [dbo].[TransactionMaster] ([Id], [DistributorId], [CustomerId], [Amount], [Notes], [TransactionDate], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (6, 1, 3, CAST(100.000000 AS Decimal(18, 6)), NULL, CAST(N'2022-01-10T00:00:00.000' AS DateTime), 3, NULL, CAST(N'2022-10-01T15:24:23.140' AS DateTime), NULL)
INSERT [dbo].[TransactionMaster] ([Id], [DistributorId], [CustomerId], [Amount], [Notes], [TransactionDate], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (7, 1, 7, CAST(20.000000 AS Decimal(18, 6)), NULL, CAST(N'2022-10-16T00:00:00.000' AS DateTime), 3, NULL, CAST(N'2022-10-16T16:23:44.550' AS DateTime), NULL)
INSERT [dbo].[TransactionMaster] ([Id], [DistributorId], [CustomerId], [Amount], [Notes], [TransactionDate], [InsertedByUserId], [UpdatedByUserId], [InsertedDate], [UpdatedDate]) VALUES (8, 1, 4, CAST(2.000000 AS Decimal(18, 6)), NULL, CAST(N'2022-10-29T00:00:00.000' AS DateTime), 3, NULL, CAST(N'2022-10-29T21:38:03.907' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[TransactionMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (1, N'Abhishek', N'Shah', N'SuperAdminas', N'SuperAdminas', 1, N'7801984196', N'9727506093', 0, NULL, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (2, N'Kushal', N'Patel', N'Kushal7232', N'Kushal7232', 2, N'7801984196', N'9727506093', 0, NULL, CAST(N'2021-08-11T16:53:00.303' AS DateTime), NULL, 1, N'21 chandresh naroda', N'382340')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (3, N'Moon', N'Moon', N'Moon007', N'^Moon007#', 3, N'9898989898', N'9898989898', 0, NULL, CAST(N'2021-08-11T16:58:18.777' AS DateTime), NULL, 1, N'21 chandresh uper no mal ', N'HA02DH')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (4, N'Customer1', N'Customer1', N'Customer1', N'^Customer1#', 6, N'0123456789', NULL, 0, NULL, CAST(N'2021-08-11T17:01:22.463' AS DateTime), CAST(N'2021-08-17T00:37:57.043' AS DateTime), 1, N'xxxxxxxxxx', N'xxx xxx')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (5, N'Customer2', N'Customer2', N'Customer2', N'^Customer2#', 6, N'0123456789', N'0123456789', 0, NULL, CAST(N'2021-08-11T17:02:16.430' AS DateTime), CAST(N'2021-08-17T00:38:31.857' AS DateTime), 1, N'zzz zzz', N'zzz zzz')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (6, N'Customer01', N'Customer01', N'Customer01', N'^Customer01#', 6, N'0789456123', NULL, 0, NULL, CAST(N'2021-08-17T20:23:58.667' AS DateTime), CAST(N'2021-08-19T22:24:24.283' AS DateTime), 1, N'xxx', N'xxx xxx')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (7, N'Customer02', N'Customer02', N'Customer02', N'^Customer02#', 6, N'0789456123', NULL, 0, NULL, CAST(N'2021-08-17T20:24:24.840' AS DateTime), NULL, 1, N'xxx', N'xxx xxx')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (8, N'Ali', N'Tiger', N'Kinderbueno', N'ali 33', 6, N'8864488869', NULL, 0, NULL, CAST(N'2021-09-10T15:31:51.733' AS DateTime), NULL, 1, N'123', N'Se27ay')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (9, N'Ali', N'Tiger', N'Ali123', N'123456', 6, N'8864488869', NULL, 0, NULL, CAST(N'2021-09-10T15:32:23.717' AS DateTime), NULL, 1, N'123', N'Se27ay')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [UserName], [Password], [RoleId], [PhNo1], [PhNo2], [LoggedInCount], [LastLoggedInTime], [InsertedDate], [UpdatedDate], [IsActive], [Address], [PostalCode]) VALUES (10, N'Yaso', N'S', N'Yaso', N'yaso01', 6, N'9977885566', N'9977886644', 0, NULL, CAST(N'2022-10-16T10:47:39.787' AS DateTime), NULL, 1, N'Wimbledon ', N'SM4 6RW')
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
ALTER TABLE [dbo].[OrderDetails] ADD  CONSTRAINT [DF_OrderDetails_InsertedDate]  DEFAULT (getdate()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[OrderDetails] ADD  CONSTRAINT [DF_OrderDetails_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[ProductPurchase] ADD  CONSTRAINT [DF_ProductPurchase_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[StockDetail] ADD  CONSTRAINT [DF_StockDetail_BatchNo]  DEFAULT (newid()) FOR [BatchNo]
GO
ALTER TABLE [dbo].[StockDetail] ADD  CONSTRAINT [DF_StockDetail_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[StockDetail] ADD  CONSTRAINT [DF_StockDetail_InsertedDate]  DEFAULT (getdate()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[StockDetail] ADD  CONSTRAINT [DF_StockDetail_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[Stocks] ADD  CONSTRAINT [DF_Stocks_InsertedDate]  DEFAULT (getdate()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[Stocks] ADD  CONSTRAINT [DF_Stocks_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_LoggedInCount]  DEFAULT ((0)) FOR [LoggedInCount]
GO
/****** Object:  StoredProcedure [dbo].[AddPurchasedProduct]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AddPurchasedProduct]        
@ProductId int ,        
@PurchasePrice decimal(18,2),        
@Quantity int ,        
@UserId int        
AS        
BEGIN
INSERT INTO ProductPurchase (ProductId, BatchNo, PurchasePrice, Quantity, InsertedByUserId, InsertedDate, UpdatedByUserId, UpdatedDate)
	VALUES (@ProductId, dbo.ProductPurchaseBatchNo(@ProductId), @PurchasePrice, @Quantity, @UserId, GETDATE(), @UserId, GETDATE())

DECLARE @IsStockAvailableForPrice BIT = 0


SET @IsStockAvailableForPrice = IIF(EXISTS (SELECT
		1
	FROM StockDetail
	WHERE PurchasePrice = TRY_CAST(@PurchasePrice AS DECIMAL(18, 2))
	AND ProductId = @ProductId
	AND IsActive = 1)
, 1, 0)
  
    
    
if(@IsStockAvailableForPrice<>1)    
BEGIN


INSERT INTO StockDetail (ProductId, BatchNo, AvailableQuantity, PurchasePrice, IsActive, InsertedByUserId, UpdatedByUserId)
	VALUES (@ProductId, dbo.StockDetailBatchNo(@ProductId, @PurchasePrice), @Quantity, @PurchasePrice, 1, @UserId, @UserId)
END
ELSE
BEGIN

UPDATE StockDetail
SET AvailableQuantity = @Quantity + AvailableQuantity
   ,UpdatedByUserId = @UserId
   ,IsActive = 1
WHERE ProductId = @ProductId
AND PurchasePrice = TRY_CAST(@PurchasePrice AS DECIMAL(18, 2))
AND IsActive = 1
END
END
GO
/****** Object:  StoredProcedure [dbo].[ChangeProductData]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ChangeProductData]      
@Id int,      
@quantity int,      
@price decimal(18,6),      
@userId int      
As       
BEGIN  
UPDATE ProductMaster  
SET SellPrice = @price  
   ,Quantity = @quantity  
   ,UpdatedDate = GETDATE()  
   ,UpdatedByUserId = @userId  
WHERE Id = @Id  
END
GO
/****** Object:  StoredProcedure [dbo].[ChangeProductPurchaseData]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ChangeProductPurchaseData] @Id int,   
@ProductId int ,
@PurchasePrice decimal(18, 2),   
@Quantity int,   
@UserId int   
AS BEGIN
SET NOCOUNT ON;
  
Declare @OldProductId int
  
Declare @OldPurchasePrice decimal(18, 2)
  
Declare @OldQuantity int
  
Declare @IsStockAvailableForPrice BIT = 0

SELECT
	@OldPurchasePrice = PurchasePrice
   ,@OldQuantity = Quantity
   ,@OldProductId = ProductId
FROM ProductPurchase
WHERE Id = @Id

IF (@OldProductId = @ProductId)
BEGIN
IF (@OldPurchasePrice <> @PurchasePrice
	OR @Quantity <> @OldQuantity)
BEGIN
UPDATE ProductPurchase
SET PurchasePrice = @PurchasePrice
   ,Quantity = @Quantity
   ,UpdatedByUserId = @UserId
   ,UpdatedDate = GETDATE()
   ,IsActive = 1
WHERE Id = @Id


UPDATE StockDetail
SET AvailableQuantity = IIF(AvailableQuantity - @OldQuantity <= 0, 0, AvailableQuantity - @OldQuantity)
   ,IsActive = IIF(AvailableQuantity - @OldQuantity <= 0, 0, AvailableQuantity - @OldQuantity)
   ,UpdatedByUserId = @UserId
   ,UpdatedDate = GETDATE()
WHERE ProductId = @ProductId
AND PurchasePrice = @OldPurchasePrice
AND IsActive = 1

UPDATE StockDetail
SET IsActive = 0
   ,UpdatedDate = GETDATE()
   ,UpdatedByUserId = @UserId
WHERE ProductId = @ProductId
AND PurchasePrice NOT IN (SELECT
		PurchasePrice
	FROM ProductPurchase
	WHERE ProductId = @ProductId)
AND IsActive = 1

SET @IsStockAvailableForPrice = IIF(EXISTS (SELECT
		1
	FROM StockDetail
	WHERE PurchasePrice = CAST(@PurchasePrice AS DECIMAL(18, 2))
	AND ProductId = @ProductId
	AND IsActive = 1)
, 1, 0)




IF (@IsStockAvailableForPrice <> 1)
BEGIN

INSERT INTO StockDetail (ProductId, BatchNo, AvailableQuantity, PurchasePrice, IsActive, InsertedByUserId, UpdatedByUserId)
	VALUES (@ProductId, dbo.StockDetailBatchNo(@ProductId, @PurchasePrice), @Quantity, @PurchasePrice, 1, @UserId, @UserId)
END
ELSE
BEGIN

UPDATE StockDetail
SET AvailableQuantity = IIF((AvailableQuantity + @Quantity) <= 0, 0, (AvailableQuantity + @Quantity))
   ,UpdatedByUserId = @UserId
   ,IsActive = IIF((AvailableQuantity + @Quantity) <= 0, 0, 1)
   ,UpdatedDate = GETDATE()
WHERE ProductId = @ProductId
AND PurchasePrice = TRY_CAST(@PurchasePrice AS DECIMAL(18, 2))
AND IsActive = 1
END
END
END
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DeleteById] @Id int,  
@TableName varchar(50)  
AS  
BEGIN  
  IF (@TableName = 'route')  
  BEGIN  
    DELETE FROM RouteMaster  
    WHERE Id = @Id  
  END  
  ELSE  
  IF (@TableName = 'product')  
  BEGIN  
    DELETE FROM ProductMaster  
    WHERE Id = @Id  
  END  
  ELSE  
  IF (@TableName = 'customer')  
  BEGIN  
    DELETE FROM Customer  
    WHERE Id = @Id  
  END  
  ELSE  
  IF (@TableName = 'order')  
  BEGIN  
    DELETE FROM OrderMaster  
    WHERE Id = @Id  
  END  
  ELSE  
  IF (@TableName = 'TransactionMaster')  
  BEGIN  
    DELETE FROM TransactionMaster  
    WHERE Id = @Id  
  END  
  ELSE  
  IF (@TableName = 'Bills')  
  BEGIN  
    DELETE FROM BillDetails  
    WHERE BillId = @Id  
    DELETE FROM Bills  
    WHERE Id = @Id  
  END  
  ELSE  
  IF(@TableName='category')
  BEGIN
  DELETE FROM Category  
    WHERE Id=@Id
  END
  ELSE IF(@TableName='Company')
  BEGIN
  Delete from Company 
  where Id=@Id
  END
  ELSE
  BEGIN  
    SELECT  
      'NO TABLE NAME FOUND'  
  END  
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteProductPurchase]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DeleteProductPurchase]
@Id int, @UserId int
AS
 BEGIN
SET NOCOUNT ON;
 Declare @Quantity INT
 Declare @PurchasePrice Decimal(18,2)
 Declare @ProductId int
SELECT
	@Quantity = Quantity
   ,@ProductId = ProductId
   ,@PurchasePrice = PurchasePrice
FROM dbo.ProductPurchase
WHERE Id = @Id
AND IsActive = 1

UPDATE dbo.StockDetail
SET AvailableQuantity = IIF(AvailableQuantity - @Quantity <= 0, 0, AvailableQuantity - @Quantity)
   ,UpdatedByUserId = @UserId
WHERE PurchasePrice = @PurchasePrice
AND ProductId = @ProductId
AND IsActive = 1

UPDATE dbo.ProductPurchase
SET IsActive = 0
   ,UpdatedByUserId = @UserId
WHERE Id = @Id

END
GO
/****** Object:  StoredProcedure [dbo].[GetAdminById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetAdminById]   
  
@Id int   
As   
BEGIN  
SELECT   
A.Id  
,UserName   
,Password  
,PhNo1   
,PhNo2   
,FirstName  
,LastName  
,Address   ,
Postalcode
FROM Admin A inner join Users U  
on A.UserId =U.Id  
where A.Id=@Id  
END  
GO
/****** Object:  StoredProcedure [dbo].[GetAdmins]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetAdmins] AS   
BEGIN  
   SELECT  
      AD.Id,  
      U.UserName,  
   U.FirstName,  
   U.LastName,  
      U.Password,  
      U.IsActive,  
      Address   ,
	  Postalcode
   FROM  
      Admin AD   
      inner join  
         Users U   
         ON AD.UserId = U.Id   
END  
GO
/****** Object:  StoredProcedure [dbo].[GetBillsHistoryPDF]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetBillsHistoryPDF] 
@id int
As
begin
select B.BillDate,B.BillNo,B.BillTotal,B.Id as BillsId,B.BillTotal as NetAmount,
C.StoreName as StoreName
,D.Name as DistributorName
,(Isnull( U.FirstName,'') + ''+Isnull( U.LastName,'')) as CustomerName
,U.Address as Address ,
U.PostalCode
from Bills  B
inner join Customer C
On B.CustomerId=C.Id
inner join Distributor D 
on B.DistributorId =D.Id 
inner join Users U
on C.UserId =U.Id
where B.Id=@id

select * from BillDetails where BillId=@id
end
GO
/****** Object:  StoredProcedure [dbo].[GetBillsPDFData]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetBillsPDFData]
@FromDate datetime,
@ToDate datetime,
@CustomerId int =0
As 
BEGIN
SELECT B.Id as BillsId,B.BillTotal as NetAmount, B.BillDate,B.FileName,C.StoreName as StoreName
FROM Bills B
inner join 
Customer C on B.CustomerId=C.Id
inner join Users u 
on C.UserId=U.Id
where (CustomerId=@CustomerId or @CustomerId=0) and cast(BillDate as date) between cast(@FromDate as date) and cast(@ToDate as date)
order by BillDate  desc
End
GO
/****** Object:  StoredProcedure [dbo].[GetCategory]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CReate PROC [dbo].[GetCategory] 
@distributorId int 
As 
begin
Select * from Category where DistributorId=@distributorId
end
GO
/****** Object:  StoredProcedure [dbo].[GetCategoryById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetCategoryById]
@id int 
As 
begin
Select *  from Category   where Id=@id
end
GO
/****** Object:  StoredProcedure [dbo].[GetCompany]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetCompany]
@distributorId int 
As 
begin
Select CO.*,CA.Name as CategoryName from Company CO left join Category CA on CO.CategoryId=CA.Id  where CO.DistributorId=@distributorId
end
GO
/****** Object:  StoredProcedure [dbo].[GetCompanyById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetCompanyById]
@id int 
As 
begin
Select CO.*,CA.Name as CategoryName from Company CO left join Category CA on CO.CategoryId=CA.Id  where CO.Id=@id
end
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetCustomerById]   
  
@Id int   
As   
BEGIN  
SELECT   
C.*,U.UserName,U.Password,U.PhNo1,U.PhNo2,U.Address,U.FirstName,U.LastName ,U.PostalCode  as PostalCode
FROM Customer C  
inner join Users  U  
on C.UserId=U.Id  
where C.Id=@Id  
END  
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerDetailsRport]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetCustomerDetailsRport]   
@CustomerId int,  
@FromDate datetime,  
@ToDate datetime,  
@DistributorId int  
AS  
BEGIN
  
  
 IF(@CustomerId<>0)  
  BEGIN
SELECT

	(CAST(C.SerialNo AS VARCHAR) + ' ' + C.StoreName) AS CustomerName
   ,O.Quantity AS Quantity
   ,CAST(O.Price AS DECIMAL(18, 2)) AS Price
   ,CAST(o.Total AS DECIMAL(18, 2)) Total
   ,P.Name AS ProductName
   ,
	--CAST(O.OrderDate AS date) AS OrderDate,  
	FORMAT(O.OrderDate, 'dd/MM/yyyy', 'en-us') AS OrderDate
FROM OrderMaster O
INNER JOIN Customer C
	ON O.CustomerId = c.Id
INNER JOIN ProductMaster P
	ON O.ProductId = P.Id
WHERE CAST(OrderDate AS DATE) BETWEEN
CAST(@FromDate AS DATE)
AND CAST(@ToDate AS DATE)
AND O.CustomerId = @CustomerId
AND C.DistributorId = @DistributorId
END
ELSE
BEGIN
SELECT

	(CAST(C.SerialNo AS VARCHAR) + ' ' + C.StoreName) AS CustomerName
   ,CAST(O.Quantity AS DECIMAL(18, 2)) AS Quantity
   ,CAST(O.Price AS DECIMAL(18, 2)) AS Price
   ,CAST(o.Total AS DECIMAL(18, 2)) Total
   ,P.Name AS ProductName
   ,
	--CAST(O.OrderDate AS date) AS OrderDate,  
	FORMAT(O.OrderDate, 'dd/MM/yyyy', 'en-us') AS OrderDate
FROM OrderMaster O
INNER JOIN Customer C
	ON O.CustomerId = c.Id
INNER JOIN ProductMaster P
	ON O.ProductId = P.Id
WHERE CAST(OrderDate AS DATE) BETWEEN
CAST(@FromDate AS DATE)
AND CAST(@ToDate AS DATE)
AND C.DistributorId = @DistributorId
END
END
GO
/****** Object:  StoredProcedure [dbo].[GetCustomers]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [dbo].[GetCustomers] @distributorId int  
AS  
BEGIN  
  SELECT  
    C.*,  
    U.UserName,  
    U.PhNo1,  
    U.PhNo2,  
    U.Address,  
    U.FirstName,  
    U.LastName,  
	PostalCode,
 (Select Sum(Isnull(Price,0)*Isnull(Quantity,0)) from OrderMaster where CustomerId=C.Id and OrderStatusId=3 ) as TotalDeliveredAmount,  
 (Select Isnull(Sum(ISNULL( Amount,0)),0) from TransactionMaster where CustomerId=C.Id ) as TotalPaidAmmount  
  FROM Customer C  
  INNER JOIN Users U  
    ON C.UserId = U.Id  
   
  WHERE C.DistributorId =@distributorId  
END  
  
  
GO
/****** Object:  StoredProcedure [dbo].[GetDashBoardData]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetDashBoardData] @OrderStatusId int,  
@FromDate datetime,  
@ToDate datetime,  
@CustomerId int = 0,  
@DistributorId int=0  
AS  
BEGIN  
  
  SELECT  
    p.Id,  
    ISNULL(t.Quantity, 0) AS Quantity,  
    P.Name as ProductName,  
 P.FilePath  
  FROM ProductMaster p  
  LEFT JOIN (SELECT  
    ISNULL(SUM(o.Quantity), 0) AS Quantity,  
    ProductId  
  FROM OrderMaster o  
  WHERE o.OrderStatusId = @OrderStatusId  
  AND (o.CustomerId = @CustomerId  
  OR @CustomerId = 0)  
  AND CAST(o.OrderDate AS date) BETWEEN CAST(@FromDate AS date) AND CAST(@ToDate AS date) and (o.DistributorId=@DistributorId or @DistributorId=0)  
  GROUP BY o.ProductId) t  
    ON t.ProductId = P.Id  
 where (p.DistributorId=@DistributorId or @DistributorId=0)  
  
  SELECT  
    c.StoreName,  
    c.Id,  
    Isnull (t.Quantity,0) as Quantity,  
    t.ProductId,  
   Isnull(P.Name,'') AS ProductName  
  FROM Customer c  
  LEFT JOIN (SELECT TOP 1  
    CustomerId,  
    ProductId,  
   SUM(Quantity) AS Quantity  
  FROM OrderMaster o  
  WHERE o.OrderStatusId = @OrderStatusId  
  AND (O.CustomerId = @CustomerId  
  OR @CustomerId = 0)  
  AND CAST(o.OrderDate AS date) BETWEEN CAST(@FromDate AS date) AND CAST(@ToDate AS date)  
  GROUP BY CustomerId,  
           ProductId  
  ORDER BY SUM(o.Quantity) DESC) t  
    ON c.Id = t.CustomerId  
  LEFT JOIN ProductMaster P  
   ON P.Id = t.ProductId  
   where (c.Id=@CustomerId or @CustomerId=0)
     
  
   Exec GetTransactionReport @DistributorId,@CustomerId,@FromDate,@ToDate  
END  
GO
/****** Object:  StoredProcedure [dbo].[GetDistributorById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetDistributorById]     
    
@Id int     
As     
BEGIN    
SELECT     
    
 D.Id   ,  
 D.Name  
 ,U.FirstName    
 ,U.LastName    
 ,U.UserName     
 ,U.Password    
 ,U.PhNo1     
 ,U.PhNo2    
 ,U.Address     
 ,U.IsActive ,
 PostalCode
FROM Distributor  D inner join Users U    
on D.UserId =U.Id    
where D.Id=@Id    
END 
GO
/****** Object:  StoredProcedure [dbo].[GetDistributorOrders]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetDistributorOrders]      
@DistributorId int=0,      
@CustomerId int=0,      
@OrderStatusId int=0,      
@FromDate datetime =null,      
@ToDate datetime=null      
AS      
begin
SELECT
	O.*
   ,P.Name AS ProductName
   ,P.FilePath
   ,C.StoreName
FROM OrderMaster O
INNER JOIN ProductMaster P
	ON O.ProductId = P.Id
INNER JOIN Customer c
	ON O.CustomerId = c.Id
WHERE (O.DistributorId = @DistributorId
OR @DistributorId = 0)
AND (O.CustomerId = @CustomerId
OR @CustomerId = 0)
AND (OrderStatusId = @OrderStatusId
OR @OrderStatusId = 0)
AND O.IsActive = 1
AND CAST(O.OrderDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
ORDER BY o.OrderStatusId, OrderDate DESC
END
GO
/****** Object:  StoredProcedure [dbo].[GetDistributorOrdersById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [dbo].[GetDistributorOrdersById]    
@OrderId int  
AS    
begin     
Select O.* , P.Name As ProductName,P.FilePath,C.StoreName,P.Id as ProductId from OrderMaster O     
inner join ProductMaster P on O.ProductId=P.Id     
inner join Customer c on O.CustomerId=c.Id    
where O.Id=@OrderId  
End 
GO
/****** Object:  StoredProcedure [dbo].[GetDistributors]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetDistributors]     
@AdminId int     
As     
BEGIN     
SELECT     
  D.Id ,    
  U.FirstName,    
  U.LastName,    
  U.UserName ,    
  U.Password,    
  U.IsActive ,   
  D.Name  ,
  PostalCode
    
from Distributor D    
inner join Users U     
On D.UserId=U.Id    
Where AdminId=@AdminId    
END 
GO
/****** Object:  StoredProcedure [dbo].[GetOrderBillsData]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetOrderBillsData] @OrderIds intlist readonly As BEGIN     
Select     
  O.*,     
  O.Total as Amount,     
  p.Name as ProductName,     
  C.StoreName,     
  C.Id as CustomerId,  
  (    
    Isnull(U.FirstName, '')+ ' ' + Isnull(u.LastName, '')    
  ) as CustomerName,     
  U.Address as Address,     
  U.PostalCode,    
  (    
    select     
      top 1 Name     
    from     
      Distributor     
    where     
      Id = o.DistributorId    
  ) as DistributorName ,  
  (    
    select     
      top 1 Id     
    from     
      Distributor     
    where     
      Id = o.DistributorId    
  ) as DistributorId,
  (select (Isnull(Max(BillNo),5000)+1) from Bills where CustomerId=C.Id) as BillNo
from     
  OrderMaster o     
  inner join ProductMaster p on o.ProductId = p.Id     
  inner join Customer C on o.CustomerId = C.Id     
  inner join Users u on C.UserId = u.Id where o.Id in (    
    select     
      Item     
    from     
      @OrderIds    
  )     
  and o.OrderStatusId = 3 END 
GO
/****** Object:  StoredProcedure [dbo].[GetOrderById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetOrderById] 

@Id int 
As 
BEGIN
SELECT 
* 
FROM OrderMaster  
where Id=@Id
END
GO
/****** Object:  StoredProcedure [dbo].[GetOrdersByCustomerId]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetOrdersByCustomerId]  
@CustomerId int  ,
@FromDate datetime,
@ToDate datetime,
@OrderStatusId int 
As   
begin  
select O.*,P.Name as ProductName,p.FilePath as FilePath  
from OrderMaster O left join ProductMaster p on o.ProductId =p.Id  where O.CustomerId =@CustomerId
and O.IsActive=1 and cast(o.OrderDate as date) between cast(@FromDate as date) and cast(@ToDate as date)
and (@OrderStatusId=0 or  IIF(OrderStatusId=2,1,OrderStatusId) =@OrderStatusId )
Order by  (case when o.OrderStatusId=1 then  1 when o.OrderStatusId=2 then 1 else o.OrderStatusId end) ,OrderDate desc
end  
GO
/****** Object:  StoredProcedure [dbo].[GetPredecessorOfUser]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetPredecessorOfUser]
@UserId int ,
@UserRoleId int 
As 
begin 
if(@UserRoleId =4 )
begin 
Select * from Users where Id in (Select D.UserId from  RetailerDetails RD
inner join Retailer R 
on RD.RetailerId =R.Id
inner join Distributor D on R.DistributorId=D.Id
where RD.UserId=@UserId
) 
end 
else if(@UserRoleId=3)
begin 
select * from Users where Id in (
select A.UserId from Distributor D 
inner join Admin A
on D.AdminId=A.Id
where D.UserId=@UserId)

end 
else if(@UserRoleId=2)
begin 
Select * from Users where RoleId=1 and UserName='SuperAdmin'
end 
end 
GO
/****** Object:  StoredProcedure [dbo].[GetProductById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetProductById] 

@Id int 
As 
BEGIN
SELECT 
P.* ,CO.Name as CompanyName,C.Name as CategoryName
FROM ProductMaster  P
left join  Company CO 
on P.CompanyId=CO.Id
left join Category C
on CO.CategoryId=C.Id
where P.Id=@Id
END
GO
/****** Object:  StoredProcedure [dbo].[GetProductDataByUserId]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE PROC [dbo].[GetProductDataByUserId]  
@CustomerId int,  
@Search varchar(200)=null,  
@Company varchar(200)=null,  
@Category varchar(200)=null  
As   
begin
;
WITH CTEProduct
AS
(SELECT DISTINCT
		PM.Id
	   ,PM.CategoryId
	   ,PM.CompanyId
	   ,PM.DistributorId
	   ,PM.Name
	   ,PM.Description
	   ,PM.SellPrice

	   ,PM.FilePath
	   ,PM.InsertedDate
	   ,PM.UpdatedDate
	   ,PM.InsertedByUserId
	   ,PM.UpdatedByUserId
	   ,PM.HasDiscount
	   ,SUM(ISNULL(AvailableQuantity, 0)) OVER (PARTITION BY ProductId) AS Quantity

	FROM dbo.StockDetail ST WITH (NOLOCK)
	INNER JOIN dbo.ProductMaster PM WITH (NOLOCK)
		ON ST.ProductId = PM.Id
		AND IsActive = 1)


SELECT
	P.*
FROM CTEProduct p
INNER JOIN Customer C
	ON P.DistributorId = C.DistributorId
LEFT JOIN Company Co
	ON P.CompanyId = Co.Id
LEFT JOIN Category Ct
	ON Co.CategoryId = Ct.Id
WHERE p.Quantity > 0
AND C.Id = @CustomerId
AND ((P.Name LIKE '%' + COALESCE(@search, P.Name) + '%')
OR (Co.Name LIKE '%' + COALESCE(@search, co.Name) + '%')
OR (Ct.Name LIKE '%' + COALESCE(@search, Ct.Name) + '%'))
AND (Co.Name LIKE '%' + COALESCE(@Company, co.Name) + '%')
AND (Ct.Name LIKE '%' + COALESCE(@Category, Ct.Name) + '%')
ORDER BY ISNULL(P.HasDiscount, 0) DESC, COALESCE(P.UpdatedDate, p.InsertedDate) DESC
END
GO
/****** Object:  StoredProcedure [dbo].[GetProductPurchase]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetProductPurchase]   
@ProductId int=0  
AS   
BEGIN
SET NOCOUNT ON
SELECT
	p.Id
   ,p.ProductId
   ,PM.Name AS ProductName
   ,p.PurchasePrice
   ,p.Quantity
   ,p.BatchNo
   ,(SELECT TOP 1
			u.UserName
		FROM Users u
		WHERE u.Id = p.InsertedByUserId)
	AS AddedBy
   ,(SELECT TOP 1
			u.UserName
		FROM Users u
		WHERE u.Id = P.UpdatedByUserId)
	AS UpdatedBy
   ,p.InsertedDate AS AddedDate
   ,p.UpdatedDate
FROM ProductPurchase P
INNER JOIN ProductMaster PM
	ON P.ProductId = PM.Id
WHERE (ISNULL(@ProductId, 0) = 0
OR p.ProductId = @ProductId)
AND IsActive = 1
ORDER BY COALESCE(P.UpdatedDate, P.InsertedDate) DESC
END
GO
/****** Object:  StoredProcedure [dbo].[GetProducts]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetProducts]  
@distributorId int   
AS   
BEGIN   
SELECT P.*,CO.Name as CompanyName ,C.Name as CategoryName  ,
(select Isnull(sum(Quantity),0) from OrderMaster o where o.ProductId =P.Id and o.OrderStatusId not in(3,4) and IsActive=1) as OrderedQuantity
FROM  ProductMaster P  
left join Company CO on P.CompanyId=CO.Id    
left join Category C on CO.CategoryId=C.Id  
WHERE P.DistributorId=@distributorId
order by Isnull(p.HasDiscount,0) desc,coalesce(p.UpdatedDate,p.InsertedDate)desc
END  

GO
/****** Object:  StoredProcedure [dbo].[GetProfitLossReport]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [dbo].[GetProfitLossReport]    
@CustomerId int =0,  
@ProductId int=0,  
@fromDate datetime =null,      
@toDate datetime =null      
AS    
 BEGIN
  
 If(@fromDate is null)  
 BEGIn
SET @fromDate = DATEADD(MONTH, -1, GETDATE())
  
 END
  
  If(@toDate is null)  
 BEGIn
SET @toDate = GETDATE()
  
 END
SELECT
	T.ProductName
   ,T.Customer
   ,SUM(T.QuantityDeliverd) AS QuantityDeliverd
   ,SUM(T.TotalPurchasedPrice) AS TotalPurchasedPrice
   ,SUM(T.TotalSellPrice) AS TotalSellPrice
   ,SUM(T.Profit) AS Profit
FROM (SELECT
		P.Name AS ProductName
	   ,OM.Price
	   ,(OM.Price * OD.QuantityDeliverd - SD.PurchasePrice * OD.QuantityDeliverd) AS Profit
	   ,SD.PurchasePrice * OD.QuantityDeliverd AS TotalPurchasedPrice
	   ,OM.Price * OD.QuantityDeliverd AS TotalSellPrice
	   ,OD.QuantityDeliverd
	   ,U.UserName AS Customer

	FROM OrderMaster OM
	INNER JOIN ProductMaster P
		ON OM.ProductId = P.Id
	INNER JOIN OrderDetails OD
		ON OD.OrderId = OM.Id
	INNER JOIN StockDetail SD
		ON SD.Id = OD.StockDetailId
	INNER JOIN Customer C
		ON C.Id = OM.CustomerId
	INNER JOIN Users U
		ON U.Id = C.UserId
	WHERE OM.IsActive = 1
	AND SD.IsActive = 1
	AND U.IsActive = 1
	AND (OM.ProductId = @ProductId
	OR @ProductId = 0)
	AND (OM.CustomerId = @CustomerId
	OR @CustomerId = 0)
	AND CAST(OM.OrderDate AS DATE) BETWEEN CAST(@fromDate AS DATE) AND CAST(@toDate AS DATE)) T
GROUP BY T.ProductName
		,T.Customer
ORDER BY T.Customer, T.ProductName
END
GO
/****** Object:  StoredProcedure [dbo].[GetRetailerDetails]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[GetRetailerDetails] 
@DistributorId int 
AS 
BEGIN 
SELECT 
RD.Id ,
R.Name ,
U.UserName,
U.Password,
U.IsActive
FROM RetailerDetails RD
inner join Users U on RD.UserId=U.Id
inner join Retailer R on RD.RetailerId=R.Id
WHERE DistributorId=@DistributorId
END
GO
/****** Object:  StoredProcedure [dbo].[GetRouteById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetRouteById] 

@Id int 
As 
BEGIN
SELECT 
*
FROM RouteMaster
where Id=@Id
END
GO
/****** Object:  StoredProcedure [dbo].[GetRoutes]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetRoutes]
@distributorId int 
AS 
BEGIN 
SELECT * FROM RouteMaster WHERE DistributorId=@distributorId
END
GO
/****** Object:  StoredProcedure [dbo].[GetStocks]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [dbo].[GetStocks]  
AS  
BEGIN
SELECT
	*
FROM (SELECT DISTINCT
		PM.Name AS ProductName
	   ,PM.FilePath
	   ,PM.Id AS ProductId
	   ,SUM(ISNULL(AvailableQuantity, 0)) OVER (PARTITION BY ProductId) AS Quantity

	FROM dbo.StockDetail ST WITH (NOLOCK)
	RIGHT JOIN dbo.ProductMaster PM WITH (NOLOCK)
		ON ST.ProductId = PM.Id
		AND IsActive = 1) T
ORDER BY  T.ProductName
END
GO
/****** Object:  StoredProcedure [dbo].[GetTransaction]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetTransaction]    
@distributorId int,    
@customerId int,    
@fromDate datetime =null,    
@toDate datetime =null    
AS     
BEGIN
SET NOCOUNT ON;
 If(@fromDate is null)
 BEGIn
SET @fromDate = DATEADD(MONTH, -1, GETDATE())
 END
  If(@toDate is null)
 BEGIn
SET @toDate = GETDATE()
 END
SELECT
	T.*
   ,C.StoreName
   ,C.SerialNo
FROM TransactionMaster T
INNER JOIN Distributor D
	ON T.DistributorId = D.Id
INNER JOIN Customer C
	ON T.CustomerId = C.Id

WHERE (@customerId = 0
OR CustomerId = @customerId)
AND D.Id = @distributorId
AND CAST(T.TransactionDate AS DATE) BETWEEN CAST(@fromDate AS DATE) AND CAST(@toDate AS DATE)
END
GO
/****** Object:  StoredProcedure [dbo].[GetTransactionById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetTransactionById]  
@id int  
AS   
BEGIN  
SELECT T.*,C.StoreName, C.SerialNo FROM TransactionMaster T inner join   
Distributor D on T.DistributorId=D.Id  
inner join Customer C on T.CustomerId=C.Id  
where T.Id =@id  
END  
GO
/****** Object:  StoredProcedure [dbo].[GetTransactionReport]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetTransactionReport]    
@DistributorId int,    
@CustomerId int=0,    
@FromDate DateTime =null,    
@ToDate DateTime =null    
As    
begin    
Declare @DayBefore Datetime = DATEADD(day, -1, CAST(@FromDate AS date));    
    
  IF OBJECT_ID('tempdb..#TempOrders') IS NOT NULL     
DROP TABLE #TempOrders    
    
IF OBJECT_ID('tempdb..#TempOrders1') IS NOT NULL     
DROP TABLE #TempOrders1    
    
IF OBJECT_ID('tempdb..#TempTransaction') IS NOT NULL     
DROP TABLE #TempTransaction    
    
IF OBJECT_ID('tempdb..#TempTransaction1') IS NOT NULL     
DROP TABLE #TempTransaction1    
    
    
Select     
  CustomerId,     
  Total into #TempOrders from     
  (    
    select     
      CustomerId,     
      sum(Total) Total     
    from     
      OrderMaster     
    where     
      cast(OrderDate as date) between cast (@FromDate as date)     
      and cast(@ToDate as date)     
      and (CustomerId = @CustomerId  or @CustomerId=0)  
	  and OrderStatusId=3 and IsActive=1
    group By     
      CustomerId    
  ) as t     
    
Select     
  CustomerId,     
  Total into #TempOrders1 from     
  (    
    select     
      CustomerId,     
      sum(Total) Total     
    from     
      OrderMaster     
    where     
      cast(OrderDate as date) < cast(@DayBefore as date)     
      and (CustomerId = @CustomerId or @CustomerId=0)    
	    and OrderStatusId=3 and IsActive=1
    group By     
      CustomerId    
  ) as t     
    
Select     
  CustomerId,     
  Amount into #TempTransaction from     
  (    
    select     
      CustomerId,     
      sum(Amount) Amount     
    from     
      TransactionMaster TM     
    where     
      cast(TransactionDate as date) between cast (@FromDate as date)     
      and cast(@ToDate as date)     
      and (CustomerId = @CustomerId or @CustomerId=0)    
    group By     
      CustomerId    
  ) as t1     
    
Select     
  CustomerId,     
  Amount into #TempTransaction1 from     
  (    
    select     
      CustomerId,     
      sum(Amount) Amount     
    from     
      TransactionMaster TM     
    where     
      cast(TransactionDate as date) < Cast(@DayBefore as Date)     
      and (CustomerId = @CustomerId or @CustomerId=0)    
    group By     
      CustomerId    
  ) as t1     
    
Select     
C.Id as CustomerId,    
  C.SerialNo,     
  C.StoreName,     
  ISNULL(OpenningBalance,0) as OpenningBalance,    
  ISNULL(T.PurchasedAmount, 0) as PurchasedAmount,     
  ISNULL(T.PaidAmount, 0) as PaidAmount,     
  (ISNULL(OpenningBalance,0)+ISNULL(T.PurchasedAmount,0)-ISNULL(T.PaidAmount,0)) as OutStanding    
     
    
from     
  Customer C     
  left join (    
    select     
     ISNULL(o.Total,0) as PurchasedAmount,     
     ISNULL(T.Amount,0) as PaidAmount,     
      --(o.Total - T.Amount) as OutStanding,     
      O.CustomerId     
    from     
      #TempOrders o    
      left join #TempTransaction T on o.CustomerId=T.CustomerId)T     
   on C.Id=T.CustomerId     
       
   left join (    
    select     
      (ISNULL(o.Total,0) -ISNULL(Temp2.Amount,0)) as OpenningBalance,     
      O.CustomerId     
    from     
      #TempOrders1 o    
      left join #TempTransaction1 temp2 on o.CustomerId=Temp2.CustomerId)T1    
   on C.Id=T1.CustomerId     
       
       
   where c.DistributorId=@DistributorId  
      and (c.Id = @CustomerId or @CustomerId=0)    
    
end    
GO
/****** Object:  StoredProcedure [dbo].[InsertBillsData]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[InsertBillsData] @CustomerId int,  @DistributorId int, 
@BillNo int,  @BillDate datetime, 
@FileName varchar(250), 
@InsertedByUserId int,  
@BillTotal decimal(18, 6),
@BillDetails BillDetailstype readonly As 
BEGIN
INSERT INTO [dbo].[Bills] ([CustomerId], [DistributorId], [BillNo], [BillTotal], [FileName], [BillDate], [InsertedByUserId], [InsertedDate])
	VALUES (@CustomerId, @DistributorId, @BillNo, @BillTotal, @FileName, @BillDate, @InsertedByUserId, GETDATE())
DECLARE @BillsId INT = SCOPE_IDENTITY()

INSERT INTO [dbo].[BillDetails] ([BillId], [ProductName], [Quantity], [Price], [Amount], [InsertedByUserId], [InsertedDate])
	SELECT
		@BillsId
	   ,[ProductName]
	   ,[Quantity]
	   ,[Price]
	   ,[Amount]
	   ,@InsertedByUserId
	   ,GETDATE()
	FROM @BillDetails
END
GO
/****** Object:  StoredProcedure [dbo].[IsUserNameExists]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[IsUserNameExists]
@UserName nvarchar(100),
@UserId int

As
BEGIN
SELECT  Count(Id) FROM Users where lower (UserName)=lower(@UserName) and (@UserId=0 Or Id =@UserId)

END



GO
/****** Object:  StoredProcedure [dbo].[ProductMasterSIDU]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ProductMasterSIDU]
(
@Id int =NULL,
@CategoryId int =NULL,
@CompanyId int =NULL,
@DistributorId int =NULL,
@Name nvarchar(MAX) =NULL,
@Description nvarchar(MAX) =NULL,
@SellPrice decimal(18,2) =NULL,
@Quantity int =NULL,
@FilePath varchar(300) =NULL,
@InsertedDate datetime =NULL,
@UpdatedDate datetime =NULL,
@InsertedByUserId int =NULL,
@UpdatedByUserId int =NULL,
@HasDiscount bit =NULL,
@OprType INT
)
AS
BEGIN-----------
-------------------------------------------------------------------------------
IF @OprType =0
BEGIN
SELECT
	*
FROM ProductMaster
END
-------------------------------------------------------------------------------
IF @OprType = 1
BEGIN
INSERT INTO ProductMaster (CategoryId, CompanyId, DistributorId, Name, Description, SellPrice, Quantity, FilePath, InsertedDate, UpdatedDate, InsertedByUserId, UpdatedByUserId, HasDiscount)
	VALUES (@CategoryId, @CompanyId, @DistributorId, @Name, @Description, @SellPrice, @Quantity, @FilePath, GETDATE(), GETDATE(), @InsertedByUserId, @UpdatedByUserId, @HasDiscount)
END
-------------------------------------------------------------------------------
IF @OprType = 2
BEGIN
DELETE FROM ProductMaster
WHERE Id = @Id
END
-------------------------------------------------------------------------------
IF @OprType = 3
BEGIN
UPDATE ProductMaster
SET CategoryId = @CategoryId
   ,CompanyId = @CompanyId
   ,DistributorId = @DistributorId
   ,Name = @Name
   ,Description = @Description
   ,SellPrice = @SellPrice
   ,Quantity = @Quantity
   ,FilePath = COALESCE(@FilePath, FilePath)
   ,UpdatedDate = GETDATE()
   ,HasDiscount = @HasDiscount
WHERE Id = @Id
END
-------------------------------------------------------------------------------
IF @OprType = 4
BEGIN
SELECT
	*
FROM ProductMaster
WHERE Id = @Id
END
-------------------------------------------------------------------------------
END---------------
GO
/****** Object:  StoredProcedure [dbo].[SetDefualtPassword]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SetDefualtPassword] @UserName Nvarchar(100) As 
BEGIN
   IF((
   SELECT
      COUNT(*) 
   FROM
      Users 
   WHERE
      UserName = @UserName 
      and IsActive = 1) = 1 ) 
      begin
         Update
            Users 
         set
            Password = ISNULL(PhNo1, ISNULL(PhNo2, UserName)) 
         where
            UserName = @UserName 
            and IsActive = 1 
            select
               1 
      end
      else
         begin
            Select
               0 
         end
end
GO
/****** Object:  StoredProcedure [dbo].[UpdateOrderStatusById]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UpdateOrderStatusById]
    @OrderStatusId int,
    @UpdatedByUserId int,
    @OrderIds IntList READONLY
As
BEGIN
SET NOCOUNT ON;
    Declare @OldOrderStatusId int = ( SELECT TOP 1
		Id
	FROM OrderMaster
	WHERE Id IN (SELECT
			*
		FROM @OrderIds)
	AND IsActive = 1)
IF (@OrderStatusId <> @OldOrderStatusId)
BEGIN
IF (@OrderStatusId != 11)
BEGIN
IF (@OrderStatusId != 3)
BEGIN
UPDATE SD
SET AvailableQuantity = AvailableQuantity + OD.QuantityDeliverd
FROM dbo.StockDetail SD
INNER JOIN dbo.OrderDetails OD
	ON SD.Id = Od.StockDetailId
WHERE OD.OrderId IN (SELECT
		*
	FROM @OrderIds)
DELETE FROM dbo.OrderDetails
WHERE OrderId IN (SELECT
			*
		FROM @OrderIds)
UPDATE dbo.OrderMaster
SET OrderStatusId = @OrderStatusId
   ,UpdatedByUserId = @UpdatedByUserId
   ,UpdatedDate = GETDATE()
WHERE Id IN (SELECT
		item
	FROM @OrderIds)
AND IsActive = 1
END


END
ELSE
IF (@OrderStatusId = 11)
BEGIN
UPDATE dbo.OrderMaster
SET IsActive = 0
   ,UpdatedByUserId = @UpdatedByUserId
   ,UpdatedDate = GETDATE()
WHERE Id IN (SELECT
		item
	FROM @OrderIds)
AND IsActive = 1
UPDATE SD
SET AvailableQuantity = AvailableQuantity + OD.QuantityDeliverd
FROM dbo.StockDetail SD
INNER JOIN dbo.OrderDetails OD
	ON SD.Id = Od.StockDetailId
WHERE OD.OrderId IN (SELECT
		*
	FROM @OrderIds)
DELETE FROM dbo.OrderDetails
WHERE OrderId IN (SELECT
			*
		FROM @OrderIds)
DELETE FROM dbo.OrderDetails
WHERE OrderId IN (SELECT
			*
		FROM @OrderIds)
END
IF (@OrderStatusId = 3)
BEGIN
DECLARE @PordersId IntList
INSERT INTO @PordersId
	SELECT
		*
	FROM @OrderIds
WHILE EXISTS (SELECT
		*
	FROM @PordersId)
BEGIN
DECLARE @OrderId INT = (SELECT TOP 1
		*
	FROM @PordersId)
DECLARE @ProductId INT
DECLARE @OrderedQuantity INT
SELECT
	@ProductId = ProductId
   ,@OrderedQuantity = Quantity
FROM dbo.OrderMaster WITH (NOLOCK)
WHERE Id = @OrderId
EXEC dbo.UpdateStock @ProductId
					,@OrderedQuantity
					,@OrderId
					,@UpdatedByUserId
DELETE FROM @PordersId
WHERE Item = @OrderId
END
END
SELECT
	1;
END
END
GO
/****** Object:  StoredProcedure [dbo].[UpdatePassword]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UpdatePassword] 
@OldPassword nvarchar(20),
@NewPassword nvarchar(20),
@UserId int=0
As 
begin
   if EXISTS (select *  from Users  where Id = @UserId and Password =@OldPassword)
   begin
      update
         Users 
      set
         Password=@NewPassword
      where
         Id = @UserId 
         Select 1 
   end
   else
      begin
         select  0 
      end
end
GO
/****** Object:  StoredProcedure [dbo].[UpdateProfile]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UpdateProfile]   
@FirstName nvarchar(200),   
@LastName nvarchar(200),   
@PhNo1 nvarchar(50),   
@PhNo2 nvarchar(50),   
@Address nvarchar(max),  
@Postalcode varchar(50),
@UserId int As   
begin  
   if EXISTS (select *  from Users  where Id = @UserId )  
   begin  
      update  
         Users   
      set  
         FirstName = @FirstName,  
   LastName=@LastName,  
         PhNo1 = @PhNo1,  
         PhNo2 = @PhNo2,  
         Address = @Address ,
		 Postalcode=@Postalcode
      where  
         Id = @UserId   
         Select 1   
   end  
   else  
      begin  
         select  0   
      end  
end  
GO
/****** Object:  StoredProcedure [dbo].[UpdateStock]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateStock]
    -- Add the parameters for the stored procedure here  
    @ProductID int,
    @OrderQuantity int,
    @OrderId int,
    @UpdatedByUserId int
AS
BEGIN
SET NOCOUNT ON;


    -- Fetch total stock in hand  
    DECLARE @TotalStock INT
SET @TotalStock = (SELECT
		SUM(AvailableQuantity)
	FROM dbo.StockDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID
	AND IsActive = 1)


    -- Check if the available stock is less than ordered quantity  
    IF @TotalStock < @OrderQuantity
    BEGIN

        PRINT 'Stock not available'

        RETURN -1

    END
UPDATE dbo.OrderMaster
SET OrderStatusId = 3
   ,UpdatedByUserId = @UpdatedByUserId
   ,UpdatedDate = GETDATE()
WHERE Id IN (@OrderId)
AND IsActive = 1

DECLARE @InventoryID INT

DECLARE @QuantityInHand INT

-- Declare a CURSOR to hold ID, Quantity  
DECLARE @GetInventoryID CURSOR

SET @GetInventoryID = CURSOR FOR SELECT
	ID
   ,AvailableQuantity
FROM dbo.StockDetail
WHERE ProductID = @ProductID
AND IsActive = 1
ORDER BY InsertedDate


    -- Open the CURSOR  
    OPEN @GetInventoryID


    -- Fetch record from the CURSOR  
    FETCH NEXT FROM @GetInventoryID
    INTO @InventoryID,
         @QuantityInHand


    -- Loop if record found in CURSOR  
    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- Check if Order quantity becomes 0  
        IF @OrderQuantity = 0
        BEGIN

            PRINT 'Updated Successfully'
           
            RETURN 1

        END

        -- If Order Qty is less than or equal to Quantity In Hand  
        IF @OrderQuantity <= @QuantityInHand
        BEGIN
INSERT INTO dbo.OrderDetails (OrderId,
dbo.StockDetailId,
QuantityDeliverd)
	SELECT
		@OrderId
	   ,Id
	   ,@OrderQuantity AS QuantityDeliverd
	FROM dbo.StockDetail
	WHERE Id = @InventoryID

UPDATE dbo.StockDetail
SET AvailableQuantity = AvailableQuantity - @OrderQuantity
WHERE ID = @InventoryID

SET @OrderQuantity = 0

        END
        -- If Order Qty is greater than Quantity In Hand  
        ELSE
        BEGIN
INSERT INTO dbo.OrderDetails (OrderId,
dbo.StockDetailId,
QuantityDeliverd)
	SELECT
		@OrderId
	   ,Id
	   ,(AvailableQuantity) AS QuantityDeliverd
	FROM dbo.StockDetail
	WHERE Id = @InventoryID

UPDATE dbo.StockDetail
SET AvailableQuantity = 0
WHERE ID = @InventoryID

SET @OrderQuantity = @OrderQuantity - @QuantityInHand

        END


        FETCH NEXT FROM @GetInventoryID
        INTO @InventoryID,
             @QuantityInHand

    END


    -- Close and  Deallocate CURSOR  
    CLOSE @GetInventoryID

    DEALLOCATE @GetInventoryID


END
GO
/****** Object:  StoredProcedure [dbo].[UpsertCategory]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [dbo].[UpsertCategory]   
@Id int,  
@DistributorId int,  
@Name varchar(300),
@Description varchar(500),
@FilePath varchar(400)='',
@InsertedDate datetime=null,  
@UpdatedDate datetime=null,  
@InsertedByUserId int,   
@UpdatedByUserId int   
AS   
BEGIN  
   if(@Id = 0)   
   begin  
      INSERT INTO  
         Category( DistributorId,Name,Description,FilePath,  InsertedDate, UpdatedDate, InsertedByUserId, UpdatedByUserId )   
      values  
         (  
            @DistributorId,@Name,@Description,@FilePath, GETDATE(), null, @InsertedByUserId, null   
         )  
   select 1  
   end  
   else if(@Id != 0)  
      begin  
         Update  
            Category   
         set  
            DistributorId = @DistributorId,Name =@Name,Description=@Description,FilePath =(case when RTRIM(LTRIM(ISNULL(@FilePath,''))) ='' then FilePath else @FilePath end ),  UpdatedDate = @UpdatedDate, UpdatedByUserId = @UpdatedByUserId   
         WHERE  
            Id = @Id   
   select 2  
      end  
   else   
   begin  
   SELECT 0  
   end  
END  
GO
/****** Object:  StoredProcedure [dbo].[UpsertCompany]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UpsertCompany] 
@Id int,
@DistributorId int,
@Name varchar(300),
@Description varchar(500),
@FilePath varchar(400)='',
@CategoryId int,
@InsertedDate datetime=null,
@UpdatedDate datetime=null,
@InsertedByUserId int, 
@UpdatedByUserId int 
AS 
BEGIN
   if(@Id = 0) 
   begin
      INSERT INTO
         Company( DistributorId,Name,Description,CategoryId,FilePath,  InsertedDate, UpdatedDate, InsertedByUserId, UpdatedByUserId ) 
      values
         (
            @DistributorId,@Name,@Description,@CategoryId,@FilePath, GETDATE(), null, @InsertedByUserId, null 
         )
		 select 1
   end
   else if(@Id != 0)
      begin
         Update
            Company 
         set
            DistributorId = @DistributorId,Name=@Name,Description=@Description, CategoryId=@CategoryId,FilePath =(case when RTRIM(LTRIM(ISNULL(@FilePath,''))) ='' then FilePath else @FilePath end ),UpdatedDate = @UpdatedDate, UpdatedByUserId = @UpdatedByUserId 
         WHERE
            Id = @Id 

			select 2
      end
	  else 
	  begin
	  SELECT 0
	  end
END
GO
/****** Object:  StoredProcedure [dbo].[UpsertOrder]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UpsertOrder]   
@Id int=0,  
@DistributorId int,  
@OrderStatusId int,  
@ProductId int,   
@CustomerId int,  
  
@Quantity int,   
@Price decimal(18, 6),  
@Total decimal(18, 6),  
@OrderDate datetime=null,   
@InsertedDate datetime=null,  
@UpdatedDate datetime=null,  
@InsertedByUserId int,   
@UpdatedByUserId int ,  
@IsActive bit  
AS   
BEGIN
  
   if(@Id = 0)   
   begin
  
   IF exists (SELECT
		*
	FROM OrderMaster
	WHERE CustomerId = @CustomerId
	AND ProductId = @ProductId
	AND DistributorId = @DistributorId
	AND OrderStatusId = 1
	AND IsActive = 1)
BEGIN
UPDATE OrderMaster
SET Price = @Price
   ,Quantity = Quantity + @Quantity
   ,Total = ((Quantity + @Quantity) * @Price)
   ,UpdatedByUserId = @InsertedByUserId
   ,UpdatedDate = @InsertedDate
   ,OrderDate = @OrderDate
WHERE CustomerId = @CustomerId
AND ProductId = @ProductId
AND DistributorId = @DistributorId
AND OrderStatusId = 1
AND IsActive = 1
END
ELSE
BEGIN

INSERT INTO OrderMaster (DistributorId, OrderStatusId, ProductId, CustomerId, Quantity, Price, Total, OrderDate, InsertedDate, UpdatedDate, InsertedByUserId, UpdatedByUserId, IsActive)
	VALUES (@DistributorId, @OrderStatusId, @ProductId, @CustomerId, @Quantity, @Price, @Total, @OrderDate, GETDATE(), NULL, @InsertedByUserId, NULL, @IsActive)
END
END
ELSE
IF (@Id != 0)
BEGIN
UPDATE OrderMaster
SET DistributorId = @DistributorId
   ,OrderStatusId = @OrderStatusId
   ,ProductId = @ProductId
   ,CustomerId = @CustomerId
   ,Quantity = @Quantity
   ,Price = @Price
   ,Total = @Total
   ,UpdatedDate = @UpdatedDate
   ,UpdatedByUserId = @UpdatedByUserId
   ,IsActive = @IsActive
WHERE Id = @Id
END
ELSE
BEGIN
SELECT
	'no oprtion done'
END
END
GO
/****** Object:  StoredProcedure [dbo].[UpsertTransaction]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UpsertTransaction]   
@Id                INT,  
@DistributorId INT,  
@CustomerId        INT,  
@Amount            DECIMAL(18, 6),  
@TransactionDate   DATETIME=NULL,  
@Notes             NVARCHAR(500),  
@InsertedByUserId  INT,  
@UpdatedByUserId   INT  
AS  
  BEGIN  
      IF( @Id = 0 )  
        BEGIN  
            INSERT INTO TransactionMaster  
                        (DistributorId,  
                         CustomerId,  
                         Amount,  
                         TransactionDate,  
                         Notes,  
                         InsertedDate,  
                         UpdatedDate,  
                         InsertedByUserId,  
                         UpdatedByUserId)  
            VALUES      ( @DistributorId,  
                          @CustomerId,  
                          @Amount,  
                          @TransactionDate,  
                          @Notes,  
                          Getdate(),  
                          NULL,  
                          @InsertedByUserId,  
                          NULL )  
        select 0  
        END  
      ELSE IF( @Id != 0 )  
        BEGIN  
            UPDATE TransactionMaster  
            SET    DistributorId = @DistributorId,  
                   CustomerId = @CustomerId,  
                   Amount = @Amount,  
                   Notes = @Notes,  
                   TransactionDate = @TransactionDate,  
                   UpdatedDate = GETDATE(),  
                   UpdatedByUserId = @UpdatedByUserId  
            WHERE  Id = @Id  
   select 1  
        END  
      ELSE  
        BEGIN  
            SELECT 2  
        END  
  END  
GO
/****** Object:  StoredProcedure [dbo].[usp_GetTableIdsForLogin]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_GetTableIdsForLogin]
@TableName varchar(100),
@UserId int
 AS 
 BEGIN
IF(@TableName='Admin')
BEGIN
SELECT TOP 1
	*
FROM dbo.Admin
WHERE UserId = @UserId
END
ELSE
IF (@TableName = 'Distributor')
BEGIN
SELECT TOP 1
	*
FROM dbo.Distributor
WHERE UserId = @UserId
END
ELSE
IF (@TableName = 'Customer')
BEGIN
SELECT TOP 1
	*
FROM dbo.Customer
WHERE UserId = @UserId
END
ELSE
BEGIN
SELECT
	0
END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetUserForLogin]    Script Date: 20-11-2022 20:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_GetUserForLogin]
@UserName nvarchar(100),
@Password nvarchar(100)
AS
 BEGIN
SELECT TOP 1
	*
FROM Users
WHERE TRIM(UserName) = TRIM(@UserName)
AND TRIM(Password) = TRIM(@Password)
AND ISNULL(IsActive, 0) = 1
END
GO
USE [master]
GO
ALTER DATABASE [AKStore] SET  READ_WRITE 
GO
