/*

█▀ █▀▀ █▀▀ █░█ █▀█ █ ▀█▀ █▄█
▄█ ██▄ █▄▄ █▄█ █▀▄ █ ░█░ ░█░
🆂🅴🅲🆄🆁🅸🆃🆈

*/

--##################################### create login  ######################################
USE [master]
GO

CREATE LOGIN [JohnB_rw] WITH PASSWORD=N'Password1' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON


--##################################### create role  ######################################
DECLARE @command VARCHAR(1000)
SELECT @command = 'IF ''?''
NOT IN(''master'', ''model'', ''msdb'',''SMArtXIdentityServer'',''rdsadmin'', ''tempdb'') 
BEGIN  USE ? EXEC (''create ROLE [qa.developers.rw]'') END'
EXEC sp_MSforeachdb @command

--##################################### setup  rights to role ########################################
DECLARE @command VARCHAR(1000) 
SELECT @command = 'IF ''?'' 
NOT IN(''master'', ''model'', ''msdb'',''SMArtXIdentityServer'',''rdsadmin'', ''tempdb'') 
BEGIN  USE ? EXEC (''
					GRANT SELECT,EXECUTE, ALTER, INSERT, UPDATE, DELETE, VIEW DEFINITION, REFERENCES 
                     ON SCHEMA :: [dbo]  TO [qa.developers.rw]
				   '') END' 
EXEC sp_MSforeachdb @command 
--##################################### create user ########################################
DECLARE @command VARCHAR(1000)
SELECT @command = 'IF ''?''
NOT IN(''master'', ''model'', ''msdb'',''SMArtXIdentityServer'',''rdsadmin'',''tempdb'') 
BEGIN  USE ? EXEC (''
create USER [JohnB_rw] FOR LOGIN [JohnB_rw];
'') END'
EXEC sp_MSforeachdb @command
--##################################### add user to role ########################################
DECLARE @command varchar(max) 
SELECT @command = 'IF ''?'' 
NOT IN(''master'', ''model'', ''msdb'',''SMArtXIdentityServer'',''rdsadmin'',''tempdb'') 
BEGIN  USE ? EXEC (''
ALTER ROLE [qa.developer.rw] ADD MEMBER [JohnB_rw];
'') END' 
EXEC sp_MSforeachdb @command 

--##########################   server rights to view server state ####################################
USE master;  
go
GRANT VIEW SERVER STATE TO [JohnB_rw]; 
GRANT ALTER TRACE TO [JohnB_rw];

--######################### db_ddladmin access (Data Definition Language) ####################################

DECLARE @command varchar(1000) 
SELECT @command = 'IF ''?'' 
NOT IN(''master'', ''model'', ''msdb'',''SMArtXIdentityServer'',''rdsadmin'',''tempdb'') 
BEGIN  USE ? EXEC (''
ALTER ROLE [db_ddladmin] ADD MEMBER [JohnB_rw]; 
'') END' 
EXEC sp_MSforeachdb @command 

-- ###### only allows a user/role to execute & view the execution plans of stored procedures & SQL statements ########

DECLARE @command varchar(1000) 
SELECT @command = 'IF ''?'' 
NOT IN(''master'', ''model'', ''msdb'',''SMArtXIdentityServer'',''rdsadmin'',''tempdb'') 
BEGIN  USE ? EXEC (''
GRANT EXECUTE, SHOWPLAN TO 	[JohnB_rw]; 
'') END' 
EXEC sp_MSforeachdb @command 

-- NOTE:  if a user or role requires more privileges beyond executing and viewing execution plans 
-- of stored procedures and SQL statements, the "db_ddladmin" role