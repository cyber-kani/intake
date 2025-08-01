-- Add reference_id column to IntakeForms table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('IntakeForms') AND name = 'reference_id')
BEGIN
    ALTER TABLE IntakeForms ADD reference_id VARCHAR(8);
END

-- Create index for faster lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reference_id' AND object_id = OBJECT_ID('IntakeForms'))
BEGIN
    CREATE INDEX idx_reference_id ON IntakeForms(reference_id);
END

-- Update existing records with reference IDs
UPDATE IntakeForms 
SET reference_id = LEFT(REPLACE(NEWID(), '-', ''), 8)
WHERE reference_id IS NULL;