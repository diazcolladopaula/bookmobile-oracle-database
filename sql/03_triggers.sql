-- Business-rule triggers.

-- Institutional users (type 'L') are not allowed to publish posts.
CREATE OR REPLACE TRIGGER trg_posts_no_institutions
BEFORE INSERT ON posts
FOR EACH ROW
DECLARE
    v_user_type users.user_type%TYPE;
BEGIN
    SELECT user_type INTO v_user_type
      FROM users
     WHERE user_id = :NEW.user_id;

    IF v_user_type = 'L' THEN
        RAISE_APPLICATION_ERROR(-20101, 'Institutional users cannot create posts');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;  -- unknown user: the foreign key reports it
END;
/

-- When a copy is marked as damaged, record the deregistration date.
CREATE OR REPLACE TRIGGER trg_copies_deregister
BEFORE UPDATE OF condition ON copies
FOR EACH ROW
WHEN (NEW.condition = 'D' AND OLD.condition <> 'D')
BEGIN
    :NEW.deregistered := NVL(:NEW.deregistered, SYSDATE);
END;
/

-- Count a read each time a loan is created, or a reservation becomes a loan.
CREATE OR REPLACE TRIGGER trg_loans_count_reads
AFTER INSERT OR UPDATE OF loan_type ON loans
FOR EACH ROW
WHEN (NEW.loan_type = 'L' AND (OLD.loan_type IS NULL OR OLD.loan_type = 'R'))
BEGIN
    UPDATE books
       SET reads_count = reads_count + 1
     WHERE (title, author) IN (SELECT e.title, e.author
                                 FROM copies c
                                 JOIN editions e ON e.isbn = c.isbn
                                WHERE c.signature = :NEW.signature);
END;
/
SHOW ERRORS
