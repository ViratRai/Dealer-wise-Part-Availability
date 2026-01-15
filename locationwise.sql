CREATE  PROC location_groupwise_availiblity  
@brandid VARCHAR(Max)  
AS  
BEGIN  
  
DECLARE @D1 VARCHAR(MAX);  
DECLARE @D2 VARCHAR(MAX);  
DECLARE @D3 VARCHAR(MAX);  
DECLARE @D4 VARCHAR(MAX);  
DECLARE @D5 VARCHAR(MAX);  
DECLARE @D6 VARCHAR(MAX);  
DECLARE @D7 VARCHAR(MAX);  
DECLARE @AV1 VARCHAR(MAX);  
DECLARE @AV2 VARCHAR(MAX);  
DECLARE @AV3 VARCHAR(MAX);  
DECLARE @AV4 VARCHAR(MAX);  
DECLARE @AV5 VARCHAR(MAX);  
DECLARE @AV6 VARCHAR(MAX);  
DECLARE @AV7 VARCHAR(MAX);  
DECLARE @stktbl NVARCHAR(MAX);  
DECLARE @sql NVARCHAR(MAX);  
DECLARE @DEALERID NVARCHAR(MAX);  
  
  
SELECT @AV1 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @AV2 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -2, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @AV3 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -3, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @AV4 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -4, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @AV5 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -5, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @AV6 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -6, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @AV7 = 'Availability % on ' + CAST(CAST(DATEADD(DAY, -7, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D1 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D2 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -2, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D3 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -3, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D4 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -4, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D5 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -5, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D6 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -6, GETDATE()) AS DATE) AS VARCHAR(43));  
SELECT @D7 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -7, GETDATE()) AS DATE) AS VARCHAR(43));  
  
SET @stktbl = 'stock_upload_spm_td001_' + @dealerid;  
  
  
--PRINT(@D1);  
SET @sql = '  
SELECT TBL.DEALER AS DEALER, TBL.LOCATION AS Location,Consignee_Type,L.BDM,Toc_updated AS Last_TOC_updated_in_scope,  
Stock_upload_date AS Last_stock_date_updated,LOC AS No_TOC_updated_parts,  
(CASE   
            WHEN TBL.D1 > 0 THEN 1 ELSE 0 END +   
        CASE   
            WHEN TBL.D2 > 0 THEN 1 ELSE 0 END +   
        CASE   
            WHEN TBL.D3 > 0 THEN 1 ELSE 0 END +   
        CASE   
            WHEN TBL.D4 > 0 THEN 1 ELSE 0 END +   
        CASE   
            WHEN TBL.D5 > 0 THEN 1 ELSE 0 END +   
        CASE   
            WHEN TBL.D6 > 0 THEN 1 ELSE 0 END +   
        CASE   
            WHEN TBL.D7 > 0 THEN 1 ELSE 0 END   
       ) AS Stock_update_last_7_days,  
       CAST(ROUND(CAST(TBL.D1 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV1)+',  
    CAST(ROUND(CAST(TBL.D2 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV2)+',  
     CAST(ROUND(CAST(TBL.D3 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV3)+',  
   CAST(ROUND(CAST(TBL.D4 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV4)+',  
    CAST(ROUND(CAST(TBL.D5 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV5)+',  
     CAST(ROUND(CAST(TBL.D6 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV6)+',  
      CAST(ROUND(CAST(TBL.D7 AS DECIMAL(10, 2)) * 100.0 / CAST(TBL.TOC AS DECIMAL(10, 2)), 0) AS DECIMAL(10,2))AS '+QUOTENAME(@AV7)+'  
     
FROM (  
    SELECT DEALER, LOCATION,Consignee_Type,Toc_updated,Stock_upload_date,  
           COUNT(Toc_Partnumber) AS LOC,  
     COUNT(Case When toc_qty > 0  then Toc_Partnumber end) as toc,  
           COUNT(CASE WHEN ' + QUOTENAME(@D1) + ' > 0 AND  toc_qty > 0 THEN Toc_Partnumber END) AS D1,  
     COUNT(CASE WHEN ' + QUOTENAME(@D2) + ' > 0 AND toc_qty > 0 THEN  Toc_Partnumber END) AS D2,  
     COUNT(CASE WHEN ' + QUOTENAME(@D3) + ' > 0 AND  toc_qty > 0 THEN Toc_Partnumber END) AS D3,  
     COUNT(CASE WHEN ' + QUOTENAME(@D4) + ' > 0 AND  toc_qty > 0 THEN Toc_Partnumber END) AS D4,  
     COUNT(CASE WHEN ' + QUOTENAME(@D5) + ' > 0 AND  toc_qty > 0 THEN Toc_Partnumber END) AS D5,  
     COUNT(CASE WHEN ' + QUOTENAME(@D6) + ' > 0 AND  toc_qty > 0 THEN Toc_Partnumber END) AS D6,  
     COUNT(CASE WHEN ' + QUOTENAME(@D7) + ' > 0 AND  toc_qty > 0 THEN Toc_Partnumber END) AS D7  
  
    FROM Uad_Partwise_Toc_32  
    GROUP BY DEALER, LOCATION,Consignee_Type,Toc_updated,Stock_upload_date  
) AS TBL  
INNER JOIN LOCATIONINFO AS L ON CONCAT(32,TBL.DEALER,TBL.LOCATION) = CONCAT(L.BRANDID,L.DEALER,L.LOCATION)  
';  
--PRINT(@sql);    
EXEC sp_executesql @sql  
  
END 