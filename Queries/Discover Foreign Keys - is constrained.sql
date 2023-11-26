USE TestingSpace

-- Find Foreign Key constraints that affect a table (and column)

/* Parameters */
DECLARE @ConstrainedTableName varchar(100) = 'DiagramTable1'        -- empty or NULL to select all tables that have constraints
DECLARE @ConstrainedColumnName varchar(100) = 'DiagramTable1_ID'    -- empty or NULL to select any columns in the table

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

WHERE ( '' = ISNULL(@ConstrainedTableName,'') OR @ConstrainedTableName = ReferencedTable.[TABLE_NAME]) 
	AND ( '' = ISNULL(@ConstrainedColumnName,'') OR @ConstrainedColumnName = TableKeyUsage.[COLUMN_NAME])
