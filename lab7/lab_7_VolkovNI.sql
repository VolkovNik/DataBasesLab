use lab
go
-- для задания 2 написать в комментарии селект
-- создать уникальный кластеризованный индекс для одного из представления

IF DB_ID (N'lab7') IS NOT NULL
	DROP DATABASE lab7;
GO

CREATE DATABASE lab7
	ON (NAME = lab7_dat, FILENAME = 
		'D:\data\lab7dat.mdf',
		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5 %)
	LOG ON (NAME = lab7_log, FILENAME = 
		'D:\data\lab7log.ldf',
		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB);
GO

use lab7
go

-- task 1

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

if OBJECT_ID(N'users_view') is not null
	drop view users_view;
go

create view users_view as
	select user_id, name
	from users 
	where age > 25
	with check option
go

select * from users_view
go

-- task 2

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

if object_id (N'vacancy') is not null
	drop table vacancy;
go

create table vacancy(
	vacancy_id			int identity(1,1) primary key not null,
	vacancy_name		varchar(64)					  not null,
	date_of_creation	date default(getdate())		  not null,
	requirment			text						  not null,
	salary				int							  null,
	company_id			int							  null
		constraint fk_company_id foreign key(company_id) references work(company_id) on delete cascade
)
go

insert into work (company_name, date_of_creation, location)
	values
	('valve', '1996-08-24', 'USA')

insert into vacancy (vacancy_name, requirment, company_id) 
	values
	('tester', 'work in this sphere for 3 years', IDENT_CURRENT('work'))

insert into vacancy (vacancy_name, requirment, company_id) 
	values
	('designer', 'knowledge of photoshop', IDENT_CURRENT('work'))

insert into work (company_name, date_of_creation, location)
	values
	('apple', '1976-04-01', 'USA')

insert into vacancy (vacancy_name, requirment, company_id) 
	values
	('programmer', 'knowledge of c++', IDENT_CURRENT('work'))


if OBJECT_ID(N'work_vacancy_view') is not null
	drop view work_vacancy_view;
go

create view work_vacancy_view as
	select 
		w.company_name as company,
		v.vacancy_name as vacancy,
		v.requirment as requirment
	from vacancy v
	inner join work w
		on v.company_id = w.company_id
	with check option
go

select * from work_vacancy_view where company = 'valve'

-- task 3

if EXISTS (select name from sys.indexes 
			where name = N'idx_users_age')
	drop index idx_users_age on users;
go

create index idx_users_age
	on users (name)
	include (age);
go

-- task 4

if OBJECT_ID(N'users_idx_view_surname') is not null
	drop view users_idx_view_surname;
go

create view users_idx_view_surname
	with SCHEMABINDING as 
	select user_id, surname
	from  dbo.users
go

if EXISTS (select name from sys.indexes 
			where name = N'idx_users_view')
	drop index idx_users_view on users;
go

create UNIQUE CLUSTERED index idx_users_view
	on users_idx_view_surname(user_id, surname)
go
