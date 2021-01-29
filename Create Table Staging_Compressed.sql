SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS [dbo].[Staging_Compressed]
GO

CREATE TABLE [dbo].[Staging_Compressed](
	[Id] [int] NOT NULL,
	[SourceFile] [nvarchar](50) NOT NULL,
    [CompressedMessage] VARBINARY(MAX) NOT NULL,
)
GO

ALTER TABLE [dbo].[Staging_Compressed] ADD PRIMARY KEY CLUSTERED 
(
	[Id],[SourceFile]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

