USE semothon;

ALTER TABLE files
ADD COLUMN object_key VARCHAR(500) NOT NULL AFTER stored_name;