
Declare @startDate date
set @startDate = '2020/01/01'
--I don't want to insert 365 dates to temporary calendar table, so I use CTE below to get dates from 2020-01-01 to 2020-12-31
;with generatenumbers as (
SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n)
)
,numbers as (
select top (366)
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as generateseries
from generatenumbers ones
 , generatenumbers tens
 , generatenumbers hundreds
 )
 ,calendar as (
 select 
	Cast(DATEADD(day,generateseries-1, @startDate) as date) as [Dates] 
	from numbers
 )
 ,
 advancedcalendar as (
 select 
	[Dates]  
 ,DATEPART(dw, [Dates]) as [Dayofweek]
 from calendar
 )
 ,calendar_with_workdays as (
select 
	Dates
	,WorkDays	
from advancedcalendar
--I often use cross aply instead inserting case when statement to select statement, because I often filter my data and I don't want to compute case when statement again
	cross apply (values(Case when [Dayofweek] < 6 then 1 else 0 end)) calendarworkingdays(WorkDays)
where 
	WorkDays = 1
)
,
calendar_with_cnt_workingdays as (
select 
	Dates
	,YEAR([DATES]) AS[YEAR]
	,MONTH([DATES]) AS [MONTH]
	,DAY([DATES]) AS [DAY]
	,COUNT(WorkDays) Over(Partition by [Year],[Month]) as cnt_WorkingDays

from calendar_with_workdays

)

select 
	Dates
	,[YEAR]
	,[MONTH]
	,[DAY]
	,cnt_WorkingDays
from calendar_with_cnt_workingdays