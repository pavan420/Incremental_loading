CREATE TABLE WatermarkTable (
    TableName NVARCHAR(255),
    LastModifiedDate DATETIME
);
INSERT INTO WatermarkTable (TableName, LastModifiedDate)
VALUES ('Sales', '1900-01-01 00:00:00');

select * from [dbo].[WatermarkTable];