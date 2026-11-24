CREATE SCHEMA IF NOT EXISTS Tourfirma;
SET search_path TO Tourfirma;
DROP TABLE IF EXISTS request_history CASCADE;
DROP TABLE IF EXISTS request CASCADE;
DROP TABLE IF EXISTS tour CASCADE;
DROP TABLE IF EXISTS report CASCADE;
DROP TABLE IF EXISTS report_type CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS passport_data CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS authentication CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS service_category CASCADE;
DROP TABLE IF EXISTS discount CASCADE;
DROP TABLE IF EXISTS request_status CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS country CASCADE;

CREATE TABLE role (
    role_id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(50) NOT NULL UNIQUE
);

CREATE TABLE authentication (
    auth_id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login            varchar(50)  NOT NULL UNIQUE,
    password         varchar(100) NOT NULL
);

CREATE TABLE users (
    user_id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name        varchar(50)  NOT NULL,
    first_name       varchar(50)  NOT NULL,
    middle_name      varchar(50),
    phone            varchar(20),
    email            varchar(100),
    organization     varchar(100),
    created_at       timestamp    NOT NULL DEFAULT now(),
    role_id          integer      NOT NULL REFERENCES role (role_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    auth_id          integer      NOT NULL UNIQUE REFERENCES authentication (auth_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE passport_data (
    passport_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    series           varchar(4)   NOT NULL,
    number           varchar(6)   NOT NULL,
    issue_date       date         NOT NULL,
    issued_by        varchar(150) NOT NULL,
    UNIQUE (series, number)
);

CREATE TABLE client (
    client_id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name        varchar(50) NOT NULL,
    first_name       varchar(50) NOT NULL,
    middle_name      varchar(50),
    birth_date       date        NOT NULL,
    phone            varchar(20) NOT NULL,
    email            varchar(100),
    registration_date timestamp   NOT NULL DEFAULT now(),
    wishes           text,
    foreign_passport varchar(20),
    passport_id      integer     NOT NULL UNIQUE REFERENCES passport_data (passport_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE country (
    country_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(60) NOT NULL UNIQUE
);

CREATE TABLE hotel (
    hotel_id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(100) NOT NULL,
    description      text,
    address          varchar(200) NOT NULL,
    stars            integer      NOT NULL,

    CONSTRAINT hotel_stars_ck CHECK (stars BETWEEN 1 AND 5)
);

CREATE TABLE service_category (
    category_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(50) NOT NULL UNIQUE,
    description      text
);

CREATE TABLE services (
    service_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(100)  NOT NULL,
    price            numeric(10,2) NOT NULL CHECK (price > 0),
    category_id      integer       NOT NULL REFERENCES service_category (category_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE discount (
    discount_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(50)  NOT NULL UNIQUE,
    percentage       numeric(5,2) NOT NULL CHECK (percentage BETWEEN 0 AND 100)
);

CREATE TABLE request_status (
    status_id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(50) NOT NULL UNIQUE
);

CREATE TABLE report_type (
    type_id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(50) NOT NULL UNIQUE
);

CREATE TABLE tour (
    tour_id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             varchar(150)  NOT NULL,
    description      text,
    start_date       date          NOT NULL,
    end_date         date          NOT NULL,
    price            numeric(10,2) NOT NULL CHECK (price > 0),
    user_id          integer       NOT NULL REFERENCES users (user_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    service_id       integer       REFERENCES services (service_id)
                       ON UPDATE CASCADE ON DELETE SET NULL,
    hotel_id         integer       NOT NULL REFERENCES hotel (hotel_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    country_id       integer       NOT NULL REFERENCES country (country_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (end_date >= start_date)
);

CREATE TABLE request (
    request_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    submission_date  timestamp     NOT NULL DEFAULT now(),
    quantity         integer       NOT NULL CHECK (quantity > 0),
    contract_number  varchar(30)   UNIQUE,
    total_cost       numeric(10,2) NOT NULL CHECK (total_cost >= 0),
    user_id          integer       NOT NULL REFERENCES users (user_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    client_id        integer       NOT NULL REFERENCES client (client_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    tour_id          integer       NOT NULL REFERENCES tour (tour_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    status_id        integer       NOT NULL REFERENCES request_status (status_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    discount_id      integer       REFERENCES discount (discount_id)
                       ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE request_history (
    record_id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    change_date      timestamp    NOT NULL DEFAULT now(),
    comment          varchar(255),
    request_id       integer      NOT NULL REFERENCES request (request_id)
                       ON UPDATE CASCADE ON DELETE CASCADE,
    user_id          integer      NOT NULL REFERENCES users (user_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE report (
    report_id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    period_start     date         NOT NULL,
    period_end       date         NOT NULL,
    user_id          integer      NOT NULL REFERENCES users (user_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    type_id          integer      NOT NULL REFERENCES report_type (type_id)
                       ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (period_end >= period_start)
);

INSERT INTO role (name) VALUES
    ('Tour operator'),
    ('Sales manager'),
    ('Administrator');

INSERT INTO request_status (name) VALUES
    ('Sent'),
    ('Confirmed'),
    ('Rejected'),
    ('Cancelled'),
    ('Under revision'),
    ('Closed');

INSERT INTO report_type (name) VALUES
    ('Sold tours report'),
    ('Tour operators report');

INSERT INTO country (name) VALUES
    ('Turkey'), ('Egypt'), ('Greece'), ('UAE'), ('Russia'), ('Thailand');

INSERT INTO discount (name, percentage) VALUES
    ('Regular customer', 5),
    ('Early booking', 7),
    ('Newlyweds', 10),
    ('Large family', 12),
    ('Group of 5 or more', 8);

INSERT INTO service_category (name, description) VALUES
    ('Transfer',  'Transportation between the airport and the hotel'),
    ('Insurance', 'Medical insurance and trip cancellation insurance'),
    ('Excursions','Sightseeing and themed tours at the resort'),
    ('Meals',     'Upgraded meal plan at the hotel');

INSERT INTO services (name, price, category_id) VALUES
    ('Group transfer airport - hotel', 1500.00, 1),
    ('Private transfer',               3500.00, 1),
    ('Medical insurance',              1200.00, 2),
    ('Trip cancellation insurance',    2000.00, 2),
    ('Resort sightseeing tour',        2500.00, 3),
    ('One-day mountain trip',          4500.00, 3),
    ('All inclusive meal plan',        6000.00, 4),
    ('Ultra all inclusive meal plan',  9000.00, 4);

INSERT INTO hotel (name, description, address, stars) VALUES
    ('Azure Beach Resort',     'Beachfront hotel with a sandy beach and a water park',
     'Antalya, Lara district, Primorskaya st., 12', 5),
    ('Golden Surf',            'Family hotel with a kids club and swimming pools',
     'Antalya, Kemer district, Sosnovaya st., 7', 4),
    ('Red Sea Palace',         'Large resort complex on the Red Sea coast',
     'Hurghada, Al Dahar embankment, 25', 5),
    ('Coral Dive Club',        'Hotel with its own diving center and coral reef',
     'Sharm El Sheikh, Naama Bay, 3', 4),
    ('Aegean Pearl',           'Seaside hotel with mountain views',
     'Crete, Rethymno, Eleftherios st., 18', 4),
    ('Palm Grand',             'City hotel near Jumeirah beach',
     'Dubai, Jumeirah, Al Safa ave., 40', 5),
    ('Black Sea Park',         'Hotel in a park area near the embankment',
     'Sochi, Adler district, Primorskaya st., 9', 4),
    ('Tropicana Beach',        'Resort hotel on Kata beach',
     'Phuket, Kata beach, 21', 5);

INSERT INTO authentication (login, password) VALUES
    ('admin',    'Admin2026'),
    ('smirnova', 'Manager01'),
    ('kozlov',   'Manager02'),
    ('belova',   'Operator01'),
    ('petrov',   'Operator02'),
    ('gromova',  'Operator03');

INSERT INTO users (last_name, first_name, middle_name, phone, email, organization, created_at, role_id, auth_id) VALUES
    ('Orlov',    'Dmitry', 'Sergeevich',  '+7 (900) 100-10-01', 'orlov@tourfirm.com',        NULL,           '2026-09-01 09:00', 3, 1),
    ('Smirnova', 'Anna',   'Pavlovna',    '+7 (900) 100-10-02', 'smirnova@tourfirm.com',     NULL,           '2026-09-01 09:05', 2, 2),
    ('Kozlov',   'Igor',   'Andreevich',  '+7 (900) 100-10-03', 'kozlov@tourfirm.com',       NULL,           '2026-09-01 09:10', 2, 3),
    ('Belova',   'Maria',  'Olegovna',    '+7 (900) 200-20-01', 'belova@suntour.com',        'SunTour',      '2026-09-02 10:00', 1, 4),
    ('Petrov',   'Artem',  'Nikolaevich', '+7 (900) 200-20-02', 'petrov@hellas-travel.com',  'Hellas Travel','2026-09-02 10:10', 1, 5),
    ('Gromova',  'Elena',  'Viktorovna',  '+7 (900) 200-20-03', 'gromova@horizon-tours.com', 'Horizon',      '2026-09-02 10:20', 1, 6);

INSERT INTO passport_data (series, number, issue_date, issued_by) VALUES
    ('4508', '312845', '2012-06-14', 'Moscow Department of Internal Affairs'),
    ('4510', '458216', '2014-09-02', 'Saint Petersburg Department of Internal Affairs'),
    ('4504', '127399', '2009-03-21', 'Novosibirsk Central District Police Department'),
    ('4515', '903471', '2015-11-30', 'Sverdlovsk Region Department of Internal Affairs'),
    ('4512', '665012', '2013-05-17', 'Tatarstan Department of Internal Affairs'),
    ('4506', '281754', '2006-12-08', 'Yaroslavl Sovetsky District Police Department'),
    ('4520', '740396', '2020-12-20', 'Moscow Department of Internal Affairs'),
    ('4518', '356128', '2018-04-27', 'Yaroslavl Region Department of Internal Affairs');

INSERT INTO client (last_name, first_name, middle_name, birth_date, phone, email, registration_date, wishes, foreign_passport, passport_id) VALUES
    ('Ivanov',   'Alexey',    'Petrovich',     '1988-03-14', '+7 (910) 111-11-11', 'ivanov.a@mail.com',    '2026-10-04 12:10', 'Quiet room, all inclusive meal plan', '75 1234567', 1),
    ('Ivanova',  'Olga',      'Nikolaevna',    '1990-07-02', '+7 (910) 222-22-22', 'ivanova.o@mail.com',   '2026-10-04 12:20', NULL,                                  '75 2345678', 2),
    ('Kuznetsov','Sergey',    'Viktorovich',   '1979-11-25', '+7 (910) 333-33-33', 'kuznetsov@mail.com',   '2026-10-10 15:00', 'Hotel with a kids club',              '75 3456789', 3),
    ('Morozova', 'Ekaterina', 'Andreevna',     '1995-05-18', '+7 (910) 444-44-44', 'morozova@mail.com',    '2026-10-18 11:30', 'Room with a sea view',                '75 4567890', 4),
    ('Volkov',   'Denis',     'Alexandrovich', '1985-09-09', '+7 (910) 555-55-55', 'volkov.d@mail.com',    '2026-10-30 14:45', 'Diving, excursions',                  '75 5678901', 5),
    ('Sokolova', 'Tatiana',   'Ivanovna',      '1972-01-30', '+7 (910) 666-66-66', 'sokolova@mail.com',    '2026-11-03 10:15', NULL,                                  '75 6789012', 6),
    ('Novikov',  'Pavel',     'Igorevich',     '2000-12-12', '+7 (910) 777-77-77', 'novikov.p@mail.com',   '2026-11-07 16:20', 'Active holiday',                      NULL,         7),
    ('Fedorova', 'Natalia',   'Sergeevna',     '1993-04-21', '+7 (910) 888-88-88', 'fedorova@mail.com',    '2026-11-11 13:05', 'Traveling with friends, group transfer', NULL,      8);

INSERT INTO tour (name, description, start_date, end_date, price, user_id, service_id, hotel_id, country_id) VALUES
    ('Antalya: all inclusive, 7 nights', 'Beach holiday with a flight from Moscow',      '2027-06-05', '2027-06-12',  68000.00, 4, 1,    1, 1),
    ('Antalya: family holiday',          'Holiday with children, kids club, animation',  '2027-07-10', '2027-07-20',  92000.00, 4, 3,    2, 1),
    ('Hurghada: Red Sea',                'Beach holiday and snorkeling',                 '2027-02-14', '2027-02-21',  54000.00, 5, 1,    3, 2),
    ('Sharm El Sheikh: diving tour',     'Dives on coral reefs with an instructor',      '2027-03-10', '2027-03-20',  73000.00, 5, NULL, 4, 2),
    ('Crete: Greek holidays',            'Seaside holiday with excursions',              '2027-06-20', '2027-07-01', 105000.00, 5, 5,    5, 3),
    ('Dubai: winter holidays',           'New Year holidays in the UAE',                 '2026-12-28', '2027-01-06', 128000.00, 6, 2,    6, 4),
    ('Sochi: mountains and sea',         'Black Sea holiday and trips to the mountains', '2027-08-01', '2027-08-10',  47000.00, 6, NULL, 7, 5),
    ('Phuket: tropical paradise',        'Beach holiday and island excursions',          '2027-01-20', '2027-02-01', 139000.00, 6, 4,    8, 6),
    ('Antalya: early holiday',           'Spring holiday with a flight from Moscow',     '2027-05-01', '2027-05-08',  61000.00, 4, 1,    1, 1);

INSERT INTO request (submission_date, quantity, contract_number, total_cost, user_id, client_id, tour_id, status_id, discount_id) VALUES
    ('2026-10-05 10:15', 2, 'TF-2026-0001', 0, 2, 1, 1, 6, 2),
    ('2026-10-12 09:40', 3, 'TF-2026-0002', 0, 3, 3, 2, 6, 4),
    ('2026-10-20 11:00', 2, 'TF-2026-0003', 0, 2, 4, 3, 6, 3),
    ('2026-11-02 13:20', 1, 'TF-2026-0004', 0, 3, 5, 8, 2, NULL),
    ('2026-11-05 12:00', 4, NULL,           0, 2, 6, 5, 3, NULL),
    ('2026-11-08 15:45', 2, NULL,           0, 3, 7, 4, 1, NULL),
    ('2026-11-10 10:20', 2, NULL,           0, 2, 2, 6, 4, NULL),
    ('2026-11-12 14:30', 5, NULL,           0, 3, 8, 7, 5, 5),
    ('2026-11-15 11:30', 2, NULL,           0, 2, 1, 9, 1, 1),
    ('2026-11-17 09:10', 3, NULL,           0, 3, 3, 1, 2, NULL);

UPDATE request r
SET total_cost = round(
        t.price * r.quantity
        * (1 - COALESCE((SELECT d.percentage FROM discount d WHERE d.discount_id = r.discount_id), 0) / 100), 2)
FROM tour t
WHERE t.tour_id = r.tour_id;

INSERT INTO request_history (change_date, comment, request_id, user_id) VALUES
    ('2026-10-05 10:15', 'Request sent to the tour operator',                          1, 2),
    ('2026-10-06 12:30', 'Request confirmed, seats reserved',                          1, 4),
    ('2026-10-12 11:20', 'All actions completed, request closed',                      1, 1),

    ('2026-10-12 09:40', 'Request sent to the tour operator',                          2, 3),
    ('2026-10-13 14:05', 'Request confirmed',                                          2, 4),
    ('2026-10-16 17:10', 'Contract issued, payment received, request closed',          2, 1),

    ('2026-10-20 11:00', 'Request sent to the tour operator',                          3, 2),
    ('2026-10-21 10:45', 'Request confirmed',                                          3, 5),
    ('2026-10-25 15:30', 'All actions completed, request closed',                      3, 1),

    ('2026-11-02 13:20', 'Request sent to the tour operator',                          4, 3),
    ('2026-11-03 09:50', 'Request confirmed, contract issued',                         4, 6),

    ('2026-11-05 12:00', 'Request sent to the tour operator',                          5, 2),
    ('2026-11-06 11:10', 'Rejected: not enough seats for the selected dates',          5, 5),

    ('2026-11-08 15:45', 'Request sent to the tour operator',                          6, 3),

    ('2026-11-10 10:20', 'Request sent to the tour operator',                          7, 2),
    ('2026-11-11 16:40', 'Cancelled: the customer refused the trip',                   7, 2),

    ('2026-11-12 14:30', 'Request sent to the tour operator',                          8, 3),
    ('2026-11-13 10:00', 'Request confirmed',                                          8, 6),
    ('2026-11-14 12:15', 'Returned for revision: passport data of one tourist is missing', 8, 1),

    ('2026-11-15 11:30', 'Request sent to the tour operator',                          9, 2),

    ('2026-11-17 09:10', 'Request sent to the tour operator',                         10, 3),
    ('2026-11-18 13:25', 'Request confirmed',                                         10, 4);

INSERT INTO report (period_start, period_end, user_id, type_id) VALUES
    ('2026-10-01', '2026-10-31', 4, 1),
    ('2026-10-01', '2026-10-31', 5, 1),
    ('2026-10-01', '2026-10-31', 1, 2),
    ('2026-11-01', '2026-11-23', 1, 2);
