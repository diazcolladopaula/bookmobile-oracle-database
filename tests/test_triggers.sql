-- Tests for the table triggers. Requires the project to be installed.
-- Everything is rolled back at the end.
--   sqlplus <user>/<password>@<service> @test_triggers.sql

SET SERVEROUTPUT ON
SET SQLBLANKLINES ON

DECLARE
    v_failures      PLS_INTEGER := 0;
    v_count         PLS_INTEGER;
    v_reads         NUMBER;
    v_deregistered  DATE;

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

    FUNCTION reads_of_quixote RETURN NUMBER IS
        v_value NUMBER;
    BEGIN
        SELECT reads_count INTO v_value FROM books
         WHERE title = 'Don Quijote de la Mancha';
        RETURN v_value;
    END reads_of_quixote;
BEGIN
    -- trg_posts_no_institutions
    expect_error('post by an institutional user is rejected', -20101,
        q'[INSERT INTO posts (signature, user_id, stop_date, post_date, text)
           VALUES ('CP010', 'U000000010', DATE '2026-09-23', SYSDATE, 'test')]');

    INSERT INTO posts (signature, user_id, stop_date, post_date, text)
    VALUES ('CP016', 'U000000009', DATE '2026-09-16', SYSDATE, 'test');
    SELECT COUNT(*) INTO v_count FROM posts
     WHERE signature = 'CP016' AND user_id = 'U000000009';
    report('post by a private user is accepted', v_count = 1);

    -- trg_copies_deregister
    UPDATE copies SET condition = 'D' WHERE signature = 'CP002';
    SELECT deregistered INTO v_deregistered FROM copies WHERE signature = 'CP002';
    report('marking a copy as damaged sets the deregistration date', v_deregistered IS NOT NULL);

    UPDATE copies SET condition = 'W' WHERE signature = 'CP001';
    SELECT deregistered INTO v_deregistered FROM copies WHERE signature = 'CP001';
    report('other condition changes leave the date empty', v_deregistered IS NULL);

    -- trg_loans_count_reads
    v_reads := reads_of_quixote;
    INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day)
    VALUES ('CP001', 'U000000002', DATE '2026-09-14', 'Villaverdana', 'Madrid', 'L', 610);
    report('a new loan increases reads_count', reads_of_quixote = v_reads + 1);

    v_reads := reads_of_quixote;
    INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day)
    VALUES ('CP003', 'U000000002', DATE '2026-09-21', 'Villaverdana', 'Madrid', 'R', 610);
    report('a new reservation does not change reads_count', reads_of_quixote = v_reads);

    UPDATE loans SET loan_type = 'L'
     WHERE signature = 'CP003' AND user_id = 'U000000002' AND stop_date = DATE '2026-09-21';
    report('a reservation turned into a loan increases reads_count', reads_of_quixote = v_reads + 1);

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_failures = 0 THEN 'All trigger tests passed.'
                              ELSE v_failures || ' trigger test(s) failed.' END);
END;
/
