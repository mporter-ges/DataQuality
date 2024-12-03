DECLARE @TestID   INT = 2;
DECLARE @TestName NVARCHAR(50) = 'ResourceVault-Equipment-GenSet JSON Rated KW InvalidData';

-- Step 1: Create the needed Temp tables
CREATE TABLE #TempEquipment (
    SiteId              INT NOT NULL,
    EquipmentID         INT NOT NULL,
    EquipmentGUID       UNIQUEIDENTIFIER,
    EquipmentName       NVARCHAR(100),
    EquipmentType       NVARCHAR(100) NULL,
    EquipmentAttributes NVARCHAR(MAX),   
    PRIMARY KEY ( EquipmentID )
    );

CREATE TABLE #AttributeKVPs (
    EquipmentID        INT NOT NULL,
    [Key]              NVARCHAR(MAX) NULL,
    [Value]            NVARCHAR(MAX) NULL
    PRIMARY KEY ( EquipmentID ),    
    );

-- Step 2: Load temp tables
INSERT INTO #TempEquipment (SiteID, EquipmentID, EquipmentGUID, EquipmentName, EquipmentType, EquipmentAttributes )
     SELECT                 SiteID, EquipmentID, EquipmentGUID, EquipmentName, EquipmentType, EquipmentAttributes
       FROM Equipment;

-- Relationally grab the JSON attribute data & flatten
INSERT INTO #AttributeKVPs (EquipmentID, [Key], [Value])
     SELECT                 EquipmentID, [Key], [Value]
       FROM #TempEquipment
CROSS APPLY OPENJSON([EquipmentAttributes], '$.Attributes')  
    WITH ( [Key]   NVARCHAR(50) '$.Key',
           [Value] NVARCHAR(50) '$.Value');

DECLARE @TotalRowCount  INT = 0;
DECLARE @FailedRowCount INT = 0;

--Step 3: Start Testing
--Total Rows
    SELECT @TotalRowCount = COUNT(*) 
      FROM #TempEquipment AS e
INNER JOIN #AttributeKVPs AS akvps ON e.EquipmentID=akvps.EquipmentID
     WHERE akvps.[key]='Rated kW'
       AND e.EquipmentType='Generator Set';

--Count rows that won't type convert
SELECT @FailedRowCount = COUNT(*) 
FROM #AttributeKVPs  
WHERE [key]='Rated kW' 
   AND value in ('000','999','99999','999999','NA','TBD');

--Write test results
SELECT @TestID AS 'TestID',
       @TestName AS 'TestName', 
       @TotalRowCount AS 'TotalRowCount', 
       @FailedRowCount AS 'FailedRowCount',
       CASE 
           WHEN @TotalRowCount > 0 THEN CONVERT(FLOAT, (CAST(@FailedRowCount AS FLOAT)/CAST(@TotalRowCount AS FLOAT))) * 100
           ELSE 0
       END AS 'PercentFailure',
       CASE
          WHEN @FailedRowCount > 0 THEN 1
          ELSE 0 
       END AS 'Result';

--Write these rows to detailed output
SELECT EquipmentID, [Value]
FROM #AttributeKVPs  
WHERE [key]='Rated kW' 
   AND value in ('000','999','99999','999999','NA','TBD');

DROP TABLE #TempEquipment;
DROP TABLE #AttributeKVPs;