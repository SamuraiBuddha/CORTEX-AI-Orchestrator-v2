-- Create databases for CORTEX services
CREATE DATABASE cortex_db;
CREATE DATABASE n8n;
CREATE DATABASE flowise;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE cortex_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE n8n TO postgres;
GRANT ALL PRIVILEGES ON DATABASE flowise TO postgres;
