USE [LabLog]
GO

ALTER TABLE [dbo].[Staging] REBUILD PARTITION = ALL
WITH 
(
	DATA_COMPRESSION = PAGE
)
GO

