-- Create database dummydb as it doesn't exists

if NOT EXISTS(
select name from sys.databases where name = N'dummydb')
BEGIN
	PRINT 'Creating dummydb database';
	Create database dummydb;
END