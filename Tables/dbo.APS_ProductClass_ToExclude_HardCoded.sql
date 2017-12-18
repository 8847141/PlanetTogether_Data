CREATE TABLE [dbo].[APS_ProductClass_ToExclude_HardCoded]
(
[ExcludedProductClass] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_ProductClass_ToExclude_HardCoded] ADD CONSTRAINT [PK_APS_ProductClass_ToExclude_HardCoded] PRIMARY KEY CLUSTERED  ([ExcludedProductClass]) ON [PRIMARY]
GO
