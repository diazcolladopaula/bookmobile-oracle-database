-- Drops every object created by this project so the install can be repeated.
-- Safe to run on an empty schema.

BEGIN
    FOR v IN (SELECT view_name FROM user_views
               WHERE view_name IN ('MY_DATA', 'MY_LOANS', 'MY_RESERVATIONS')) LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;

    FOR p IN (SELECT object_name FROM user_objects
               WHERE object_type = 'PACKAGE' AND object_name = 'BOOKMOBILE_PKG') LOOP
        EXECUTE IMMEDIATE 'DROP PACKAGE ' || p.object_name;
    END LOOP;

    FOR t IN (SELECT table_name FROM user_tables
               WHERE table_name IN ('POSTS', 'LOANS', 'USERS', 'SERVICES', 'STOPS',
                                    'ASSIGN_BUS', 'ASSIGN_DRV', 'BIBUSES', 'DRIVERS',
                                    'ROUTES', 'MUNICIPALITIES', 'COPIES', 'EDITIONS',
                                    'MORE_AUTHORS', 'BOOKS')) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/
