CREATE PROC partwise_availiblity        
@brandid VARCHAR(Max)        
AS        
BEGIN        
        
--DECLARE @BrandID    VARCHAR(MAX) = 32;        
DECLARE @DealerID   VARCHAR(MAX);                        
DECLARE  @max int;                          
DECLARE  @td int;                            
DECLARE @Perc  NVARCHAR(20)        
        
set @max = 1        
select @td = COUNT(distinct dealerid) from Dealer_Workshop_Master        
where BrandID = @brandid         
AND Status = 1          
AND DEALERID IN ('20208', '20796', '20375', '20344', '20385', '20422', '20399', '20374', '20951', '20396', '20425','20426')        
                   
PRINT CONCAT('In This Brandid ', @brandid, ' TOTAL NO OF Dealers= ', @Td);         
        
declare @Grouptbl varchar(MAX);        
        
DECLARE @sql NVARCHAR(MAX);        
DECLARE @D1 NVARCHAR(MAX);        
DECLARE @D2 NVARCHAR(MAX);        
DECLARE @D3 NVARCHAR(MAX);        
DECLARE @D4 NVARCHAR(MAX);        
DECLARE @D5 NVARCHAR(MAX);        
DECLARE @D6 NVARCHAR(MAX);        
DECLARE @D7 NVARCHAR(MAX);        
        
-- Set the dates for the last 7 days        
SELECT @D1 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AS VARCHAR(43));        
SELECT @D2 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -2, GETDATE()) AS DATE) AS VARCHAR(43));        
SELECT @D3 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -3, GETDATE()) AS DATE) AS VARCHAR(43));        
SELECT @D4 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -4, GETDATE()) AS DATE) AS VARCHAR(43));        
SELECT @D5 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -5, GETDATE()) AS DATE) AS VARCHAR(43));        
SELECT @D6 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -6, GETDATE()) AS DATE) AS VARCHAR(43));        
SELECT @D7 = 'Stock qty on ' + CAST(CAST(DATEADD(DAY, -7, GETDATE()) AS DATE) AS VARCHAR(43));        
        
--------------------- table create and drop table        
        
set @Grouptbl = 'Uad_Partwise_Toc_' + @brandid        
print (@Grouptbl)        
        
SET @sql = '        
drop table ' + @Grouptbl + '        
        
CREATE TABLE ' + @Grouptbl + ' (        
    Dealer Varchar(max),        
    Location Varchar(max),        
    Consignee_Type Varchar(max),        
    Toc_Partnumber Varchar(Max),        
    Latest_partnumber Varchar(Max),        
    Orderpartnumber Varchar(Max),        
    Description Varchar(Max),        
    Category Varchar(Max),        
    Rate Decimal(18,2),        
    N1 Decimal (18,2),        
    N2 Decimal (18,2),        
    N3 Decimal (18,2),        
    Avg_Sales Decimal (18,2),        
    Toc_qty Decimal(10,2),        
    SCS_Norms Decimal(18,2),        
    Toc_updated Varchar(max),        
    Stock_upload_date Varchar(Max),        
    ' + QUOTENAME(@D1) + ' DECIMAL(10, 2),        
    ' + QUOTENAME(@D2) + ' DECIMAL(10, 2),        
    ' + QUOTENAME(@D3) + ' DECIMAL(10, 2),        
    ' + QUOTENAME(@D4) + ' DECIMAL(10, 2),        
    ' + QUOTENAME(@D5) + ' DECIMAL(10, 2),        
    ' + QUOTENAME(@D6) + ' DECIMAL(10, 2),        
    ' + QUOTENAME(@D7) + ' DECIMAL(10, 2)        
);'        
        
EXEC sp_executesql @sql;        
        
WHILE(@max <= @td)         
BEGIN        
    select @dealerid = Dealerid from (        
        select Dealerid, ROW_NUMBER() over (order by dealerid asc) m        
        from (        
            select Dealerid, ROW_NUMBER() over (partition by dealerid order by dealerid asc) w        
            from Dealer_Workshop_Master        
            where BrandID = @BrandID AND Status = 1         
            AND DEALERID IN ('20208', '20796', '20375', '20344', '20385', '20422', '20399', '20374', '20951', '20396', '20425','20426')        
        ) as td        
        where w = 1        
    ) as tes        
    where m = @max        
        
    PRINT(@max);        
    PRINT(@dealerID);        
        
    DECLARE @tbl NVARCHAR(MAX);        
    DECLARE @stktbl NVARCHAR(MAX);        
    DECLARE @maxtbl NVARCHAR(MAX);        
        
    -- Set the table names dynamically        
    SET @tbl = '[10.10.152.17].[z_scope].[dbo].[ogs_Toc_td001_' + @dealerid + ']';        
    SET @stktbl = 'stock_upload_spm_td001_' + @dealerid;        
    SET @maxtbl = 'Stockable_NonStockable_TD001_' + @dealerid;        
        
    -- Build dynamic SQL for report generation        
    SET @sql = '        
    INSERT INTO ' + @Grouptbl + '        
    SELECT ta.Dealer AS Dealer,        
           ta.Location AS Location,        
           ta.Consignee_type AS Consignee_Type,        
           ta.Toc_Partnumber,        
           ta.Latest_partnumber,        
           pm.orderpartno as Orderpartnumber,        
           pm.partdesc as Description,        
           pm.parttype as Category,        
    pm.landedcost as Rate,            
           isnull(max_tbl.n1,0) AS N1,        
           isnull(max_tbl.n2,0) AS N2,        
           isnull(max_tbl.n3,0) AS N3,        
           ISNULL(max_tbl.Avg3MSale, 0) AS Avg_Sales,        
           ta.Toc_qty,        
           ISNULL(max_tbl.MAXVALUE, 0) AS SCS_Norms,        
           ta.Toc_updated,        
           ta.Stock_upload_date,        
           ta.[' + @D1 + '],        
           ta.[' + @D2 + '],        
           ta.[' + @D3 + '],        
           ta.[' + @D4 + '],        
           ta.[' + @D5 + '],        
           ta.[' + @D6 + '],        
           ta.[' + @D7 + ']        
    FROM (        
        SELECT b.brandid,        
               b.Dealer AS Dealer,        
               b.Location AS Location,        
               d.Consignee_type AS Consignee_Type,        
               TOC.Locationid AS Locationid,        
               toc.partnumber AS Toc_Partnumber,        
               (CASE WHEN toc.brandid = sub.brandid AND toc.partnumber = sub.partnumber        
                     THEN sub.subpartnumber ELSE toc.partnumber END) AS Latest_partnumber,        
               toc.qty AS Toc_qty,        
               toc.date AS Toc_updated,        
               CAST(s.maxdate AS DATE) AS Stock_upload_date,        
               ISNULL(stock_qty.day1, 0) AS [' + @D1 + '],        
               ISNULL(stock_qty.day2, 0) AS [' + @D2 + '],        
               ISNULL(stock_qty.day3, 0) AS [' + @D3 + '],        
               ISNULL(stock_qty.day4, 0) AS [' + @D4 + '],        
               ISNULL(stock_qty.day5, 0) AS [' + @D5 + '],        
               ISNULL(stock_qty.day6, 0) AS [' + @D6 + '],        
               ISNULL(stock_qty.day7, 0) AS [' + @D7 + ']        
        FROM ' + @tbl + ' AS toc        
        INNER JOIN locationinfo b ON toc.locationid = b.locationid        
        LEFT JOIN dealer_setting_master d ON b.locationid = d.locationid        
        LEFT JOIN (SELECT partnumber, subpartnumber, brandid FROM Substitution_Master) AS sub        
            ON toc.partnumber = sub.partnumber AND toc.brandid = sub.brandid        
        LEFT JOIN (        
            SELECT locationid, partnumber, qty        
            FROM ' + @stktbl + '        
            WHERE CONCAT(locationid, stockdate) IN (        
                SELECT CONCAT(locationid, MAX(stockdate))        
                FROM ' + @stktbl + '        
                GROUP BY locationid        
            )        
        ) AS tbl ON toc.locationid = tbl.locationid AND toc.partnumber = tbl.partnumber        
        LEFT JOIN (        
            SELECT locationid, MAX(stockdate) AS maxdate        
            FROM ' + @stktbl + '        
            GROUP BY locationid        
        ) AS s ON toc.locationid = s.locationid        
        LEFT JOIN (        
            SELECT brandid,        
                   locationid,        
                   partnumber,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day1,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -2, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day2,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -3, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day3,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -4, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day4,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -5, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day5,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -6, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day6,        
                   SUM(CASE WHEN CAST(stockdate AS DATE) = CAST(DATEADD(DAY, -7, GETDATE()) AS DATE) THEN qty ELSE 0 END) AS day7        
            FROM ' + @stktbl + '        
            GROUP BY locationid, partnumber, brandid        
        ) AS stock_qty ON toc.locationid = stock_qty.locationid AND toc.partnumber = stock_qty.partnumber        
        WHERE CONCAT(toc.locationid, toc.date) IN (        
            SELECT CONCAT(locationid, MAX(date))        
            FROM ' + @tbl + '        
            GROUP BY locationid        
        ) AND b.status = 1         
        AND toc.qty > 0        
    ) AS ta        
    LEFT JOIN (        
        SELECT locationid, partnumber, partnumber1, n1, n2, N3, Avg3MSale, MAXVALUE        
        FROM ' + @maxtbl + '        
        WHERE CONCAT(locationid, stockdate) IN (        
            SELECT CONCAT(locationid, MAX(stockdate))        
            FROM ' + @maxtbl + '        
            GROUP BY locationid        
        )        
    ) max_tbl        
    ON ta.locationid = max_tbl.locationid AND ta.Latest_partnumber = max_tbl.partnumber        
    INNER JOIN VW_PartMaster AS pm ON ta.Latest_partnumber = pm.partno AND ta.brandid = pm.brandid        
    ';        
        
-- Print the dynamic SQL to debug        
PRINT @sql;        
        
SET @max = @max + 1        
        
-- Execute the dynamic SQL        
EXEC sp_executesql @sql;        
END        
        
        
exec location_groupwise_availiblity'32'        
exec Dealer_Groupwise_availiblity '32'        
end    
    