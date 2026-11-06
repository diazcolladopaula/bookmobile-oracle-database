-- Fictional sample data. Towns, people, e-mail addresses and phone numbers are invented.
-- Triggers are already installed, so books.reads_count is filled in by the loan inserts.

-- Catalogue ---------------------------------------------------------------

INSERT INTO books (title, author, country, language, pub_year, alt_title, topic, content, awards) VALUES
    ('Don Quijote de la Mancha', 'Cervantes Saavedra, Miguel de', 'Spain', 'Spanish', 1605,
     'The Ingenious Gentleman Don Quixote of La Mancha', 'Classic fiction',
     'Satirical adventures of a landowner who believes he is a knight.', NULL);
INSERT INTO books (title, author, country, language, pub_year, topic, content) VALUES
    ('Pride and Prejudice', 'Austen, Jane', 'United Kingdom', 'English', 1813, 'Classic fiction',
     'Courtship and class in rural England.');
INSERT INTO books (title, author, country, language, pub_year, topic, content) VALUES
    ('Frankenstein', 'Shelley, Mary', 'United Kingdom', 'English', 1818, 'Gothic fiction',
     'A scientist creates a living being and cannot face the consequences.');
INSERT INTO books (title, author, country, language, pub_year, topic, content) VALUES
    ('Platero y yo', 'Jimenez, Juan Ramon', 'Spain', 'Spanish', 1914, 'Poetic prose',
     'Short lyrical chapters about a man and his donkey.');
INSERT INTO books (title, author, country, language, pub_year, topic, content) VALUES
    ('Fortunata y Jacinta', 'Perez Galdos, Benito', 'Spain', 'Spanish', 1887, 'Classic fiction',
     'Two women and one man in nineteenth-century Madrid.');
INSERT INTO books (title, author, country, language, pub_year, alt_title, topic, content) VALUES
    ('Die Verwandlung', 'Kafka, Franz', 'Czech Republic', 'German', 1915, 'Metamorphosis', 'Modernist fiction',
     'A traveling salesman wakes up transformed into an insect.');
INSERT INTO books (title, author, country, language, pub_year, topic, content) VALUES
    ('Treasure Island', 'Stevenson, Robert Louis', 'United Kingdom', 'English', 1883, 'Adventure',
     'A boy, a map and a crew that cannot be trusted.');

INSERT INTO more_authors (title, main_author, alt_authors, mentions) VALUES
    ('Don Quijote de la Mancha', 'Cervantes Saavedra, Miguel de', 'Dore, Gustave', 'Illustrations');

INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000011', 'Don Quijote de la Mancha', 'Cervantes Saavedra, Miguel de', 'Spanish', NULL, '3rd edition', 'Sample Press', 'Madrid', 'NL-000001');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000028', 'Don Quijote de la Mancha', 'Cervantes Saavedra, Miguel de', 'English', NULL, '1st edition', 'Sample Press', 'London', 'NL-000002');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000035', 'Don Quijote de la Mancha', 'Cervantes Saavedra, Miguel de', 'French', NULL, '2nd edition', 'Sample Press', 'Paris', 'NL-000003');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000042', 'Pride and Prejudice', 'Austen, Jane', 'Spanish', 'English', '1st edition', 'Sample Press', 'Barcelona', 'NL-000004');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000059', 'Pride and Prejudice', 'Austen, Jane', 'English', NULL, '4th edition', 'Sample Press', 'London', 'NL-000005');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000066', 'Frankenstein', 'Shelley, Mary', 'English', NULL, '2nd edition', 'Sample Press', 'London', 'NL-000006');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000073', 'Frankenstein', 'Shelley, Mary', 'Spanish', NULL, '1st edition', 'Sample Press', 'Madrid', 'NL-000007');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000080', 'Frankenstein', 'Shelley, Mary', 'Italian', NULL, '1st edition', 'Sample Press', 'Milan', 'NL-000008');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000097', 'Platero y yo', 'Jimenez, Juan Ramon', 'Spanish', NULL, '5th edition', 'Sample Press', 'Madrid', 'NL-000009');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000103', 'Fortunata y Jacinta', 'Perez Galdos, Benito', 'Spanish', NULL, '2nd edition', 'Sample Press', 'Madrid', 'NL-000010');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000110', 'Die Verwandlung', 'Kafka, Franz', 'German', 'Spanish', '1st edition', 'Sample Press', 'Berlin', 'NL-000011');
INSERT INTO editions (isbn, title, author, language, alt_languages, edition, publisher, pub_place, national_lib_id) VALUES
    ('9780000000127', 'Treasure Island', 'Stevenson, Robert Louis', 'English', NULL, '3rd edition', 'Sample Press', 'Edinburgh', 'NL-000012');

INSERT INTO copies (signature, isbn, condition) VALUES ('CP001', '9780000000011', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP002', '9780000000011', 'N');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP003', '9780000000028', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP004', '9780000000035', 'W');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP005', '9780000000042', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP006', '9780000000059', 'N');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP007', '9780000000059', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP008', '9780000000066', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP009', '9780000000073', 'W');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP010', '9780000000080', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP011', '9780000000097', 'N');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP012', '9780000000097', 'G');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP013', '9780000000103', 'W');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP014', '9780000000110', 'G');
INSERT INTO copies (signature, isbn, condition, comments, deregistered) VALUES ('CP015', '9780000000127', 'D', 'Water damage', DATE '2026-05-02');
INSERT INTO copies (signature, isbn, condition) VALUES ('CP016', '9780000000127', 'G');

-- Routes, stops, fleet and staff ------------------------------------------

INSERT INTO municipalities (town, province, population) VALUES ('Villaverdana', 'Madrid', 4200);
INSERT INTO municipalities (town, province, population) VALUES ('Fuentealba', 'Madrid', 1850);
INSERT INTO municipalities (town, province, population) VALUES ('San Millan del Prado', 'Segovia', 920);
INSERT INTO municipalities (town, province, population) VALUES ('Robledillo Alto', 'Segovia', 410);
INSERT INTO municipalities (town, province, population) VALUES ('Valdecarros del Rio', 'Toledo', 3100);
INSERT INTO municipalities (town, province, population) VALUES ('Torrejoncillo Nuevo', 'Toledo', 1500);
INSERT INTO municipalities (town, province, population) VALUES ('Cerrada de Arriba', 'Avila', 780);
INSERT INTO municipalities (town, province, population) VALUES ('Penarrubia de Tormes', 'Avila', 1260);

INSERT INTO routes (route_id) VALUES ('RT001');
INSERT INTO routes (route_id) VALUES ('RT002');
INSERT INTO routes (route_id) VALUES ('RT003');

-- stop_time is in minutes since midnight (600 = 10:00)
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Villaverdana', 'Madrid', 'Plaza Mayor 1', 'RT001', 600);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Fuentealba', 'Madrid', 'Calle del Pozo 4', 'RT001', 660);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('San Millan del Prado', 'Segovia', 'Plaza de la Iglesia 2', 'RT002', 600);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Robledillo Alto', 'Segovia', 'Avenida del Roble 8', 'RT002', 660);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Valdecarros del Rio', 'Toledo', 'Paseo del Rio 3', 'RT003', 540);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Torrejoncillo Nuevo', 'Toledo', 'Calle Nueva 10', 'RT003', 600);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Cerrada de Arriba', 'Avila', 'Plaza del Ayuntamiento 1', 'RT003', 660);
INSERT INTO stops (town, province, address, route_id, stop_time) VALUES ('Penarrubia de Tormes', 'Avila', 'Calle Larga 22', 'RT003', 720);

INSERT INTO bibuses (plate, last_itv, next_itv) VALUES ('1234-BCD', DATE '2026-01-15', DATE '2027-01-15');
INSERT INTO bibuses (plate, last_itv, next_itv) VALUES ('5678-FGH', DATE '2025-06-02', DATE '2026-06-02');
INSERT INTO bibuses (plate, last_itv, next_itv) VALUES ('9012-JKL', DATE '2026-04-20', DATE '2027-04-20');

INSERT INTO drivers (passport, email, fullname, birthdate, phone, address, contract_start, contract_end) VALUES
    ('DRV-0000001', 'driver1@example.com', 'Ricardo Salas Medina', DATE '1978-04-12', 600100001, 'Calle Olmo 12, Madrid', DATE '2018-03-01', NULL);
INSERT INTO drivers (passport, email, fullname, birthdate, phone, address, contract_start, contract_end) VALUES
    ('DRV-0000002', 'driver2@example.com', 'Elena Cobos Prieto', DATE '1985-09-30', 600100002, 'Calle Fresno 5, Segovia', DATE '2021-09-15', DATE '2027-06-30');
INSERT INTO drivers (passport, email, fullname, birthdate, phone, address, contract_start, contract_end) VALUES
    ('DRV-0000003', 'driver3@example.com', 'Tomas Aranda Gil', DATE '1969-01-22', 600100003, 'Calle Pino 7, Toledo', DATE '2012-06-01', NULL);

-- Each route runs on a fixed weekday in three consecutive weeks.
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('1234-BCD', DATE '2026-09-07', 'RT001');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('5678-FGH', DATE '2026-09-08', 'RT002');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('9012-JKL', DATE '2026-09-09', 'RT003');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('5678-FGH', DATE '2026-09-14', 'RT001');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('9012-JKL', DATE '2026-09-15', 'RT002');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('1234-BCD', DATE '2026-09-16', 'RT003');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('9012-JKL', DATE '2026-09-21', 'RT001');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('1234-BCD', DATE '2026-09-22', 'RT002');
INSERT INTO assign_bus (plate, task_date, route_id) VALUES ('5678-FGH', DATE '2026-09-23', 'RT003');

INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000001', DATE '2026-09-07', 'RT001');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000002', DATE '2026-09-08', 'RT002');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000003', DATE '2026-09-09', 'RT003');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000002', DATE '2026-09-14', 'RT001');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000003', DATE '2026-09-15', 'RT002');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000001', DATE '2026-09-16', 'RT003');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000003', DATE '2026-09-21', 'RT001');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000001', DATE '2026-09-22', 'RT002');
INSERT INTO assign_drv (passport, task_date, route_id) VALUES ('DRV-0000002', DATE '2026-09-23', 'RT003');

-- The bus visits every stop of its route on each assigned day.
INSERT INTO services (town, province, bus, task_date, passport)
SELECT s.town, s.province, ab.plate, ab.task_date, ad.passport
  FROM stops s
  JOIN assign_bus ab ON ab.route_id = s.route_id
  JOIN assign_drv ad ON ad.route_id = ab.route_id AND ad.task_date = ab.task_date;

-- Users -------------------------------------------------------------------
-- user_type: P private person, L institution. User U000000005 is banned.

INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000001', 'ID-0000001', 'Lucia', 'Romero', 'Vega', DATE '1991-03-14', 'Villaverdana', 'Madrid', 'Calle Olmo 3', 'user01@example.com', 600200001, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000002', 'ID-0000002', 'Pablo', 'Navarro', NULL, DATE '1984-11-02', 'Villaverdana', 'Madrid', 'Calle Alamo 9', 'user02@example.com', 600200002, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000003', 'ID-0000003', 'Irene', 'Campos', 'Soto', DATE '1976-07-21', 'Fuentealba', 'Madrid', 'Calle del Pozo 12', NULL, 600200003, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000004', 'ID-0000004', 'Hugo', 'Ferrer', 'Lazaro', DATE '2001-01-30', 'Fuentealba', 'Madrid', 'Camino Viejo 2', 'user04@example.com', 600200004, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000005', 'ID-0000005', 'Sara', 'Duran', 'Ortega', DATE '1995-05-09', 'San Millan del Prado', 'Segovia', 'Calle Real 6', 'user05@example.com', 600200005, 'P', DATE '2026-11-17');
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000006', 'ID-0000006', 'Daniel', 'Pascual', 'Rey', DATE '1968-12-18', 'Robledillo Alto', 'Segovia', 'Avenida del Roble 15', NULL, 600200006, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000007', 'ID-0000007', 'Nuria', 'Gallego', 'Marin', DATE '1989-08-25', 'Valdecarros del Rio', 'Toledo', 'Paseo del Rio 11', 'user07@example.com', 600200007, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000008', 'ID-0000008', 'Adrian', 'Molina', 'Cano', DATE '1999-02-11', 'Torrejoncillo Nuevo', 'Toledo', 'Calle Nueva 4', 'user08@example.com', 600200008, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000009', 'ID-0000009', 'Clara', 'Santos', 'Iglesias', DATE '1957-10-03', 'Cerrada de Arriba', 'Avila', 'Plaza del Ayuntamiento 5', NULL, 600200009, 'P', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000010', 'ID-0000010', 'Municipal Library', 'Penarrubia', NULL, DATE '1990-01-01', 'Penarrubia de Tormes', 'Avila', 'Calle Larga 1', 'library@example.com', 600200010, 'L', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000011', 'ID-0000011', 'Senior Centre', 'Valdecarros', NULL, DATE '1990-01-01', 'Valdecarros del Rio', 'Toledo', 'Calle Mayor 2', 'centre@example.com', 600200011, 'L', NULL);
INSERT INTO users (user_id, id_card, name, surname1, surname2, birthdate, town, province, address, email, phone, user_type, banned_until) VALUES
    ('U000000012', 'ID-0000012', 'Marcos', 'Rivas', 'Pardo', DATE '1982-06-27', 'Penarrubia de Tormes', 'Avila', 'Calle Larga 14', 'user12@example.com', 600200012, 'P', NULL);

-- Loans and posts ---------------------------------------------------------
-- Every loan happens on a day the bookmobile visits the user's town.
-- time_of_day is a few minutes after the scheduled stop time.

INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP005', 'U000000001', DATE '2026-09-07', 'Villaverdana', 'Madrid', 'L', 605, DATE '2026-09-14');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP008', 'U000000002', DATE '2026-09-07', 'Villaverdana', 'Madrid', 'L', 610, DATE '2026-09-21');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP011', 'U000000003', DATE '2026-09-07', 'Fuentealba', 'Madrid', 'L', 665, DATE '2026-09-14');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP012', 'U000000004', DATE '2026-09-14', 'Fuentealba', 'Madrid', 'L', 670, DATE '2026-09-28');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP009', 'U000000006', DATE '2026-09-08', 'Robledillo Alto', 'Segovia', 'L', 665, DATE '2026-09-22');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP014', 'U000000007', DATE '2026-09-09', 'Valdecarros del Rio', 'Toledo', 'L', 545, DATE '2026-09-23');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP006', 'U000000008', DATE '2026-09-09', 'Torrejoncillo Nuevo', 'Toledo', 'L', 605, NULL);
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP016', 'U000000009', DATE '2026-09-16', 'Cerrada de Arriba', 'Avila', 'L', 665, NULL);
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP010', 'U000000012', DATE '2026-09-09', 'Penarrubia de Tormes', 'Avila', 'L', 725, DATE '2026-09-16');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP013', 'U000000001', DATE '2026-09-14', 'Villaverdana', 'Madrid', 'L', 603, DATE '2026-09-21');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP007', 'U000000005', DATE '2026-09-08', 'San Millan del Prado', 'Segovia', 'L', 604, DATE '2026-10-20');
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP005', 'U000000002', DATE '2026-09-21', 'Villaverdana', 'Madrid', 'L', 611, NULL);
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP008', 'U000000003', DATE '2026-09-21', 'Fuentealba', 'Madrid', 'L', 666, NULL);
INSERT INTO loans (signature, user_id, stop_date, town, province, loan_type, time_of_day, return_date) VALUES
    ('CP010', 'U000000010', DATE '2026-09-23', 'Penarrubia de Tormes', 'Avila', 'L', 722, NULL);

INSERT INTO posts (signature, user_id, stop_date, post_date, text, likes, dislikes) VALUES
    ('CP005', 'U000000001', DATE '2026-09-07', DATE '2026-09-16', 'Witty and still sharp after two centuries. I loved the dialogue.', 4, 0);
INSERT INTO posts (signature, user_id, stop_date, post_date, text, likes, dislikes) VALUES
    ('CP008', 'U000000002', DATE '2026-09-07', DATE '2026-09-20', 'Darker than I expected, but I could not put it down.', 7, 1);
INSERT INTO posts (signature, user_id, stop_date, post_date, text, likes, dislikes) VALUES
    ('CP014', 'U000000007', DATE '2026-09-09', DATE '2026-09-22', 'Short and unsettling. The ending stayed with me.', 3, 0);
INSERT INTO posts (signature, user_id, stop_date, post_date, text, likes, dislikes) VALUES
    ('CP010', 'U000000012', DATE '2026-09-09', DATE '2026-09-15', 'A good edition, easy to read.', 1, 0);
INSERT INTO posts (signature, user_id, stop_date, post_date, text, likes, dislikes) VALUES
    ('CP012', 'U000000004', DATE '2026-09-14', DATE '2026-09-25', 'Beautiful prose, perfect for a slow afternoon.', 5, 0);

COMMIT;
