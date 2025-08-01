-- Add reference_id column to IntakeForms table
ALTER TABLE IntakeForms ADD reference_id VARCHAR(8);

-- Create index for faster lookups
CREATE INDEX idx_reference_id ON IntakeForms(reference_id);

-- Generate reference IDs for existing records
UPDATE IntakeForms 
SET reference_id = LEFT(REPLACE(NEWID(), '-', ''), 8)
WHERE reference_id IS NULL;