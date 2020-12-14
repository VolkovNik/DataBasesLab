use master
go

IF DB_ID ('lab8') IS NOT NULL
	DROP DATABASE lab8;
GO

CREATE DATABASE lab8
	ON (NAME = lab8_dat, FILENAME = 
		'D:\labs-data\lab8dat.mdf',
		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5 %)
	LOG ON (NAME = lab8_log, FILENAME = 
		'D:\labs-data\lab8log.ldf',
		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB);
GO

use lab8
go

IF OBJECT_ID ('users') IS NOT NULL
	DROP TABLE users;
GO

create table users (
	user_id				int identity(1,1)	not null primary key,
	name				varchar(50)			not null,
	surname				varchar(50)			not null,
	country				varchar(50)			not null,
	passport_id			char(10)			not null unique,
	date_of_creation	date				not null
		constraint default_date default (getdate()),
	date_of_birthday	date			not null
)
go

insert into users(name, surname, passport_id, country, date_of_birthday)
	values
	('nikita', 'volkov', '9222345678', 'Russia', '2000-07-17'),
	('maksim', 'fish', '1234567895', 'France', '1998-05-06'),
	('arseniy', 'volkov', '2345623457', 'Russia', '2010-09-01'),
	('yura', 'kozlov', '9876543232', 'Russia', '2004-01-01'),
	('yaroslav', 'petrov', '9222111333', 'China', '1986-09-24'),
	('ivan', 'ivanov', '9222111111', 'USA', '2001-11-11')
go

select * from users
go

/*
 * Пункт 1
 * Создать хранимую процедуру, производящую выборку
 * из некоторой таблицы и возвращающую результат
 * выборки в виде курсора.
 */

 if OBJECT_ID ('get_users', 'P') is not null
	drop procedure get_users
go

create procedure get_users
	@cur_cursor cursor varying output
as
	set @cur_cursor = cursor
	forward_only static for 
	select * from users
	open @cur_cursor
go

declare @my_cursor cursor
exec get_users @cur_cursor = @my_cursor output;
fetch next from @my_cursor;
while (@@FETCH_STATUS = 0)
	begin;
		fetch next from @my_cursor;
	end;
close @my_cursor
deallocate @my_cursor
go

/*
 * Пункт 2
 * Модифицировать хранимую процедуру п.1. таким
 * образом, чтобы выборка осуществлялась с
 * формированием столбца, значение которого
 * формируется пользовательской функцией.
 */
 
 create function calculate_age (@birthday date)
	returns int
	as
	begin
	declare @age int
	if (cast(getdate() as date) < @birthday)
	return -1
	select @age = year(getdate()) - year(@birthday) +
		case when dateadd(year, year(getdate()) - year(@birthday), @birthday) < cast(getdate() as date) then 0 else -1 end
    return @age
   end
go

alter procedure get_users
	@cur_cursor cursor varying output
as
	set @cur_cursor = cursor
	forward_only static for 
	select name, surname, country, passport_id, date_of_creation, dbo.calculate_age(date_of_birthday)
		as age from users
	open @cur_cursor
go

declare @my_cursor cursor
exec get_users @cur_cursor = @my_cursor output;
fetch next from @my_cursor;
while (@@FETCH_STATUS = 0)
	begin;
		fetch next from @my_cursor;
	end;
close @my_cursor
deallocate @my_cursor
go

/*
 * Пункт 3
 * Создать хранимую процедуру, вызывающую процедуру
 * п.1., осуществляющую прокрутку возвращаемого
 * курсора и выводящую сообщения, сформированные из
 * записей при выполнении условия, заданного еще одной
 * пользовательской функцией.
 */

 create function check_for_adult (@age int)
	returns int
	as
	begin
	declare @flag int
	if (@age >= 18)
		set @flag = 1
	else
		set @flag = 0
	return @flag
	end
go

 if OBJECT_ID ('print_adult_users', 'P') is not null
	drop procedure print_adult_users
go

create procedure print_adult_users as
	declare @name varchar(50)
	declare @surname varchar(50)
	declare @country varchar(50)
	declare @passport_id char(10)
	declare @date_of_creation date
	declare @age int
	declare @my_cursor cursor
	exec get_users @cur_cursor = @my_cursor output;

	fetch next from @my_cursor into @name, @surname, @country, @passport_id, @date_of_creation, @age
	while (@@FETCH_STATUS = 0)
		begin;
			if (dbo.check_for_adult(@age) = 1)
				select @name as name, @surname as surname, @country as country, @passport_id as passport_id,
					@date_of_creation as date_of_creation, @age as age;
			fetch next from @my_cursor into @name, @surname, @country, @passport_id, @date_of_creation, @age
		end;
	close @my_cursor
	deallocate @my_cursor
go

exec print_adult_users
go

/*
 * Пункт 4
 * Модифицировать хранимую процедуру п.2. таким
 * образом, чтобы выборка формировалась с помощью
 * табличной функции.
 */

 create function table_func_inline()
	returns table
	as
	return
	(
		select 	name, surname, country, passport_id, date_of_creation, date_of_birthday
		from users
	)
go

alter procedure get_users
	@cur_cursor cursor varying output
as
	set @cur_cursor = cursor
	forward_only static for 
	select name, surname, country, passport_id, date_of_creation, dbo.calculate_age(date_of_birthday)
		as age from table_func_inline()
	open @cur_cursor
go

declare @my_cursor cursor
exec get_users @cur_cursor = @my_cursor output;
fetch next from @my_cursor;
while (@@FETCH_STATUS = 0)
	begin;
		fetch next from @my_cursor;
	end;
close @my_cursor
deallocate @my_cursor
go

create function table_func()
	returns @new_table table (
		name				varchar(50)			not null,
		surname				varchar(50)			not null,
		country				varchar(50)			not null,
		passport_id			char(10)			not null unique,
		date_of_creation	date				not null,
		date_of_birthday	date				not null
	)
	as
	begin
		insert @new_table
		select 	name, surname, country, passport_id, date_of_creation, date_of_birthday
		from users
		return
	end 
go

alter procedure get_users
	@cur_cursor cursor varying output
as
	set @cur_cursor = cursor
	forward_only static for 
	select name, surname, country, passport_id, date_of_creation, dbo.calculate_age(date_of_birthday)
		as age from table_func()
	open @cur_cursor
go

declare @my_cursor cursor
exec get_users @cur_cursor = @my_cursor output;
fetch next from @my_cursor;
while (@@FETCH_STATUS = 0)
	begin;
		fetch next from @my_cursor;
	end;
close @my_cursor
deallocate @my_cursor
go