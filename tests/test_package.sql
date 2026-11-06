-- Tests for bookmobile_pkg. Requires the project to be installed (sql/install.sql).
-- Everything is rolled back at the end, so the sample data is left untouched.
--   sqlplus <user>/<password>@<service> @test_package.sql

SET SERVEROUTPUT ON
SET SQLBLANKLINES ON

DECLARE
    v_failures  PLS_INTEGER := 0;
    v_count     PLS_INTEGER;
    v_before    NUMBER;
    v_after     NUMBER;
    v_ban       DATE;

    PROCEDURE report (p_name IN VARCHAR2, p_ok IN BOOLEAN) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CASE WHEN p_ok THEN '[PASS] ' ELSE '[FAIL] ' END || p_name);
        IF NOT p_ok THEN
            v_failures := v_failures + 1;
        END IF;
    END report;

    -- Runs a statement and checks that it fails with the given error code.
    PROCEDURE expect_error (p_name IN VARCHAR2, p_code IN PLS_INTEGER, p_sql IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_sql;
        report(p_name || ' (no error raised)', FALSE);
    EXCEPTION
        WHEN OTHERS THEN
            report(p_name || ' (expected ' || p_code || ', got ' || SQLCODE || ')', SQLCODE = p_code);
    END expect_error;

    -- The bookmobile visits the stops of route RT001 on the given day.
    PROCEDURE add_service_day (p_day IN DATE) IS
    BEGIN
        INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('1234-BCD', p_day, 'RT001');
        INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000001', p_day, 'RT001');
        INSERT INTO services (town, province, bus, task_date, passport)
        SELECT town, province, '1234-BCD', p_day, 'DRV-0000001' FROM stops WHERE route_id = 'RT001';
    END add_service_day;

    FUNCTION reads_of_quixote RETURN NUMBER IS
        v_reads NUMBER;
    BEGIN
        SELECT reads_count INTO v_reads FROM books
         WHERE title = 'Don Quijote de la Mancha';
        RETURN v_reads;
    END reads_of_quixote;
BEGIN
    add_service_day(TRUNC(SYSDATE));
    add_service_day(TRUNC(SYSDATE) + 7);

    -- Reservations ---------------------------------------------------------
    expect_error('reserve: unknown user', -20001,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP001', 'U999999999', TRUNC(SYSDATE) + 7); END;]');

    UPDATE users SET banned_until = TRUNC(SYSDATE) + 5 WHERE user_id = 'U000000002';
    expect_error('reserve: banned user', -20002,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP001', 'U000000002', TRUNC(SYSDATE) + 7); END;]');
    UPDATE users SET banned_until = NULL WHERE user_id = 'U000000002';

    expect_error('reserve: date in the past', -20009,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP001', 'U000000001', TRUNC(SYSDATE) - 1); END;]');
    expect_error('reserve: no service in the user''s town that day', -20004,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP001', 'U000000006', TRUNC(SYSDATE) + 7); END;]');
    expect_error('reserve: unknown copy', -20005,
        q'[BEGIN bookmobile_pkg.reserve_copy('ZZZZZ', 'U000000001', TRUNC(SYSDATE) + 7); END;]');
    expect_error('reserve: damaged copy', -20006,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP015', 'U000000001', TRUNC(SYSDATE) + 7); END;]');

    bookmobile_pkg.reserve_copy('CP002', 'U000000003', TRUNC(SYSDATE) + 7);
    SELECT COUNT(*) INTO v_count FROM loans
     WHERE signature = 'CP002' AND user_id = 'U000000003' AND loan_type = 'R';
    report('reserve: copy reserved', v_count = 1);

    expect_error('reserve: copy already reserved by someone else', -20006,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP002', 'U000000004', TRUNC(SYSDATE) + 7); END;]');

    bookmobile_pkg.reserve_edition('9780000000011', 'U000000002', TRUNC(SYSDATE) + 7);
    SELECT COUNT(*) INTO v_count FROM loans
     WHERE signature = 'CP001' AND user_id = 'U000000002' AND loan_type = 'R';
    report('reserve edition: first free copy is picked', v_count = 1);

    expect_error('reserve edition: all copies taken', -20008,
        q'[BEGIN bookmobile_pkg.reserve_edition('9780000000011', 'U000000001', TRUNC(SYSDATE) + 7); END;]');
    expect_error('reserve edition: unknown ISBN', -20007,
        q'[BEGIN bookmobile_pkg.reserve_edition('0000000000000', 'U000000001', TRUNC(SYSDATE) + 7); END;]');

    -- Loans ----------------------------------------------------------------
    expect_error('loan: damaged copy', -20006,
        q'[BEGIN bookmobile_pkg.loan_copy('CP015', 'U000000004'); END;]');
    expect_error('loan: future date', -20009,
        q'[BEGIN bookmobile_pkg.loan_copy('CP003', 'U000000004', TRUNC(SYSDATE) + 7); END;]');

    v_before := reads_of_quixote;
    bookmobile_pkg.loan_copy('CP003', 'U000000004');
    SELECT COUNT(*) INTO v_count FROM loans
     WHERE signature = 'CP003' AND user_id = 'U000000004'
       AND loan_type = 'L' AND return_date IS NULL;
    report('loan: copy lent', v_count = 1);
    report('loan: reads_count increased', reads_of_quixote = v_before + 1);

    expect_error('loan: copy already on loan', -20006,
        q'[BEGIN bookmobile_pkg.loan_copy('CP003', 'U000000003'); END;]');

    v_before := reads_of_quixote;
    bookmobile_pkg.reserve_copy('CP004', 'U000000004', TRUNC(SYSDATE));
    bookmobile_pkg.loan_copy('CP004', 'U000000004');
    SELECT COUNT(*) INTO v_count FROM loans
     WHERE signature = 'CP004' AND user_id = 'U000000004' AND loan_type = 'L';
    report('loan: reservation converted into a loan', v_count = 1);
    report('loan: converted reservation counts as a read', reads_of_quixote = v_before + 1);

    -- Borrowing limit: five open reservations, then one more attempt.
    INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day)
    SELECT signature, 'U000000001', TRUNC(SYSDATE) + 7, 'Villaverdana', 'Madrid', 'R', 600
      FROM copies
     WHERE signature IN ('CP009', 'CP011', 'CP012', 'CP013', 'CP014');
    expect_error('reserve: borrowing limit reached', -20003,
        q'[BEGIN bookmobile_pkg.reserve_copy('CP007', 'U000000001', TRUNC(SYSDATE) + 7); END;]');
    DELETE FROM loans WHERE user_id = 'U000000001' AND loan_type = 'R';

    -- Returns --------------------------------------------------------------
    bookmobile_pkg.return_copy('CP003');
    SELECT COUNT(*) INTO v_count FROM loans
     WHERE signature = 'CP003' AND return_date IS NOT NULL;
    report('return: return date recorded', v_count = 1);

    expect_error('return: no open loan', -20010,
        q'[BEGIN bookmobile_pkg.return_copy('CP003'); END;]');
    expect_error('return: date not after the loan date', -20011,
        q'[BEGIN bookmobile_pkg.return_copy('CP016', DATE '2026-09-16'); END;]');

    -- Loan CP006 / U000000008 started on 2026-09-09, so it was due on 2026-09-23.
    bookmobile_pkg.return_copy('CP006', TRUNC(SYSDATE));
    SELECT banned_until INTO v_ban FROM users WHERE user_id = 'U000000008';
    report('return: late return bans the user for as many days as the delay',
           v_ban = TRUNC(SYSDATE) + (TRUNC(SYSDATE) - DATE '2026-09-23'));

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_failures = 0 THEN 'All package tests passed.'
                              ELSE v_failures || ' package test(s) failed.' END);
END;
/
