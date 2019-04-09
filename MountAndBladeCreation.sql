/*
SELECT
   	tc.table_name, kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    NATURAL JOIN information_schema.key_column_usage AS kcu
    JOIN information_schema.constraint_column_usage AS ccu
    ON ( ccu.constraint_name = tc.constraint_name )
WHERE constraint_type = 'FOREIGN KEY' AND tc.table_name IN (SELECT table_name FROM information_schema.tables WHERE table_schema='public');
*/

/*
 drop table if exists "building_types" cascade;
 drop table if exists "rels_character_fraction" cascade;
 drop table if exists "rels_fractions" cascade;
 drop table if exists "item_types" cascade;
 drop table if exists "rels_characters" cascade;
 drop table if exists "items" cascade;
 drop table if exists "battles" cascade;
 drop table if exists "inventory" cascade;
 drop table if exists "people_type" cascade;
 drop table if exists "people" cascade;
 drop table if exists "fractions" cascade;
 drop table if exists "buildings" cascade

*/

-- SELECT column_name,data_type,character_maximum_length FROM information_schema.columns WHERE table_name = 'people_type';


CREATE TABLE PEOPLE_TYPE (
	ID SERIAL PRIMARY KEY,
	TYPE_NAME VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE FRACTIONS (
	ID SERIAL PRIMARY KEY,
	FRAC_NAME VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE PEOPLE (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR(40) NOT NULL,
	HUM_TYPE_ID INTEGER NOT NULL,
	FRAC_ID INTEGER,
	DINARS INTEGER CHECK (DINARS IS NULL OR DINARS >= 0 )
);

CREATE TABLE ITEM_TYPES ( 
	ID SERIAL PRIMARY KEY,
	TYPE_NAME VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE ITEMS (
	ID SERIAL PRIMARY KEY,
	ITEM_NAME VARCHAR(40) NOT NULL UNIQUE,
	ITEM_TYPE_ID INTEGER NOT NULL,
	DIN_COST INTEGER NOT NULL CHECK ( DIN_COST > 0 )
);

CREATE TABLE INVENTORY (
	ID SERIAL PRIMARY KEY,
	HUM_ID INTEGER NOT NULL,
	ITEM_ID INTEGER NOT NULL
);

CREATE TABLE BUILDING_TYPES ( 
	ID SERIAL PRIMARY KEY,
	TYPE_NAME VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE BUILDINGS (
	ID SERIAL PRIMARY KEY,
	BUILDING_NAME VARCHAR(20) NOT NULL UNIQUE,
	X_POS INTEGER NOT NULL CHECK ( X_POS BETWEEN -10000 AND 10000 ),
	Y_POS INTEGER NOT NULL CHECK ( Y_POS BETWEEN -10000 AND 10000 ),
	BUILDING_TYPE_ID INTEGER NOT NULL,
	FRAC_ID INTEGER NOT NULL
);

CREATE TABLE BATTLES (
	ID SERIAL PRIMARY KEY,
	HUM1_ID INTEGER NOT NULL,
	HUM2_ID INTEGER NOT NULL,
	BUILDING_ID INTEGER,
	X_POS INTEGER CHECK ( X_POS IS NULL OR ( X_POS BETWEEN -10000 AND 10000 ) ),
	Y_POS INTEGER CHECK ( Y_POS IS NULL OR ( Y_POS BETWEEN -10000 AND 10000 ) ),
	BATTLE_DATE DATE NOT NULL,
	HAS_WON BOOLEAN,
	CHECK ( HUM1_ID != HUM2_ID )
);

CREATE TABLE RELS_CHARACTERS (
	ID SERIAL PRIMARY KEY,
	HUM1_ID INTEGER NOT NULL,
	HUM2_ID INTEGER NOT NULL,
	REL_LVL INTEGER NOT NULL CHECK ( REL_LVL BETWEEN -100 AND 100 ),
	CHECK ( HUM1_ID != HUM2_ID )
);

CREATE TABLE RELS_CHARACTER_FRACTION (
	ID SERIAL PRIMARY KEY,
	HUM_ID INTEGER NOT NULL,
	FRAC_ID INTEGER NOT NULL,
	REL_LVL INTEGER NOT NULL CHECK ( REL_LVL BETWEEN -100 AND 100 )
);

CREATE TABLE RELS_FRACTIONS (
	ID SERIAL PRIMARY KEY,
	FRAC1_ID INTEGER NOT NULL,
	FRAC2_ID INTEGER NOT NULL,
	REL_LVL INTEGER NOT NULL CHECK ( REL_LVL BETWEEN -100 AND 100 ),
	CHECK ( FRAC1_ID != FRAC2_ID ),
	UNIQUE ( FRAC1_ID, FRAC2_ID )
);


-- CREATING RELATIONS

ALTER TABLE PEOPLE
	ADD FOREIGN KEY (HUM_TYPE_ID)		REFERENCES PEOPLE_TYPE (ID),
	ADD FOREIGN KEY (FRAC_ID)			REFERENCES FRACTIONS (ID);

ALTER TABLE ITEMS
	ADD FOREIGN KEY (ITEM_TYPE_ID)		REFERENCES ITEM_TYPES (ID);

ALTER TABLE INVENTORY
	ADD FOREIGN KEY (HUM_ID)			REFERENCES PEOPLE (ID),
	ADD FOREIGN KEY (ITEM_ID) 			REFERENCES ITEMS (ID);

ALTER TABLE BUILDINGS
	ADD FOREIGN KEY (BUILDING_TYPE_ID)	REFERENCES BUILDING_TYPES (ID),
	ADD FOREIGN KEY (FRAC_ID)			REFERENCES FRACTIONS (ID);

ALTER TABLE BATTLES
	ADD FOREIGN KEY (HUM1_ID)			REFERENCES PEOPLE (ID),
	ADD FOREIGN KEY (HUM2_ID)			REFERENCES PEOPLE (ID),
	ADD FOREIGN KEY (BUILDING_ID)		REFERENCES BUILDINGS (ID);

ALTER TABLE RELS_CHARACTERS 
	ADD FOREIGN KEY (HUM1_ID)			REFERENCES PEOPLE (ID),
	ADD FOREIGN KEY (HUM2_ID)			REFERENCES PEOPLE (ID);

ALTER TABLE RELS_CHARACTER_FRACTION
	ADD FOREIGN KEY (HUM_ID)			REFERENCES PEOPLE (ID),
	ADD FOREIGN KEY (FRAC_ID)			REFERENCES FRACTIONS (ID);

ALTER TABLE RELS_FRACTIONS
	ADD FOREIGN KEY (FRAC1_ID)			REFERENCES FRACTIONS (ID),
	ADD FOREIGN KEY (FRAC2_ID)			REFERENCES FRACTIONS (ID);

	
-- CREATING DATA

INSERT INTO PEOPLE_TYPE (TYPE_NAME) VALUES
	('герой'),
	('перевозчик'),
	('нейтрал'),
	('леди');

INSERT INTO FRACTIONS (FRAC_NAME) VALUES
	('Кергитское ханство'),
	('Северное королевство'),
	('Королевство Родоков'),
	('Королевство Свадия'),
	('Королевство Вегирс'),
	('Сарранидский Султанат');

INSERT INTO PEOPLE (NAME, HUM_TYPE_ID, FRAC_ID, DINARS) VALUES
	('Граф Райкс', 1, 3, 12343),
	('Боярин Рудин', 1, 3, 57573),
	('Боярин Хавел', 1, 5, 1456),
	('Боярин Нелаг', 1, 5, 732),
	('Карабан Ноян', 1, 1, 6532),
	('Граф Регас', 1, 4, 4272),
	('Граф Дэлинард', 1, 4, 8264),
	('Эмир Азадун ', 1, 6, 456),
	('Эмир Дашвал', 1, 6, 9124),
	('Ярл Турегор', 1, 2, 34583),
	('Ярл Турия', 1, 2, 1234),
	('Джоана', 4, NULL, NULL),
	('Дрина', 4, NULL, NULL),
	('Бандиты-горцы', 3, NULL, 1546),
	('Дезертиры', 3, NULL, 234),
	('Охотники за гол', 3, NULL, 781),
	('Сельские фе', 2, NULL, 55),
	('Караван', 2, NULL, 348);

INSERT INTO ITEM_TYPES (TYPE_NAME) VALUES
	('оружие'),
	('доспех'),
	('боеприпасы'),
	('лошадь'),
	('еда'),
	('прочее');

INSERT INTO ITEMS (ITEM_NAME, ITEM_TYPE_ID, DIN_COST) VALUES
	('Калёный северный меч', 1, 5023),
	('Сбалансированный полуторный меч', 1, 4730),
	('Мастерский боевой лук', 1, 1500),
	('Лук кочевника', 1, 600),
	('Зазубренные стрелы', 3, 150),
	('Погнутые болты', 3, 30),
	('Бархат', 6, 414),
	('Книга исцеления', 6, 5432),
	('Свежая свинина', 5, 47),
	('Фрукты', 5, 33),
	('Хлеб', 5, 21),
	('Стальной щит', 2, 609),
	('Обычный тарч', 2, 323),
	('Резвый скаковой конь', 4, 10831),
	('Тяжёлый вьючный гунтер', 4, 8074),
	('Толстый крылатый закрытый шлем', 2, 3422),
	('Толстый бацинет с забралом', 2, 2738),
	('Помятая зелёная туника', 2, 346),
	('Толстый латный доспех', 2, 8613),
	('Стальные наголенники', 2, 3553),
	('Грубые кольчатые чулки', 2, 874),
	('Усиленные чешуйчатые перчатки', 2, 605),
	('Ламеллярные перчатки', 2, 126);


INSERT INTO INVENTORY (HUM_ID, ITEM_ID) VALUES
	(3, 1),
	(3, 4),
	(3, 5),
	(7, 1),
	(7, 10),
	(11, 12),
	(11, 14),
	(11, 2);

INSERT INTO BUILDING_TYPES (TYPE_NAME) VALUES
	('город'),
	('замок'),
	('деревня');

INSERT INTO BUILDINGS (BUILDING_NAME, X_POS, Y_POS, BUILDING_TYPE_ID, FRAC_ID) VALUES
	('Суно', -8000, -540, 1, 4),
	('Рибелет', -8200, -500, 2, 4),
	('Рулунс', 8100, 300, 3, 4),
	('Саргот', 2150, 500, 1, 2),
	('Курин', 2400, 400, 2, 2),
	('Рувар', 2450, 250, 3, 2),
	('Кудан', -4213, 4683, 1, 5),
	('Слезк', -4126, 4534, 2, 5),
	('Базек', -4457, 4375, 3, 5),
	('Барейе', 5954, 4285, 1, 6),
	('Дюррин', 6123, 4400, 2, 6),
	('Сехтем', 6300, 4500 , 3, 6),
	('Ичамур', -6783, 142, 1, 1),
	('Дистар', -6495, 900, 2, 1),
	('Дуган', -6200, 500, 3, 1),
	('Джелкала', -9120, -3673, 1, 3),
	('Эргеллон', -9240, -3487, 2, 3),
	('Эспиш', -9400, -3374, 3, 3);

INSERT INTO BATTLES (HUM1_ID, HUM2_ID, BUILDING_ID, X_POS, Y_POS, BATTLE_DATE, HAS_WON) VALUES
	(1, 7, 1, NULL, NULL, '1259-05-10', NULL),
	(3, 11, 5, NULL, NULL, '1259-06-22', TRUE),
	(5, 9, NULL, 4932, 912, '1259-06-23', FALSE),
	(12, 6, NULL, 5342, 367, '1259-07-17', FALSE);

INSERT INTO RELS_CHARACTERS (HUM1_ID, HUM2_ID, REL_LVL) VALUES
	(3, 5, 100),
	(2, 7, 15),
	(4, 9, -20),
	(6, 10, -70);

INSERT INTO RELS_CHARACTER_FRACTION (HUM_ID, FRAC_ID, REL_LVL) VALUES
	(5, 1, -95),
	(8, 3, 55),
	(11, 2, 30),
	(12, 6, -5);

INSERT INTO RELS_FRACTIONS (FRAC1_ID, FRAC2_ID, REL_LVL) VALUES
	(1, 5, 40),
	(2, 4, 85),
	(6, 1, -30),
	(3, 2, -65);



-- CREATING TRIGGERS

CREATE OR REPLACE FUNCTION check_battle_row() RETURNS trigger AS $$
    BEGIN
        IF NEW.BUILDING_ID IS NULL AND (NEW.X_POS IS NULL OR NEW.Y_POS IS NULL) THEN
            RAISE EXCEPTION 'Building and position(-s) can not be undefined as the same time!';
        END IF;

        IF NEW.BUILDING_ID IS NOT NULL AND (NEW.X_POS IS NOT NULL OR NEW.Y_POS IS NOT NULL) THEN
        	RAISE EXCEPTION 'Building and position(-s) can not be defined as the same time!';
        END IF;

        IF ( NEW.BUILDING_ID IS NOT NULL AND EXISTS ( SELECT RES.ID FROM (
        	 SELECT PEOPLE.ID, PEOPLE.NAME, PEOPLE_TYPE.TYPE_NAME FROM PEOPLE JOIN PEOPLE_TYPE 
        	 ON (PEOPLE.HUM_TYPE_ID = PEOPLE_TYPE.ID)
        	 	) AS RES
        	 WHERE RES.ID IN (NEW.HUM1_ID, NEW.HUM2_ID) AND RES.TYPE_NAME IN ('перевозчик','нейтрал'))) THEN
        	 RAISE EXCEPTION 'Battle with neutrals for building is not allowed!';
        END IF;

        IF EXISTS (SELECT ID FROM BUILDING_TYPES WHERE ( TYPE_NAME = 'деревня' AND ID = NEW.BUILDING_ID ) ) THEN
        	RAISE EXCEPTION 'Battles can not occur for villages!';
        END IF;

        IF ( NEW.HAS_WON IS NULL AND EXISTS( SELECT COUNT(*) FROM (
        	 SELECT PEOPLE.ID, PEOPLE.NAME, PEOPLE_TYPE.TYPE_NAME FROM PEOPLE JOIN PEOPLE_TYPE 
        	 ON (PEOPLE.HUM_TYPE_ID = PEOPLE_TYPE.ID)
        	 	) AS RES
        	 WHERE RES.ID IN (NEW.HUM1_ID, NEW.HUM2_ID) AND RES.TYPE_NAME IN ('перевозчик','нейтрал')
        	 HAVING COUNT(*) = 2)) THEN
        	RAISE EXCEPTION 'Battle result between neutrals can not be undefined!';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER battle_trigger
BEFORE INSERT ON BATTLES
    FOR EACH ROW EXECUTE PROCEDURE check_battle_row();

-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_people_row() RETURNS trigger AS $$
    BEGIN
    	IF ( EXISTS (SELECT ID FROM PEOPLE_TYPE WHERE ID = NEW.HUM_TYPE_ID AND TYPE_NAME = 'герой') AND
    	    EXISTS(SELECT ID FROM PEOPLE WHERE NAME = NEW.NAME) ) THEN --если герой И такое имя уже существует
    		RAISE EXCEPTION 'This hero name already exists';
    	END IF;
    	RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER people_trigger
BEFORE INSERT ON PEOPLE
	FOR EACH ROW EXECUTE PROCEDURE check_people_row();

------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION check_rel_char_row() RETURNS trigger AS $$
    BEGIN
    	IF NOT EXISTS(SELECT COUNT(*)
    				FROM PEOPLE JOIN PEOPLE_TYPE 
        	 		ON (PEOPLE.HUM_TYPE_ID = PEOPLE_TYPE.ID)
        	 		WHERE PEOPLE.ID IN (NEW.HUM1_ID, NEW.HUM2_ID) AND PEOPLE_TYPE.TYPE_NAME IN ('герой','леди')
        	 		HAVING COUNT(*) = 2) THEN
    		RAISE EXCEPTION 'relations can be only hero-hero, lady-hero or lady-lady';
    	END IF;
    	RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rel_char_trigger
BEFORE INSERT ON RELS_CHARACTERS
	FOR EACH ROW EXECUTE PROCEDURE check_rel_char_row();

-------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION check_rel_char_frac_row() RETURNS trigger AS $$
    BEGIN
    	IF NOT EXISTS (SELECT PEOPLE.ID FROM PEOPLE JOIN PEOPLE_TYPE ON (PEOPLE.HUM_TYPE_ID = PEOPLE_TYPE.ID)
    			   WHERE PEOPLE.ID = NEW.HUM_ID AND PEOPLE_TYPE.TYPE_NAME = 'герой') THEN
    		RAISE EXCEPTION 'relations can be only hero-frac';
    	END IF;
    	RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rel_char_frac_trigger
BEFORE INSERT ON RELS_CHARACTER_FRACTION
	FOR EACH ROW EXECUTE PROCEDURE check_rel_char_frac_row();

/*DO
$do$
BEGIN
IF EXISTS (SELECT RES.ID FROM (
		SELECT PEOPLE.ID, PEOPLE.NAME, PEOPLE_TYPE.TYPE_NAME FROM PEOPLE 
		JOIN PEOPLE_TYPE ON (PEOPLE.HUM_TYPE_ID = PEOPLE_TYPE.ID)
		) AS RES
WHERE RES.ID IN (17, 16) AND RES.TYPE_NAME IN ('перевозчик','нейтрал')) THEN
RAISE EXCEPTION 'BOOM';
END IF;
END
$do$*/