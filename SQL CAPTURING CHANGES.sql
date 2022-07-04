--Inserting data to Stage table 

set nocount on

Declare @actualdatetime datetime
Set @actualdatetime = GETDATE()

drop table Stage.Staging_Project_Management_Statuses

create table Stage.Staging_Project_Management_Statuses (
	ProjectID int not null Primary Key
	,Preparation_Status varchar(50) not null
	,Initiation_Status varchar(50) not null
	,Strategic_Management_Status varchar(50) not null
	,Introducing_Status varchar(50) not null
	,Stage_Control_Status varchar(50) not null
	,PDM_Status varchar(50) not null
	,Ending_Status varchar(50) not null
	,Payment_Status varchar(50) not null
	)
Insert into Stage.Staging_Project_Management_Statuses 
( ProjectID
, Preparation_Status
, Initiation_Status
, Strategic_Management_Status
, Introducing_Status
, Stage_Control_Status
, PDM_Status
, Ending_Status
, Payment_Status
)
Values 
('1', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 5%')
,('2', 'Finished', 'Finished', 'In Progress', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Paid in 10%')
,('3', 'Finished', 'Finished', 'In Progress', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Paid in 30%')
,('4', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 50%')
,('5', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Paid in 95%')
,('6', 'Finished', 'Finished', 'Finished', 'In Progress', 'In Progress', 'In Progress', 'Not started', 'Paid in 50%')
,('7', 'Finished', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 50%')
,('8', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 40%')
,('9', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'In Progress', 'Paid in 100%')
,('10', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 0%');

--Inserting data to fact table

drop table Facts.Project_Management_Statuses

create table Facts.Project_Management_Statuses (
	ProjectID int not null Primary Key
	,Preparation_Status varchar(50) not null
	,Initiation_Status varchar(50) not null
	,Strategic_Management_Status varchar(50) not null
	,Introducing_Status varchar(50) not null
	,Stage_Control_Status varchar(50) not null
	,PDM_Status varchar(50) not null
	,Ending_Status varchar(50) not null
	,Payment_Status varchar(50) not null
	)

Insert into Facts.Project_Management_Statuses 
( ProjectID
, Preparation_Status
, Initiation_Status
, Strategic_Management_Status
, Introducing_Status
, Stage_Control_Status
, PDM_Status
, Ending_Status
, Payment_Status
)
Values 
('1', 'In Progress', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 15%')
,('2', 'Finished', 'Finished', 'Finished', 'Finished', 'In Progress', 'Not started', 'Not started', 'Paid in 20%')
,('3', 'Finished', 'Finished', 'In Progress', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Paid in 30%')
,('4', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 50%')
,('5', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Paid in 95%')
,('6', 'Finished', 'Finished', 'Finished', 'In Progress', 'In Progress', 'In Progress', 'Not started', 'Paid in 50%')
,('7', 'Finished', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 50%')
,('8', 'In Progress', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 60%')
,('9', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'Finished', 'In Progress', 'Paid in 100%')
,('10', 'Finished', 'In Progress', 'Not started', 'Not started', 'Not started', 'Not started', 'Not started', 'Paid in 10%');

drop table dbo.capturedChanges

Create table dbo.CapturedChanges (
	ProjectID int not null 
	,StatusName varchar(50)
	,Status varchar(50)
	,ChangeDateTime datetime
	)

--I want to capture changed statuses between Stage and Facts level
--Firstly I have to unpivot my data to get easier to compare data
;with StagingUnpivot as (
Select 
	ProjectID
	,[StatusName]
	,[Status]
	
from Stage.Staging_Project_Management_Statuses
UNPIVOT
(
 [Status] for [StatusName] IN (Preparation_Status, Initiation_Status, Strategic_Management_Status, Introducing_Status, Stage_Control_Status, PDM_Status, Ending_Status, Payment_Status)

) as up
)
,
FactsUnpivot as (
Select 
	ProjectID
	,[StatusName]
	,[Status]
	
from Facts.Project_Management_Statuses 
UNPIVOT
(
 [Status] for [StatusName] IN (Preparation_Status, Initiation_Status, Strategic_Management_Status, Introducing_Status, Stage_Control_Status, PDM_Status, Ending_Status, Payment_Status)

) as up
)
--Secondly I want to get an information which Statuses have been changed
,
CompareData as (
Select [ProjectID], [StatusName], [Status] from FactsUnpivot
except
Select [ProjectID], [StatusName], [Status] from StagingUnpivot
)
--Thirdly, If something changes then I want to get actual datetime
Insert into dbo.CapturedChanges (
	ProjectID
	,StatusName
	,[Status]
	,[ChangeDatetime] )
select 
	ProjectID
	,StatusName
	,[Status]
	,@actualdatetime
from CompareData

