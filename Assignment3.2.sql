/*
In order to help a friend who has a dog walking business to store her clients and jobs. To do 
I have created the following tables: clients or the names, contacts  for contact details, and dogs for the dog names and breed. 
More than one owner can have more than one dog so it is a many-to-many relationship I created a table to join dogs and owners 
called dogs_owners. There is another table called jobs that contains the dog walking jobs with the date, start, and finish of the walks.
The column time is calculated with start and finish time and shows how long the walk was. The column total shows the total price of the walk = time x £12 
*/

create database dogwalking;
use dogwalking;

CREATE TABLE contacts (contact_id int auto_increment primary key,phonenumber int ,
 house_no int , street Varchar(50), town varchar(10));
 
CREATE TABLE owners (owner_id int auto_increment primary key,
owner_fname varchar (50), owner_sname varchar(50) not null, contact_id int, foreign key (contact_id) references contacts(contact_id));


CREATE TABLE dogs (dog_id int auto_increment primary key,dog_name varchar(50) not null, dog_breed varchar(50) );

CREATE TABLE dogs_owners 
(dogs_owners_id int auto_increment primary key, owner_id int  ,foreign key (owner_id) 
REFERENCES owners(owner_id), dog_id int, foreign key (dog_id) REFERENCES dogs(dog_id));

CREATE TABLE jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    walk_date DATE not null,
    walk_start TIME not null,
    walk_finish TIME not null,
    CHECK (walk_finish>walk_start),
    job_time TIME GENERATED ALWAYS AS (TIMEDIFF(walk_finish, walk_start)),
    dogs_owners_id INT,
    FOREIGN KEY (dogs_owners_id) REFERENCES dogs_owners(dogs_owners_id),
    total INT GENERATED ALWAYS AS ((job_time) * 12/10000)
);

INSERT INTO contacts (house_no, street, town, phonenumber)
VALUES (20, "Main Street", "Bath", 1234),
       (21, "Main Street", "Bath", 1221),
       (22, "Hight Street", "Bath",null),
       (22, "Low Street", "Bath", 1222),
       (1, "Main Square", "Saltford", null),
       (20, "Main Street", "Bath", null),
       (25, "Main Street", "Bath",null),
       (24, "Hight Street", "Bath",null),
       (28, "Hight Street", "Bath",null),
       (10, "Hight Street", "Bath", null);
       
select * from contacts;

INSERT INTO owners (owner_fname, owner_sname, contact_id)
VALUES ( "John", "Smith", 1),
       ("Kate", "Smith", 1),
       ( "Robert", "Smith", 2),
       ( "Josh", "Twinkle", 4),
       ( "Suzie", "Smart", 3),
       ( "Tom", "Smart", 7),
       ( "Tom", "Knight", 8),
       ( "Peter", "Twinkle", 6),
       ( "George", "Grass", 9),
       ( "Tom", "Grass", 10),
       ( "Ann", "White", 5);
       
select * from owners;

INSERT INTO dogs (dog_name, dog_breed)
VALUES ( "Fufu", "Labrador"),
       ("Bailey", "Labrador"),
       ( "Coco","Poodle"),
       ( "Shadow", "German Shepherd"),
       ( "Prince", "German Shepherd"),
       ( "Princess", "Akita"),
       ( "Khaleesi", "Akita"),
       ( "Misty", "Akita"),
       ( "George", "Daschund"),
       ( "Bubu", "Daschund"),
       ( "Bella", "Westie"),
       ("Bella", "Visla");
       
select * from dogs;

INSERT INTO dogs_owners (owner_id, dog_id)
	VALUES (12, 1), (13, 1),(14, 2),(15, 3),(16, 4),(17, 5),(18, 6),
(19, 7),(20, 8),(21, 9),(21, 10),(21, 11), (22, 12);

select* from dogs_owners;

INSERT INTO jobs (walk_date, walk_start, walk_finish , dogs_owners_id)
VALUES 
("2023-08-01", "15:00:00", "16:00:00",53),("2023-08-01","15:00:00","16:00:00",54),("2023-08-01","15:00:00", "16:00:00",55),
("2023-08-02","15:00:00","16:00:00",56),("2023-08-02","15:00:00", "16:00:00",57),("2023-08-02","15:00:00","17:00:00",58),
("2023-08-02","15:00:00", "16:00:00",59),("2023-08-03","15:00:00", "16:00:00",60),("2023-08-03","15:00:00", "16:00:00",61),
("2023-08-03","15:00:00","16:00:00",62),("2023-08-03","15:00:00", "16:00:00",63),("2023-08-03","15:00:00", "16:00:00",64),
("2023-08-03","15:00:00","16:00:00",65);

select * from jobs;

-- I want to delete the first job as it was just a test /did not really happen or it was a mistake. 
delete from jobs where job_id=1;


-- people who has the surname Smith
select * from owners where owner_sname ="Smith";

-- people who live at the same address
SELECT o1.owner_fname, o1.owner_sname
FROM owners o1
JOIN owners o2 ON o1.contact_id = o2.contact_id
WHERE o1.owner_fname != o2.owner_fname OR o1.owner_sname != o2.owner_sname;

-- shows the address of Fufu dog
SELECT distinct house_no,street, town
FROM dogs as d
JOIN dogs_owners as dow ON d.dog_id = dow.dog_id
JOIN owners as o ON dow.owner_id = o.owner_id
JOIN contacts as c ON o.contact_id = c.contact_id
WHERE d.dog_name = "Fufu";
-- how much money did the dog walker make on a specific date 

-- the total amount of money earn on a give date
SELECT sum(total) from jobs where walk_date = '2023-08-01' ;

-- how many differnet walking job there was per date
select count(walk_date) as number_jobs, walk_date from jobs group by walk_date;

-- the maximum amount earned per job 
select max(total), job_id, walk_date from jobs group by walk_date, job_id;

-- prints out the full name of the owners 
select CONCAT(owner_fname,'  ', owner_sname) as full_name, contact_id from owners;

-- mistake correction: instead of Visla , rewrite it to Hungarian Visla for breed 
SELECT dog_name,dog_id, REPLACE(dog_breed, 'Visla', 'Hungarian_Visla') 
FROM dogs;

-- stored procedure to add a new client to the database : updates owners, dogs, contacts and dogs_owners tables. 
DELIMITER //
CREATE PROCEDURE AddNewClientWithDogsAndContacts(
    IN owner_fname VARCHAR(20),
    IN owner_sname VARCHAR(20),
    IN phonenumber INT(10),
    IN house_no INT,
	IN street VARCHAR(30),
	IN town VARCHAR(30),
    IN dog_name VARCHAR(255),
    IN dog_breed VARCHAR(255)
)
BEGIN
    DECLARE new_owner_id INT;
    DECLARE new_dog_id INT;
	DECLARE new_contact_id INT;

    -- Start a transaction
    START TRANSACTION;

    -- Insert client information
    INSERT INTO owners (owner_fname, owner_sname) VALUES (owner_fname, owner_sname);
    SET new_owner_id = LAST_INSERT_ID();

    -- Insert dog information
    INSERT INTO dogs (dog_name, dog_breed) VALUES (dog_name, dog_breed);
    SET new_dog_id = LAST_INSERT_ID();

    -- Insert contact information
   INSERT INTO contacts (house_no, street, town, phonenumber) VALUES (house_no, street, town, phonenumber);
   SET new_contact_id = LAST_INSERT_ID();

    -- Insert into dog_owners table to establish the relationship
    INSERT INTO dogs_owners (owner_id, dog_id) VALUES (new_owner_id, new_dog_id);

    -- Commit the transaction
    COMMIT;
END //
DELIMITER ;


-- Scenario: I have a new client who I want to add to the database 

CALL AddNewClientWithDogsAndContacts ('John','Blue',234,6,'Dean_str', 'Bath','Fido3','Golden_Retriever');

-- check that the prodecure worked 
select * from dogs;
select * from contacts;
select * from dogs_owners;







