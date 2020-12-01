use lab
GO
IF DB_ID (N'lab6') IS NOT NULL
	DROP DATABASE lab6;
GO

CREATE DATABASE lab6
	ON (NAME = lab6_dat, FILENAME = 
		'D:\data\lab6dat.mdf',
		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5 %)
	LOG ON (NAME = lab6_log, FILENAME = 
		'D:\data\lab6log.ldf',
		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB);
GO

use lab6
go

-- задание 1 и 2

IF OBJECT_ID (N'users') IS NOT NULL
	DROP TABLE users;
GO

create table users (
	user_id			 int identity(1,1)	not null,
	name			 varchar(50)		not null,
	surname			 varchar(50)		not null,
	passport_id		 char(10)			not null,
	date_of_creation date				not null
		constraint default_date default (getdate()),
	age				 int				not null
		constraint check_age check (age >= 18)
)
go

insert into users(name, surname, passport_id, age)
	values
	('nikita', 'volkov', '9222345678', 20),
	('ivan', 'ivanov', '9222111111', 30)
go

select * from users
go


/*
 * IDENT_CURRENT возвращает последнее значение идентифицирующего столбца, 
 * созданное для конкретной таблицы в любом сеансе и области поиска.
 * @@IDENTITY возвращает последнее значение идентификатора, созданное для любой таблицы в текущем сеансе по всем областям.
 * SCOPE_IDENTITY возвращает последнее значение идентификатора, созданное для любой таблицы в текущем сеансе по текущей области поиска
 */

SELECT IDENT_CURRENT('users') as 'ident_current'

SELECT @@IDENTITY as '@@identity'

SELECT SCOPE_IDENTITY() as 'scope_identity'
go

-- заданиие 3

if object_id (N'book') is not null
	drop table book;
go

create table book (
	book_id				uniqueidentifier default newid()	not null,
	name				varchar(255)						not null,
	author				varchar(255)						not null,
	description			text								null,
	publication_date	date								not null
);
go

insert into book(name, author, publication_date)
	values 
	('The Little Prince', 'Antoine de Saint-Exupery', '1943-04-01')
go

select * from book
go

insert into book(book_id, name, author, publication_date)
	values
	(newid(), 'Needful Things', 'Steven King', '1991-10-01')
go

select * from book
go

-- задание 4

if object_id (N'game') is not null
	drop table game;
go

create table game(
	game_id		int primary key	not null,
	name		varchar(50)		not null,
	platform	varchar(50)		not null,
	cost		int				null
)
go

create sequence count_by_one
	as int
	start with 1
	increment by 1
go 

insert into game (game_id, name, platform)
	values
	(next value for count_by_one, 'portal2', 'pc'),
	(next value for count_by_one, 'uncharted', 'ps3')
go

select * from game
go

-- задание 5

if object_id (N'work') is not null
	drop table work;
go

create table work(
	company_id		 int identity(1,1) primary key  not null,
	company_name	 varchar(32)					not null,
	date_of_creation date							null,
	location		 varchar(100)					not null,
	description		 text							null
)
go

insert into work (company_name, date_of_creation, location)
	values
	('valve', '1996-08-24', 'USA'),
	('apple', '1976-04-01', 'USA'),
	('ubisoft', '1986-01-01', 'France'),
	('sibur', '1995-01-01', 'Russia'),
	('alibaba group', '1999-04-04', 'China')
go

if object_id (N'vacancy') is not null
	drop table vacancy;
go

create table vacancy(
	vacancy_id			int identity(1,1) primary key not null,
	vacancy_name		varchar(64)					  not null,
	date_of_creation	date default(getdate())		  not null,
	requirment			text						  not null,
	salary				int							  null,
	work_id				int							  null
		constraint fk_work_id foreign key(work_id) references work(company_id) on delete cascade
)

insert into vacancy (vacancy_name, requirment, work_id) 
	values
	('tester', 'work in this sphere for 3 years', 1),
	('programmer', 'knowledge of c++', 2),
	('programmer', 'knowledge of java', 3),
	('engineer', 'higher technical education', 4),
	('designer', 'knowledge of revit', 5)

select * from work

select * from vacancy 
go

-- test cascade

delete from work 
	where company_name = 'valve'

select * from work

select * from vacancy 
go

-- test set null

alter table vacancy
	drop constraint fk_work_id

alter table vacancy
	add constraint fk_work_id foreign key(work_id) references work(company_id) on delete set null

delete from work 
	where company_name = 'apple'

select * from work

select * from vacancy 
go

-- test set default

alter table vacancy
	drop constraint fk_work_id

-- если не задано значение по умолчанию, то значение становится равным NULL
alter table vacancy
	add constraint fk_work_id foreign key(work_id) references work(company_id) on delete set default

delete from work 
	where company_name = 'ubisoft'

select * from work

select * from vacancy 
go

-- no action (формирует ошибку, и выполняется откат операции удаления строки из родительской таблицы)
/*
alter table vacancy
	drop constraint fk_work_id

alter table vacancy
	add constraint fk_work_id foreign key(work_id) references work(company_id) on delete no action

delete from work 
	where company_name = 'sibur'

select * from work

select * from vacancy 
go
*/