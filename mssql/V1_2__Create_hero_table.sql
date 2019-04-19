-- CREATE HERO TABLE

USE Test;

CREATE TABLE dbo.hero
(
    id int NOT NULL identity,
    name VARCHAR(250) NOT NULL,
    description varchar(2000) NOT NULL,
    debut_year INT NOT NULL,
    appearances INT NOT NULL,
    special_powers INT NOT NULL,
    cunning INT NOT NULL,
    strength INT NOT NULL,
    technology INT NOT NULL,
    created_at datetime NOT NULL,
    updated_at datetime NOT NULL
);
ALTER TABLE dbo.hero
ADD CONSTRAINT pk_hero_id PRIMARY KEY (id);
