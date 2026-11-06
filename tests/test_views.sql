-- Tests for the per-user views. Requires the project to be installed.
-- Everything is rolled back at the end.
--   sqlplus <user>/<password>@<service> @test_views.sql

SET SERVEROUTPUT ON
SET SQLBLANKLINES ON

DECLARE
    v_failures  PLS_INTEGER := 0;
    v_count     PLS_INTEGER;
    v_text      VARCHAR2(2000);
    v_date      DATE;

    PROCEDURE report (p_name IN VARCHAR2, p_ok IN BOOLEAN) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CASE WHEN p_ok THEN '[PASS] ' ELSE '[FAIL] ' END || p_name);
        IF NOT p_ok THEN
            v_failures := v_failures + 1;
        END IF;
    END report;

    PROCEDURE expect_error (p_name IN VARCHAR2, p_code IN PLS_INTEGER, p_sql IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_sql;
        report(p_name || ' (no error raised)', FALSE);
    EXCEPTION
        WHEN OTHERS THEN
            report(p_name || ' (expected ' || p_code || ', got ' || SQLCODE || ')', SQLCODE = p_code);
    END expect_error;

    PROCEDURE add_service_day (p_day IN DATE) IS
    BEGIN
        INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('1234-BCD', p_day, 'RT001');
        INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000001', p_day, 'RT001');
        INSERT INTO services (town, province, bus, task_date, passport)
        SELECT town, province, '1234-BCD', p_day, 'DRV-0000001' FROM stops WHERE route_id = 'RT001';
    END add_service_day;
BEGIN
    add_service_day(TRUNC(SYSDATE));
    add_service_day(TRUNC(SYSDATE) + 7);

    -- my_data
    DBMS_SESSION.SET_IDENTIFIER('U000000001');
    SELECT COUNT(*) INTO v_count FROM my_data;
    report('my_data shows only the current user', v_count = 1);

    DBMS_SESSION.CLEAR_IDENTIFIER;
    SELECT COUNT(*) INTO v_count FROM my_data;
    report('my_data is empty without a client identifier', v_count = 0);

    -- my_loans
    DBMS_SESSION.SET_IDENTIFIER('U000000001');
    SELECT COUNT(*) INTO v_count FROM my_loans;
    report('my_loans lists the loans of the current user', v_count = 2);

    UPDATE my_loans SET post_text = 'Updated review' WHERE signature = 'CP005';
    SELECT post_text INTO v_text FROM my_loans WHERE signature = 'CP005';
    report('my_loans: an existing post is edited', v_text = 'Updated review');

    UPDATE my_loans SET post_text = 'First review' WHERE signature = 'CP013';
    SELECT COUNT(*) INTO v_count FROM posts
     WHERE signature = 'CP013' AND user_id = 'U000000001';
    report('my_loans: a new post is created', v_count = 1);

    DBMS_SESSION.SET_IDENTIFIER('U000000010');
    expect_error('my_loans: institutional user cannot post', -20101,
        q'[UPDATE my_loans SET post_text = 'test' WHERE signature = 'CP010']');

    -- my_reservations
    DBMS_SESSION.SET_IDENTIFIER('U000000003');
    INSERT INTO my_reservations (signature, stop_date) VALUES ('CP002', TRUNC(SYSDATE) + 7);
    SELECT COUNT(*) INTO v_count FROM my_reservations;
    report('my_reservations: insert creates a reservation', v_count = 1);

    DBMS_SESSION.SET_IDENTIFIER('U000000004');
    SELECT COUNT(*) INTO v_count FROM my_reservations;
    report('my_reservations: other users cannot see it', v_count = 0);

    DBMS_SESSION.SET_IDENTIFIER('U000000003');
    UPDATE my_reservations SET stop_date = TRUNC(SYSDATE) WHERE signature = 'CP002';
    SELECT stop_date INTO v_date FROM my_reservations WHERE signature = 'CP002';
    report('my_reservations: update moves the reservation', v_date = TRUNC(SYSDATE));

    DELETE FROM my_reservations WHERE signature = 'CP002';
    SELECT COUNT(*) INTO v_count FROM my_reservations;
    report('my_reservations: delete cancels the reservation', v_count = 0);

    DBMS_SESSION.CLEAR_IDENTIFIER;
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_failures = 0 THEN 'All view tests passed.'
                              ELSE v_failures || ' view test(s) failed.' END);
END;
/
