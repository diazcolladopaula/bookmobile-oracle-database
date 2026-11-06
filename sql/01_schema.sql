-- Relational schema for the bookmobile (mobile library) database.
-- Target: Oracle Database 12c or later.

-- Catalogue ---------------------------------------------------------------

CREATE TABLE books (
    title        VARCHAR2(200) NOT NULL,
    author       VARCHAR2(100) NOT NULL,
    country      VARCHAR2(50),
    language     VARCHAR2(50),
    pub_year     NUMBER(4),
    alt_title    VARCHAR2(200),
    topic        VARCHAR2(200),
    content      VARCHAR2(2500),
    awards       VARCHAR2(200),
    reads_count  NUMBER(10) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_books PRIMARY KEY (title, author)
);

CREATE TABLE more_authors (
    title        VARCHAR2(200) NOT NULL,
    main_author  VARCHAR2(100) NOT NULL,
    alt_authors  VARCHAR2(200) NOT NULL,
    mentions     VARCHAR2(200),
    CONSTRAINT pk_more_authors PRIMARY KEY (title, main_author, alt_authors),
    CONSTRAINT fk_more_authors_books FOREIGN KEY (title, main_author)
        REFERENCES books (title, author)
);

CREATE TABLE editions (
    isbn               VARCHAR2(20),
    title              VARCHAR2(200) NOT NULL,
    author             VARCHAR2(100) NOT NULL,
    language           VARCHAR2(50) DEFAULT 'Spanish' NOT NULL,
    alt_languages      VARCHAR2(50),
    edition            VARCHAR2(50),
    publisher          VARCHAR2(100),
    extension          VARCHAR2(50),
    series             VARCHAR2(50),
    copyright          VARCHAR2(20),
    pub_place          VARCHAR2(50),
    dimensions         VARCHAR2(50),
    physical_features  VARCHAR2(200),
    materials          VARCHAR2(200),
    notes              VARCHAR2(500),
    national_lib_id    VARCHAR2(20) NOT NULL,
    url                VARCHAR2(200),
    CONSTRAINT pk_editions PRIMARY KEY (isbn),
    CONSTRAINT uk_editions_national_lib UNIQUE (national_lib_id),
    CONSTRAINT fk_editions_books FOREIGN KEY (title, author)
        REFERENCES books (title, author)
);

CREATE TABLE copies (
    signature     VARCHAR2(5),
    isbn          VARCHAR2(20) NOT NULL,
    condition     VARCHAR2(1) DEFAULT 'G' NOT NULL,
    comments      VARCHAR2(200),
    deregistered  DATE,
    CONSTRAINT pk_copies PRIMARY KEY (signature),
    CONSTRAINT fk_copies_editions FOREIGN KEY (isbn) REFERENCES editions (isbn),
    CONSTRAINT ck_copies_condition CHECK (condition IN ('N', 'G', 'W', 'D'))
);

-- Fleet, routes and staff -------------------------------------------------

CREATE TABLE municipalities (
    town        VARCHAR2(50),
    province    VARCHAR2(22),
    population  NUMBER(5) NOT NULL,
    CONSTRAINT pk_municipalities PRIMARY KEY (town, province),
    CONSTRAINT ck_municipalities_population CHECK (population >= 0)
);

CREATE TABLE routes (
    route_id  VARCHAR2(5),
    CONSTRAINT pk_routes PRIMARY KEY (route_id)
);

CREATE TABLE drivers (
    passport        VARCHAR2(17),
    email           VARCHAR2(100) NOT NULL,
    fullname        VARCHAR2(80) NOT NULL,
    birthdate       DATE NOT NULL,
    phone           NUMBER(9) NOT NULL,
    address         VARCHAR2(100) NOT NULL,
    contract_start  DATE NOT NULL,
    contract_end    DATE,
    CONSTRAINT pk_drivers PRIMARY KEY (passport),
    CONSTRAINT ck_drivers_phone CHECK (phone BETWEEN 100000000 AND 999999999),
    CONSTRAINT ck_drivers_contract CHECK (contract_end IS NULL OR contract_start < contract_end)
);

CREATE TABLE bibuses (
    plate     VARCHAR2(8),
    last_itv  DATE NOT NULL,
    next_itv  DATE NOT NULL,
    CONSTRAINT pk_bibuses PRIMARY KEY (plate),
    CONSTRAINT ck_bibuses_itv CHECK (last_itv < next_itv)
);

-- One driver and one bus are assigned to a route on a given day.

CREATE TABLE assign_drv (
    passport   VARCHAR2(17),
    task_date  DATE,
    route_id   VARCHAR2(5) NOT NULL,
    CONSTRAINT pk_assign_drv PRIMARY KEY (passport, task_date),
    CONSTRAINT fk_assign_drv_drivers FOREIGN KEY (passport)
        REFERENCES drivers (passport) ON DELETE CASCADE,
    CONSTRAINT fk_assign_drv_routes FOREIGN KEY (route_id)
        REFERENCES routes (route_id) ON DELETE CASCADE
);

CREATE TABLE assign_bus (
    plate      VARCHAR2(8),
    task_date  DATE,
    route_id   VARCHAR2(5) NOT NULL,
    CONSTRAINT pk_assign_bus PRIMARY KEY (plate, task_date),
    CONSTRAINT uk_assign_bus_route_day UNIQUE (task_date, route_id),
    CONSTRAINT fk_assign_bus_bibuses FOREIGN KEY (plate)
        REFERENCES bibuses (plate) ON DELETE CASCADE,
    CONSTRAINT fk_assign_bus_routes FOREIGN KEY (route_id)
        REFERENCES routes (route_id) ON DELETE CASCADE
);

-- Every municipality has at most one stop; stop_time is minutes since midnight.

CREATE TABLE stops (
    town       VARCHAR2(50),
    province   VARCHAR2(22),
    address    VARCHAR2(100) NOT NULL,
    route_id   VARCHAR2(5) NOT NULL,
    stop_time  NUMBER(4) NOT NULL,
    CONSTRAINT pk_stops PRIMARY KEY (town, province),
    CONSTRAINT fk_stops_municipalities FOREIGN KEY (town, province)
        REFERENCES municipalities (town, province) ON DELETE CASCADE,
    CONSTRAINT fk_stops_routes FOREIGN KEY (route_id) REFERENCES routes (route_id),
    CONSTRAINT ck_stops_time CHECK (stop_time BETWEEN 0 AND 1439)
);

-- A service is one visit of a bus (and its driver) to a stop on a given day.

CREATE TABLE services (
    town       VARCHAR2(50),
    province   VARCHAR2(22),
    bus        VARCHAR2(8) NOT NULL,
    task_date  DATE,
    passport   VARCHAR2(17) NOT NULL,
    CONSTRAINT pk_services PRIMARY KEY (town, province, task_date),
    CONSTRAINT fk_services_stops FOREIGN KEY (town, province)
        REFERENCES stops (town, province) ON DELETE CASCADE,
    CONSTRAINT fk_services_assign_bus FOREIGN KEY (bus, task_date)
        REFERENCES assign_bus (plate, task_date),
    CONSTRAINT fk_services_assign_drv FOREIGN KEY (passport, task_date)
        REFERENCES assign_drv (passport, task_date)
);

-- Users and activity ------------------------------------------------------

CREATE TABLE users (
    user_id       VARCHAR2(10),
    id_card       VARCHAR2(17) NOT NULL,
    name          VARCHAR2(80) NOT NULL,
    surname1      VARCHAR2(80) NOT NULL,
    surname2      VARCHAR2(80),
    birthdate     DATE NOT NULL,
    town          VARCHAR2(50) NOT NULL,
    province      VARCHAR2(22) NOT NULL,
    address       VARCHAR2(150) NOT NULL,
    email         VARCHAR2(100),
    phone         NUMBER(9) NOT NULL,
    user_type     VARCHAR2(1) NOT NULL,
    banned_until  DATE,
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uk_users_id_card UNIQUE (id_card),
    CONSTRAINT fk_users_municipalities FOREIGN KEY (town, province)
        REFERENCES municipalities (town, province),
    CONSTRAINT ck_users_phone CHECK (phone BETWEEN 100000000 AND 999999999),
    CONSTRAINT ck_users_type CHECK (user_type IN ('L', 'P'))
);

-- A loan row is a loan ('L') or a reservation ('R') made for a service day.
-- time_of_day is minutes since midnight. A row with no return_date is still open.

CREATE TABLE loans (
    signature    VARCHAR2(5),
    user_id      VARCHAR2(10),
    stop_date    DATE,
    town         VARCHAR2(50) NOT NULL,
    province     VARCHAR2(22) NOT NULL,
    loan_type    VARCHAR2(1) NOT NULL,
    time_of_day  NUMBER(4) DEFAULT 0 NOT NULL,
    return_date  DATE,
    CONSTRAINT pk_loans PRIMARY KEY (signature, user_id, stop_date),
    CONSTRAINT fk_loans_users FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT fk_loans_copies FOREIGN KEY (signature) REFERENCES copies (signature),
    CONSTRAINT fk_loans_services FOREIGN KEY (town, province, stop_date)
        REFERENCES services (town, province, task_date),
    CONSTRAINT ck_loans_type CHECK (loan_type IN ('L', 'R')),
    CONSTRAINT ck_loans_time CHECK (time_of_day BETWEEN 0 AND 1439),
    CONSTRAINT ck_loans_dates CHECK (return_date IS NULL OR return_date > stop_date)
);

CREATE TABLE posts (
    signature  VARCHAR2(5),
    user_id    VARCHAR2(10),
    stop_date  DATE,
    post_date  DATE NOT NULL,
    text       VARCHAR2(2000) NOT NULL,
    likes      NUMBER(7) DEFAULT 0 NOT NULL,
    dislikes   NUMBER(7) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_posts PRIMARY KEY (signature, user_id, stop_date),
    CONSTRAINT fk_posts_loans FOREIGN KEY (signature, user_id, stop_date)
        REFERENCES loans (signature, user_id, stop_date) ON DELETE CASCADE,
    CONSTRAINT ck_posts_dates CHECK (stop_date < post_date)
);

-- Indexes on foreign keys that are not covered by a primary key ------------

CREATE INDEX idx_editions_book   ON editions (title, author);
CREATE INDEX idx_copies_isbn     ON copies (isbn);
CREATE INDEX idx_loans_user      ON loans (user_id);
CREATE INDEX idx_loans_service   ON loans (town, province, stop_date);
CREATE INDEX idx_users_town      ON users (town, province);
CREATE INDEX idx_stops_route     ON stops (route_id);
CREATE INDEX idx_services_bus    ON services (bus, task_date);
CREATE INDEX idx_services_driver ON services (passport, task_date);

-- Column documentation ----------------------------------------------------

COMMENT ON COLUMN copies.condition IS 'N new, G good, W worn, D damaged';
COMMENT ON COLUMN users.user_type IS 'L institutional (library or association), P private person';
COMMENT ON COLUMN users.banned_until IS 'Last day of the borrowing ban, NULL if the user is not banned';
COMMENT ON COLUMN loans.loan_type IS 'L loan, R reservation';
COMMENT ON COLUMN loans.time_of_day IS 'Minutes since midnight';
COMMENT ON COLUMN loans.return_date IS 'NULL while the loan or reservation is still open';
COMMENT ON COLUMN stops.stop_time IS 'Minutes since midnight';
COMMENT ON COLUMN books.reads_count IS 'Number of loans of any edition, maintained by trg_loans_count_reads';
