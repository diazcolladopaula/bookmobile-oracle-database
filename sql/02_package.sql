-- Business logic for reservations, loans and returns.
--
-- Rules
--   * A user can hold at most max_open_items open loans and reservations.
--   * Banned users cannot borrow or reserve.
--   * Loans and reservations happen on a day the bookmobile visits the user's town.
--   * A copy that is damaged, deregistered, on loan or reserved is not available.
--   * Loans last loan_days days. Returning late bans the user for as many days as the delay.
--
-- The procedures never commit or roll back: the caller controls the transaction.
--
-- Error codes
--   -20001 user not found                -20007 ISBN not found
--   -20002 user is banned                -20008 no copy of the edition available
--   -20003 borrowing limit reached       -20009 invalid date for the operation
--   -20004 no service in the user's town -20010 no open loan for the copy
--   -20005 copy not found                -20011 return date not after the loan date
--   -20006 copy not available

CREATE OR REPLACE PACKAGE bookmobile_pkg AS

    max_open_items  CONSTANT PLS_INTEGER := 5;
    loan_days       CONSTANT PLS_INTEGER := 14;

    -- Reserves one specific copy for a future (or current) service day.
    PROCEDURE reserve_copy (
        p_signature  IN copies.signature%TYPE,
        p_user_id    IN users.user_id%TYPE,
        p_stop_date  IN DATE
    );

    -- Reserves the first available copy of an edition.
    PROCEDURE reserve_edition (
        p_isbn       IN editions.isbn%TYPE,
        p_user_id    IN users.user_id%TYPE,
        p_stop_date  IN DATE
    );

    -- Lends a copy at the stop of the user's town. If the user had reserved
    -- the copy for that day, the reservation becomes the loan.
    PROCEDURE loan_copy (
        p_signature  IN copies.signature%TYPE,
        p_user_id    IN users.user_id%TYPE,
        p_stop_date  IN DATE DEFAULT TRUNC(SYSDATE)
    );

    -- Registers the return of a copy that is currently on loan.
    PROCEDURE return_copy (
        p_signature    IN copies.signature%TYPE,
        p_return_date  IN DATE DEFAULT SYSDATE
    );

END bookmobile_pkg;
/

CREATE OR REPLACE PACKAGE BODY bookmobile_pkg AS

    -- Loads the user and rejects unknown or banned users.
    PROCEDURE get_active_user (
        p_user_id  IN  users.user_id%TYPE,
        p_user     OUT users%ROWTYPE
    ) IS
    BEGIN
        BEGIN
            SELECT * INTO p_user FROM users WHERE user_id = p_user_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001, 'User not found: ' || p_user_id);
        END;

        IF p_user.banned_until IS NOT NULL AND p_user.banned_until >= TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20002, 'User ' || p_user_id || ' is banned until '
                                            || TO_CHAR(p_user.banned_until, 'YYYY-MM-DD'));
        END IF;
    END get_active_user;

    PROCEDURE check_borrowing_limit (p_user_id IN users.user_id%TYPE) IS
        v_open PLS_INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_open
          FROM loans
         WHERE user_id = p_user_id AND return_date IS NULL;

        IF v_open >= max_open_items THEN
            RAISE_APPLICATION_ERROR(-20003, 'User ' || p_user_id || ' already has '
                                            || v_open || ' open loans or reservations');
        END IF;
    END check_borrowing_limit;

    -- Returns the stop time (minutes since midnight) if the bus visits the town that day.
    FUNCTION stop_time_for (
        p_town       IN stops.town%TYPE,
        p_province   IN stops.province%TYPE,
        p_stop_date  IN DATE
    ) RETURN stops.stop_time%TYPE IS
        v_stop_time stops.stop_time%TYPE;
    BEGIN
        SELECT st.stop_time INTO v_stop_time
          FROM services sv
          JOIN stops st ON st.town = sv.town AND st.province = sv.province
         WHERE sv.town = p_town
           AND sv.province = p_province
           AND sv.task_date = p_stop_date;
        RETURN v_stop_time;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'The bookmobile does not visit ' || p_town
                                            || ' on ' || TO_CHAR(p_stop_date, 'YYYY-MM-DD'));
    END stop_time_for;

    PROCEDURE check_copy_available (p_signature IN copies.signature%TYPE) IS
        v_condition     copies.condition%TYPE;
        v_deregistered  copies.deregistered%TYPE;
        v_open          PLS_INTEGER;
    BEGIN
        BEGIN
            SELECT condition, deregistered
              INTO v_condition, v_deregistered
              FROM copies
             WHERE signature = p_signature;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20005, 'Copy not found: ' || p_signature);
        END;

        IF v_condition = 'D' OR v_deregistered IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'Copy ' || p_signature || ' is damaged or deregistered');
        END IF;

        SELECT COUNT(*) INTO v_open
          FROM loans
         WHERE signature = p_signature AND return_date IS NULL;

        IF v_open > 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Copy ' || p_signature || ' is on loan or reserved');
        END IF;
    END check_copy_available;

    PROCEDURE reserve_copy (
        p_signature  IN copies.signature%TYPE,
        p_user_id    IN users.user_id%TYPE,
        p_stop_date  IN DATE
    ) IS
        v_user       users%ROWTYPE;
        v_stop_date  DATE := TRUNC(p_stop_date);
        v_stop_time  stops.stop_time%TYPE;
    BEGIN
        IF v_stop_date < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20009, 'A reservation must be for today or a later date');
        END IF;

        get_active_user(p_user_id, v_user);
        check_borrowing_limit(p_user_id);
        v_stop_time := stop_time_for(v_user.town, v_user.province, v_stop_date);
        check_copy_available(p_signature);

        INSERT INTO loans (signature, user_id, stop_date, town, province,
                           loan_type, time_of_day, return_date)
        VALUES (p_signature, p_user_id, v_stop_date, v_user.town, v_user.province,
                'R', v_stop_time, NULL);
    END reserve_copy;

    PROCEDURE reserve_edition (
        p_isbn       IN editions.isbn%TYPE,
        p_user_id    IN users.user_id%TYPE,
        p_stop_date  IN DATE
    ) IS
        v_exists     PLS_INTEGER;
        v_signature  copies.signature%TYPE;
    BEGIN
        SELECT COUNT(*) INTO v_exists FROM editions WHERE isbn = p_isbn;
        IF v_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'ISBN not found: ' || p_isbn);
        END IF;

        BEGIN
            SELECT signature INTO v_signature
              FROM (SELECT c.signature
                      FROM copies c
                     WHERE c.isbn = p_isbn
                       AND c.condition <> 'D'
                       AND c.deregistered IS NULL
                       AND NOT EXISTS (SELECT 1 FROM loans l
                                        WHERE l.signature = c.signature
                                          AND l.return_date IS NULL)
                     ORDER BY c.signature)
             WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20008, 'No copy of ISBN ' || p_isbn || ' is available');
        END;

        reserve_copy(v_signature, p_user_id, p_stop_date);
    END reserve_edition;

    PROCEDURE loan_copy (
        p_signature  IN copies.signature%TYPE,
        p_user_id    IN users.user_id%TYPE,
        p_stop_date  IN DATE DEFAULT TRUNC(SYSDATE)
    ) IS
        v_user       users%ROWTYPE;
        v_stop_date  DATE := TRUNC(p_stop_date);
        v_stop_time  stops.stop_time%TYPE;
    BEGIN
        IF v_stop_date > TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20009, 'A loan cannot be registered for a future date; make a reservation instead');
        END IF;

        get_active_user(p_user_id, v_user);
        v_stop_time := stop_time_for(v_user.town, v_user.province, v_stop_date);

        -- The user reserved this copy for this day: the reservation becomes the loan.
        UPDATE loans
           SET loan_type = 'L'
         WHERE signature = p_signature
           AND user_id = p_user_id
           AND stop_date = v_stop_date
           AND loan_type = 'R';

        IF SQL%ROWCOUNT = 1 THEN
            RETURN;
        END IF;

        check_borrowing_limit(p_user_id);
        check_copy_available(p_signature);

        INSERT INTO loans (signature, user_id, stop_date, town, province,
                           loan_type, time_of_day, return_date)
        VALUES (p_signature, p_user_id, v_stop_date, v_user.town, v_user.province,
                'L', v_stop_time, NULL);
    END loan_copy;

    PROCEDURE return_copy (
        p_signature    IN copies.signature%TYPE,
        p_return_date  IN DATE DEFAULT SYSDATE
    ) IS
        v_user_id    loans.user_id%TYPE;
        v_stop_date  loans.stop_date%TYPE;
        v_days_late  NUMBER;
        v_ban_until  DATE;
    BEGIN
        BEGIN
            SELECT user_id, stop_date INTO v_user_id, v_stop_date
              FROM loans
             WHERE signature = p_signature
               AND loan_type = 'L'
               AND return_date IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20010, 'There is no open loan for copy ' || p_signature);
        END;

        IF p_return_date <= v_stop_date THEN
            RAISE_APPLICATION_ERROR(-20011, 'The return date must be after the loan date');
        END IF;

        UPDATE loans
           SET return_date = p_return_date
         WHERE signature = p_signature
           AND user_id = v_user_id
           AND stop_date = v_stop_date;

        v_days_late := TRUNC(p_return_date) - (TRUNC(v_stop_date) + loan_days);
        IF v_days_late > 0 THEN
            v_ban_until := TRUNC(p_return_date) + v_days_late;
            UPDATE users
               SET banned_until = GREATEST(NVL(banned_until, v_ban_until), v_ban_until)
             WHERE user_id = v_user_id;
        END IF;
    END return_copy;

END bookmobile_pkg;
/
SHOW ERRORS
