CREATE PROCEDURE UpdateWatermark
@TableName Varchar(200),
@LastModifiedDate DATETIME
AS
BEGIN
	UPDATE WatermarkTable
	SET LastModifiedDate = @LastModifieddate
	WHERE TableName = @TableName
END	