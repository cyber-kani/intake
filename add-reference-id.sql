-- Add reference_id column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('IntakeForms') AND name = 'reference_id')
BEGIN
    ALTER TABLE IntakeForms ADD reference_id VARCHAR(8);
    PRINT 'Added reference_id column';
END
ELSE
BEGIN
    PRINT 'reference_id column already exists';
END

-- Create index if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reference_id' AND object_id = OBJECT_ID('IntakeForms'))
BEGIN
    CREATE INDEX idx_reference_id ON IntakeForms(reference_id);
    PRINT 'Created index on reference_id';
END
ELSE
BEGIN
    PRINT 'Index already exists';
END

-- Update existing records with reference IDs
UPDATE IntakeForms 
SET reference_id = LEFT(REPLACE(NEWID(), '-', ''), 8)
WHERE reference_id IS NULL;

PRINT 'Updated existing records with reference IDs';