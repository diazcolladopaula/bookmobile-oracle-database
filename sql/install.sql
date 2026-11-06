-- Installs the whole project in dependency order.
-- Run it from the sql/ directory:
--   sqlplus <user>/<password>@<service> @install.sql

SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

@@00_reset.sql
@@01_schema.sql
@@02_package.sql
@@03_triggers.sql
@@04_views.sql
@@05_sample_data.sql

PROMPT
PROMPT Installation finished. Run the queries in 06_queries.sql or the scripts in ../tests.
