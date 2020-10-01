DROP TRIGGER book_tr;

DROP SEQUENCE book_sq;

DROP TABLE book CASCADE CONSTRAINTS PURGE;

DROP TABLE move CASCADE CONSTRAINTS PURGE;

DROP TABLE movement CASCADE CONSTRAINTS PURGE;

DROP TABLE receive CASCADE CONSTRAINTS PURGE;

DROP TABLE seller CASCADE CONSTRAINTS PURGE;

DROP TABLE send CASCADE CONSTRAINTS PURGE;

DROP TABLE store CASCADE CONSTRAINTS PURGE;

CREATE TABLE book (
    id            INTEGER NOT NULL,
    name          VARCHAR2(100) NOT NULL,
    author        VARCHAR2(100) NOT NULL,
    publisher     VARCHAR2(100) NOT NULL,
    price_input   NUMBER NOT NULL,
    price_output  NUMBER NOT NULL,
    count         INTEGER NOT NULL
);

ALTER TABLE book ADD CONSTRAINT book_pk PRIMARY KEY ( id );

CREATE SEQUENCE book_sq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

CREATE OR REPLACE TRIGGER book_tr 
BEFORE INSERT ON book 
FOR EACH ROW

BEGIN
  SELECT book_sq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

CREATE TABLE move (
    book_id      INTEGER NOT NULL,
    movement_id  INTEGER NOT NULL,
    count        INTEGER NOT NULL
);

ALTER TABLE move ADD CONSTRAINT move_pk PRIMARY KEY ( book_id,
                                                      movement_id );

CREATE TABLE movement (
    id              INTEGER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) NOT NULL,
    waybill_number  VARCHAR2(100) NOT NULL,
    waybill_date    DATE DEFAULT SYSDATE NOT NULL,
    operation_type  SMALLINT NOT NULL
);

ALTER TABLE movement ADD CONSTRAINT movement_pk PRIMARY KEY ( id );

CREATE TABLE receive (
    seller_id    INTEGER NOT NULL,
    movement_id  INTEGER NOT NULL
);

ALTER TABLE receive ADD CONSTRAINT receive_pk PRIMARY KEY ( seller_id,
                                                            movement_id );

CREATE TABLE seller (
    id       INTEGER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) NOT NULL,
    name     VARCHAR2(100) NOT NULL,
    address  VARCHAR2(100) NOT NULL,
    percent  FLOAT DEFAULT 10 NOT NULL
);

ALTER TABLE seller ADD CHECK ( percent BETWEEN 5 AND 100 );

ALTER TABLE seller ADD CONSTRAINT seller_pk PRIMARY KEY ( id );

CREATE TABLE send (
    seller_id    INTEGER NOT NULL,
    movement_id  INTEGER NOT NULL
);

ALTER TABLE send ADD CONSTRAINT send_pk PRIMARY KEY ( seller_id,
                                                      movement_id );

CREATE TABLE store (
    book_id    INTEGER NOT NULL,
    seller_id  INTEGER NOT NULL,
    count      INTEGER NOT NULL
);

ALTER TABLE store ADD CONSTRAINT store_pk PRIMARY KEY ( book_id,
                                                        seller_id );

ALTER TABLE move
    ADD CONSTRAINT move_book_fk FOREIGN KEY ( book_id )
        REFERENCES book ( id )
        ON DELETE CASCADE;

ALTER TABLE move
    ADD CONSTRAINT move_movement_fk FOREIGN KEY ( movement_id )
        REFERENCES movement ( id )
        ON DELETE CASCADE;

ALTER TABLE receive
    ADD CONSTRAINT receive_movement_fk FOREIGN KEY ( movement_id )
        REFERENCES movement ( id )
        ON DELETE CASCADE;

ALTER TABLE receive
    ADD CONSTRAINT receive_seller_fk FOREIGN KEY ( seller_id )
        REFERENCES seller ( id )
        ON DELETE SET NULL;

ALTER TABLE send
    ADD CONSTRAINT send_movement_fk FOREIGN KEY ( movement_id )
        REFERENCES movement ( id )
        ON DELETE CASCADE;

ALTER TABLE send
    ADD CONSTRAINT send_seller_fk FOREIGN KEY ( seller_id )
        REFERENCES seller ( id )
        ON DELETE SET NULL;

ALTER TABLE store
    ADD CONSTRAINT store_book_fk FOREIGN KEY ( book_id )
        REFERENCES book ( id )
        ON DELETE CASCADE;

ALTER TABLE store
    ADD CONSTRAINT store_seller_fk FOREIGN KEY ( seller_id )
        REFERENCES seller ( id )
        ON DELETE SET NULL;

INSERT ALL
INTO book (name, author, publisher, price_input, price_output, count)
VALUES ('book1', 'author1', 'publisher1', 100, 200, 11)
INTO book (name, author, publisher, price_input, price_output, count)
VALUES ('book2', 'author2', 'publisher2', 100, 200, 12)
INTO book (name, author, publisher, price_input, price_output, count)
VALUES ('book3', 'author3', 'publisher3', 100, 200, 13)
SELECT * FROM dual;

INSERT INTO seller (name, address, percent)
VALUES ('seller1', 'address1', 7);
INSERT INTO seller (name, address)
VALUES ('seller2', 'address2');

INSERT INTO movement (waybill_number, operation_type)
VALUES ('01000', 1);

INSERT ALL
INTO store (book_id, seller_id, count)
VALUES (1, 2, 3)
INTO store (book_id, seller_id, count)
VALUES (2, 2, 1)
INTO store (book_id, seller_id, count)
VALUES (2, 1, 4)
INTO store (book_id, seller_id, count)
VALUES (3, 1, 5)
SELECT * FROM dual;

INSERT INTO send (seller_id, movement_id)
VALUES (1, 1);

INSERT INTO receive (seller_id, movement_id)
VALUES (2, 1);

INSERT INTO move (book_id, movement_id, count)
VALUES (2, 1, 3);
INSERT INTO move (book_id, movement_id, count)
VALUES (3, 1, 2);