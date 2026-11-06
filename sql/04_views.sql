-- Per-user views. They show only the rows of the user whose id is stored in the
-- session client identifier, which an application sets after authenticating:
--
--   EXEC DBMS_SESSION.SET_IDENTIFIER('U000000001');
--
-- With no identifier set, the views are empty.

CREATE OR REPLACE VIEW my_data AS
SELECT user_id, id_card, name, surname1, surname2, birthdate, town, province,
       address, email, phone, user_type, banned_until
  FROM users
 WHERE user_id = SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
WITH READ ONLY;

-- Loans of the user with the post written about each one (if any).
-- Updating post_text creates the post or edits the existing one; other columns are read-only.
CREATE OR REPLACE VIEW my_loans AS
SELECT l.signature, l.user_id, l.stop_date, l.town, l.province, l.return_date,
       p.text AS post_text, p.post_date, p.likes, p.dislikes
  FROM loans l
  LEFT JOIN posts p
    ON p.signature = l.signature
   AND p.user_id = l.user_id
   AND p.stop_date = l.stop_date
 WHERE l.user_id = SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
   AND l.loan_type = 'L';

CREATE OR REPLACE TRIGGER trg_my_loans_post
INSTEAD OF UPDATE ON my_loans
FOR EACH ROW
BEGIN
    IF :NEW.signature <> :OLD.signature
       OR :NEW.user_id <> :OLD.user_id
       OR :NEW.stop_date <> :OLD.stop_date THEN
        RAISE_APPLICATION_ERROR(-20202, 'Only post_text can be updated');
    END IF;

    IF :NEW.post_text IS NULL THEN
        RAISE_APPLICATION_ERROR(-20201, 'The post text cannot be empty');
    END IF;

    IF :OLD.post_text IS NULL THEN
        INSERT INTO posts (signature, user_id, stop_date, post_date, text, likes, dislikes)
        VALUES (:OLD.signature, :OLD.user_id, :OLD.stop_date, SYSDATE, :NEW.post_text, 0, 0);
    ELSE
        UPDATE posts
           SET text = :NEW.post_text,
               post_date = SYSDATE
         WHERE signature = :OLD.signature
           AND user_id = :OLD.user_id
           AND stop_date = :OLD.stop_date;
    END IF;
END;
/

-- Reservations of the user. Insert to reserve a copy, update stop_date to move
-- the reservation to another service day, delete to cancel it.
CREATE OR REPLACE VIEW my_reservations AS
SELECT signature, user_id, stop_date, town, province
  FROM loans
 WHERE user_id = SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
   AND loan_type = 'R';

CREATE OR REPLACE TRIGGER trg_my_reservations_insert
INSTEAD OF INSERT ON my_reservations
FOR EACH ROW
BEGIN
    bookmobile_pkg.reserve_copy(:NEW.signature,
                                SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),
                                :NEW.stop_date);
END;
/

CREATE OR REPLACE TRIGGER trg_my_reservations_delete
INSTEAD OF DELETE ON my_reservations
FOR EACH ROW
BEGIN
    DELETE FROM loans
     WHERE signature = :OLD.signature
       AND user_id = :OLD.user_id
       AND stop_date = :OLD.stop_date
       AND loan_type = 'R';
END;
/

CREATE OR REPLACE TRIGGER trg_my_reservations_move
INSTEAD OF UPDATE ON my_reservations
FOR EACH ROW
BEGIN
    IF :NEW.signature <> :OLD.signature OR :NEW.user_id <> :OLD.user_id THEN
        RAISE_APPLICATION_ERROR(-20202, 'Only stop_date can be updated');
    END IF;

    IF :NEW.stop_date = :OLD.stop_date THEN
        RETURN;
    END IF;

    DELETE FROM loans
     WHERE signature = :OLD.signature
       AND user_id = :OLD.user_id
       AND stop_date = :OLD.stop_date
       AND loan_type = 'R';

    bookmobile_pkg.reserve_copy(:OLD.signature, :OLD.user_id, :NEW.stop_date);
END;
/
SHOW ERRORS
