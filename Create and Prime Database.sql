-- https://enbala.atlassian.net/browse/IC-1734
-- 2 hour timeboxed spike to start the basics of a data quality framework

CREATE SCHEMA DataQuality;

CREATE TABLE DataQuality.Tests (
TestID           INT IDENTITY PRIMARY KEY,
TestName         NVARCHAR(50) NOT NULL,
DatabaseName     NVARCHAR(255) NOT NULL,
SchemaName       NVARCHAR(255) NOT NULL,
TableName        NVARCHAR(255) NOT NULL,
ColumnName       NVARCHAR(255) NOT NULL,
isJSON           BIT NOT NULL,
ArrayName        NVARCHAR(255) NULL,
ElementName      NVARCHAR(255) NULL,
ShortDescription NVARCHAR(50) NOT NULL,
[Description]    NVARCHAR(MAX) NULL,
TestFileName     NVARCHAR(MAX) NOT NULL
);

CREATE TABLE DataQuality.TestSetMaster (
TestSetID        INT IDENTITY PRIMARY KEY,
TestSetName      NVARCHAR(50) NOT NULL
);

CREATE TABLE DataQuality.TestSetDetail (
TestSetID        INT NOT NULL,
TestSetDetailID  INT IDENTITY PRIMARY KEY,
TestID           INT NOT NULL
);

CREATE TABLE DataQuality.TestExecutionMaster (
TestExecutionMasterID INT IDENTITY PRIMARY KEY,
TestSetID        INT NOT NULL,
StartTime        DATETIME NULL,
EndTime          DATETIME NULL,
TotalRowCount    INT NULL,
FailedRowCount   INT NULL,
OverallResult    INT NULL  -- 0=Success, 1=Fail (might be a WARN in the future?)
)

CREATE TABLE DataQuality.TestExecutionDetail (
TestExecutionMasterID INT NOT NULL,
TestSetID        INT NOT NULL,
TestID           INT NOT NULL,
StartTime        DATETIME NULL,
EndTime          DATETIME NULL,
TotalRowCount    INT NULL,
FailedRowCount   INT NULL,
Result           INT NULL  -- 0=Success, 1=Fail (might be a WARN in the future?)
);

INSERT INTO DataQuality.Tests 
            (TestID,TestName, DatabaseName, SchemaName, TableName, ColumnName, isJSON, 
             ArrayName, ElementName, ShortDescription, [Description], TestFileName)
     VALUES (1, 'ResourceVault-Equipment-GenSet JSON Rated KW TypeConversion', 'ResourceVault', 'dbo', 'ResourceAttribute', TRUE,
             '.Attributes', 'Rated KW', 'ResourceVault-Equipment-GenSet JSON: Rated KW TypeConversion',' ','001-ResourceVault-Equipment-GenSet JSON Rated KW TypeConversion.sql')),
            (2, 'ResourceVault-Equipment-GenSet JSON Rated KW InvalidData', 'ResourceVault', 'dbo', 'ResourceAttribute', TRUE,
             '.Attributes', 'Rated KW', 'ResourceVault-Equipment-GenSet JSON Rated KW InvalidData',' ','002-ResourceVault-Equipment-GenSet JSON Rated KW InvalidData.sql');

INSERT INTO DataQuality.TestSetMaster ( TestSetID, TestSetName )
     VALUES                           (         1, 'Full Suite - All Tests');


INSERT INTO  DataQuality.TestSetDetail ( TestSetID, TestSetDetailID, TestID )
     VALUES                            (         1,               1,      1 ), 
                                       (         1,               2,      2 );