-- Crear base de datos y usuario para Metabase
CREATE DATABASE metabase;
CREATE USER metabase_user WITH ENCRYPTED PASSWORD 'met_pass';
GRANT ALL PRIVILEGES ON DATABASE metabase TO metabase_user;

-- Crear base de datos y usuario para MyData
CREATE DATABASE MyData;
CREATE USER mydata_user WITH ENCRYPTED PASSWORD 'mydata_pass';
GRANT ALL PRIVILEGES ON DATABASE MyData TO mydata_user;
