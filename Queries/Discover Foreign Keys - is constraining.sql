/*   Discover Foreign Keys 
      "Is constraining?" - Choose a table (and column) to see if it is constraining other tables
  	https://github.com/afun-entp/Shared_References
*/


/* Parameters */
DECLARE @ConstrainingTableName varchar(100) = 'DiagramTable3'		-- used in a LIKE clause. Empty or NULL to select all tables that make referential constraints
DECLARE @ConstrainingColumnName varchar(100) = 'DiagramTable1_ID'	-- used in a LIKE clause. Empty or NULL to select any columns in the table
	
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

WHERE ( '' = ISNULL(@ConstrainingTableName,'') OR ConstrainingTable.[TABLE_NAME] LIKE @ConstrainingTableName)
	AND ( '' = ISNULL(@ConstrainingColumnName,'') OR TableKeyUsage.[COLUMN_NAME] LIKE @ConstrainingColumnName)
