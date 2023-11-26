USE TestingSpace

-- Choose a table and find Foreign Key relationships that it has with other tables ( include both upstream & downstream to see all relationships )

/* Parameters */
DECLARE @TableName varchar(100) = 'DiagramTable1'
DECLARE @IncludeUpstreamReferences bit = 1      -- 1 to include find Constraints where other tables refer to @TableName
DECLARE @IncludeDownstreamReferences bit = 1    -- 1 to include find referential Constraints that @TableName has on other tables

IF (@IncludeUpstreamReferences = 0 AND @IncludeDownstreamReferences = 0)
    BEGIN
        PRINT 'You choose to not include either Upstream or Downstream references. You should have at least one of those for this query to return anything.'
    END

IF ('' = ISNULL(@TableName, ''))
    BEGIN
        PRINT 'You failed to specify a Table Name, so this query will not return anything.'
    END


/* Logic */
SELECT
    ConstrainingTable   = ConstrainingTable.[TABLE_NAME],
	ForeignKeyColumn    = [KEY_COLUMN_USAGE].[COLUMN_NAME],
	ReferencedTable     = ReferencedTable.[TABLE_NAME],
	ReferencedColumn    = TableKeyUsage.[COLUMN_NAME],
	ConstraintName      = [REFERENTIAL_CONSTRAINTS].[CONSTRAINT_NAME]
FROM [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS] 
	JOIN [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] ConstrainingTable 
            ON ConstrainingTable.[CONSTRAINT_NAME] = [REFERENTIAL_CONSTRAINTS].[CONSTRAINT_NAME]
	JOIN [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] ReferencedTable 
            ON ReferencedTable.[CONSTRAINT_NAME] = [REFERENTIAL_CONSTRAINTS].[UNIQUE_CONSTRAINT_NAME]
	JOIN [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] 
            ON [KEY_COLUMN_USAGE].CONSTRAINT_NAME = [REFERENTIAL_CONSTRAINTS].[CONSTRAINT_NAME]
	JOIN ( SELECT [TABLE_CONSTRAINTS].[TABLE_NAME], [KEY_COLUMN_USAGE].COLUMN_NAME
				    FROM [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS]
					    JOIN [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE]
						    ON [TABLE_CONSTRAINTS].[CONSTRAINT_NAME] = [KEY_COLUMN_USAGE].[CONSTRAINT_NAME]
				    WHERE [TABLE_CONSTRAINTS].[CONSTRAINT_TYPE] = 'PRIMARY KEY'
                ) TableKeyUsage
		    ON TableKeyUsage.TABLE_NAME = ReferencedTable.[TABLE_NAME]

WHERE ( @IncludeUpstreamReferences = 1 AND @TableName = ReferencedTable.[TABLE_NAME] ) 
    OR ( @IncludeDownstreamReferences = 1 AND @TableName = ConstrainingTable.[TABLE_NAME])
