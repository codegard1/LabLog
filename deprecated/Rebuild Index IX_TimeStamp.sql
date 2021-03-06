USE [LabLog]
GO
ALTER INDEX [IX_TimeStamp] 
ON [dbo].[Logs1] 
REBUILD PARTITION = ALL 
WITH (
    PAD_INDEX = OFF, 
    STATISTICS_NORECOMPUTE = OFF, 
    SORT_IN_TEMPDB = OFF, 
    ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, 
    ALLOW_PAGE_LOCKS = ON
    )
GO
