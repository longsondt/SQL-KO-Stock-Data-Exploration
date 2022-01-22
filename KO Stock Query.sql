	-- COCA COLA STOCK DATA (1962 - 2021) EXPLORATION PROJECT -- 
						-- Bruce Doan --


	-- 1. Simple data exploration --  

/* Premilinary view of the original data set */
SELECT * 
FROM dbo.['COCO COLA$']


/* Find the dates that has the highest closing price */
SELECT *
FROM dbo.['COCO COLA$']
WHERE [Close] = (SELECT MAX([Close]) FROM dbo.['COCO COLA$']);


/* Find the dates that has the highest volume traded */
SELECT * 
FROM dbo.['COCO COLA$']
WHERE [Volume] = (SELECT MAX([Volume]) FROM dbo.['COCO COLA$']);


/* Calculate the daily percentage change */
SELECT *, (([Close] - [Open])/[Open]) * 100 AS [Daily change in %]
FROM dbo.['COCO COLA$'];


/* Calculate the arithmetic average daily return over the entire period of the data set */ 
WITH CTE_KO as ( 
SELECT [Date], [Open], [Close], (([Close] - [Open])/[Open]) * 100 as [Daily change in %]
FROM dbo.['COCO COLA$']
)
SELECT AVG([Daily change in %]) as [Average daily return %]
FROM CTE_KO;


	-- 2. Produce a yearly data set from the original daily data set --

	/* GOAL: Use the daily data set to produce a yearly data set that contains 
	The Year, and Open, Close, High, Close, and Total Volume Traded of that year */

/* Create Temp table that includes a ROW_NUMBER function for later use */
DROP TABLE IF EXISTS #temp_KO
CREATE TABLE #temp_KO
( 
	[Year] int, 
	[Date#] int, 
	[Open] float, 
	[High] float,
	[Low] float, 
	[Close] float, 
	[Adj Close] float, 
	[Volume] float,
	[Rolling sum of volume traded] float
) 
INSERT INTO #temp_KO
SELECT DATEPART(year, a.[Date]) as [Year], 
	    ROW_NUMBER() OVER(PARTITION BY DATEPART(year, a.[Date]) ORDER BY a.[Date]) as [Date#],
		a.[Open],
		a.[High],
		a.[Low],
		a.[Close],
		a.[Adj Close],
		a.[Volume],
		SUM(CAST(a.[Volume] AS bigint)) OVER (PARTITION BY DATEPART(year, a.[Date]) ORDER BY b.[Date]) as [Rolling sum of volume traded]
FROM dbo.['COCO COLA$'] a 
JOIN dbo.['COCO COLA$'] b
ON a.[Date] = b.[Date];

/* View the temp table */
SELECT * FROM #temp_KO;


/* Create the new yearly data table  */
DROP TABLE IF EXISTS [COCA COLA yearly data 1962 - 2021] 
CREATE TABLE [COCA COLA yearly data 1962 - 2021] 
(
	[Year] int,
	[Open] float,
	[Close] float,
	[High] float,
	[Low] float,
	[Total volume traded] float
);

/* Compile the required data using MULTIPLE CTEs and INSERT into the new table */ 
WITH KO_Yearly_Open AS (
SELECT [Year], [Open]
FROM #temp_KO
WHERE [Date#] = (SELECT MIN([Date#]) FROM #temp_KO)
),
KO_Yearly_Close AS (
SELECT a.[Year], a.[Close]
	FROM #temp_KO a
	INNER JOIN (SELECT [Year], MAX([Date#]) as [Last day of year]
				FROM #temp_KO
				GROUP BY [Year]) as b
	ON a.[Date#] = b.[Last day of year] AND a.[Year] = b.[Year]
),
KO_Yearly_High AS (
SELECT [Year], MAX([High]) as [High]
FROM #temp_KO
GROUP BY [Year]
),
KO_Yearly_Low AS (
SELECT [Year], MIN([Low]) as [Low]
FROM #temp_KO
GROUP BY [Year]
),
KO_Yearly_TotalVolumeTraded AS (
SELECT a.[Year], 
	   a.[Rolling sum of volume traded] as [Total volume traded]
FROM #temp_KO a
INNER JOIN (SELECT [Year], MAX([Date#]) as [Last day of year]
			FROM #temp_KO
			GROUP BY [Year]) as b
ON a.[Date#] = b.[Last day of year] AND a.[Year] = b.[Year]
)
INSERT INTO dbo.[COCA COLA yearly data 1962 - 2021]
SELECT a.[Year], [Open], [Close], [High], [Low], [Total volume traded]
FROM [KO_Yearly_Open] a 
FULL JOIN KO_Yearly_Close b
ON a.[Year] = b.[Year]
FULL JOIN KO_Yearly_High c
ON a.[Year] = c.[Year]
FULL JOIN KO_Yearly_Low d 
ON a.[Year] = d.[Year]
FULL JOIN KO_Yearly_TotalVolumeTraded e
ON a.[Year] = e.[Year];

/* View the new table */
SELECT * 
FROM dbo.[COCA COLA yearly data 1962 - 2021];


	-- 3. Data Exploration of the new yearly data -- 

/* Find the top 5 years with the highest/lowest closing price */
/* This query could also be applied to Total volume traded */ 
SELECT TOP 5 [Year], [Close]
FROM dbo.[COCA COLA yearly data 1962 - 2021]
ORDER BY [Close] DESC; -- ASC /* For lowest */


/* Find the year when the stock reaches/dips highest/lowest within a specified period */
/* This query could also be applied to Total volume traded */ 
SELECT * 
FROM dbo.[COCA COLA yearly data 1962 - 2021]
/* WHERE [High] = (
	SELECT MAX([High]) from dbo.[COCA COLA yearly data 1962 - 2021] WHERE 2000 <= [Year] AND [Year] <= 2021
	); */ 
WHERE [Low] = (
	SELECT Min([Low]) from dbo.[COCA COLA yearly data 1962 - 2021] WHERE 2000 <= [Year] AND [Year] <= 2021
	);


/* Calculate the yearly return in % */
SELECT a.[Year], 
	   ((a.[Close] - b.[Close]) / b.[Close]) * 100 as [Yearly return in %]
FROM dbo.[COCA COLA yearly data 1962 - 2021] a 
INNER JOIN dbo.[COCA COLA yearly data 1962 - 2021] b 
ON a.[Year] = b.[Year] + 1
ORDER BY [Year];


/* Calculate the ARITHMETIC mean return of the stock from any specified period */
WITH yearly_return AS
(
	SELECT a.[Year], 
		   ((a.[Close] - b.[Close]) / b.[Close]) * 100 AS [Yearly return in %]
	FROM dbo.[COCA COLA yearly data 1962 - 2021] a 
	INNER JOIN dbo.[COCA COLA yearly data 1962 - 2021] b 
	ON a.[Year] = b.[Year] + 1
)
SELECT AVG([Yearly return in %]) AS [Arithmetic mean return]
FROM yearly_return
WHERE 2000 <= [Year] AND [Year] <= 2021


/* Find the GEOMETRIC mean return of the stock from any specified period */ 
WITH yearly_return AS
(
	SELECT a.[Year], 
		   ((a.[Close] - b.[Close]) / b.[Close]) * 100 AS [Yearly return in %]
	FROM dbo.[COCA COLA yearly data 1962 - 2021] a 
	INNER JOIN dbo.[COCA COLA yearly data 1962 - 2021] b 
	ON a.[Year] = b.[Year] + 1
)
SELECT (EXP(AVG(LOG(([Yearly return in %] / 100) + 1))) - 1) * 100 as [Arithmetic mean return in %]
FROM yearly_return
WHERE 2020 <= [Year] AND [Year] <= 2021

