# 1. Database Creation  
create database music_store;

use music_store;
# 2. Table Creation.
CREATE TABLE Employee ( 
 employee_id INT PRIMARY KEY, 
 last_name VARCHAR(120), 
 first_name VARCHAR(120), 
 title VARCHAR(120), 
 reports_to INT, 
 levels VARCHAR(255), 
 birthdate varchar(225), 
 hire_date varchar(225), 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100) 
);

create table customer(
customer_id int primary key,
first_name varchar(150),
last_name varchar(150),
company varchar(150),
address varchar(150),
city varchar(60),
state varchar(60),
country varchar(50),
postal_code varchar(50),
phone varchar(50),
fax varchar(50),
email varchar(60),
support_req_id int,
foreign key(support_req_id) references Employee(employee_id)
);

create table invoice(
invoice_id int primary key,
customer_id int,
foreign key (customer_id) references customer(customer_id),
invoice_date date,
billing_address varchar(255),
billing_city varchar(100),
billing_state varchar(100),
billing_country varchar(100),
billing_postal_code varchar(60),
total decimal(10,2)
);

#execution is remaning
# this table having reference of 2 tables
create table invoice_line(
invoice_line_id int primary key,
invoice_id int,
foreign key (invoice_id) references invoice(invoice_id),
track_id int,
foreign key (track_id) references track(track_id),
unit_price decimal(10,2),
quantity int
);

create table track(
track_id int primary key,
name varchar(220),
album_id int,
foreign key (album_id) references album(album_id),
media_type_id int,
foreign key (media_type_id) references media_type(media_type_id),
genre_id int,
foreign key (genre_id) references genre(genre_id),
composer varchar(225),
milliseconds int,
bytes int,
unit_price decimal(10,2)
);

# media_type and genre are referened to the track
create table media_type(
media_type_id int primary key,
name varchar(120)
);

create table genre(
genre_id int primary key,
name varchar(120)
);


create table album(
album_id int primary key,
title varchar(160),
artist_id int,
foreign key (artist_id) references artist(artist_id)
);

create table artist(
artist_id int primary key,
name varchar(120)
);

create table playlist(
playlist_id int primary key,
name varchar(255)
);

create table playlist_track(
playlist_id int ,
track_id int,
primary key (playlist_id ,track_id),
foreign key (playlist_id) references playlist(playlist_id),
foreign key (track_id) references track(track_id)
);




select * from customer;
-- sequence of table execution :
-- 1. Genre and MediaType
-- 2. Employee 
-- 3. Customer 
-- 4. Artist 
-- 5. Album
-- 6. Track
-- 7. Invoice 
-- 8. InvoiceLine
-- 9. Playlist
-- 10. PlaylistTrack 


#3. Data Import 
/*Recommended Data Import Order:
To avoid foreign key errors and maintain referential integrity, import data in the following sequence:
1. Genre
2. MediaType
3. Employee
4 . Customer
Artist
Album
Track ← Use LOAD DATA INFILE for this
Invoice
InvoiceLine
Playlist
PlaylistTrack*/

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
# "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\track.csv"
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);
-- limit length (optional)


select * from genre;
select  * from media_type;
select * from employee;
select * from customer;
select * from artist;
select * from album;
select * from track;
select * from invoice;
select * from Invoice_Line;
select * from playlist;
select * from Playlist_Track;

# 1. Who is the senior most employee based on job title? 
select * from employee;

select * from employee
order by levels desc
limit 1 ;

select * from employee
where title like 'Senior%';


# 2. Which countries have the most Invoices?
select billing_country , count(*) as total_invoices from invoice
group by billing_country
order by total_invoices desc
limit 1;

# 3. What are the top 3 values of total invoice? 
select total from invoice 
order by total desc
limit 3;

-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in 
-- the city we made the most money. Write a query that returns one city that has the highest sum of 
-- invoice totals. Return both the city name & sum of all invoice totals 
select * from invoice;

select sum(total) as invoice_total ,billing_city from invoice
group by billing_city
order by invoice_total desc;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared 
-- the best customer. Write a query that returns the person who has spent the most money 

-- note here we join 2 tables cutomer and invoice by using [coustore_id] because all the sales data is in invoice table.
select * from Customer;
select * from invoice;

select customer.customer_id , customer.first_name , customer.last_name , sum(invoice.total) as total
from customer 
join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

-- moderate level 
-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A 
select * from genre;
select * from track;
select * from customer;
select * from invoice;
select * from invoice_line;

select distinct email ,first_name ,last_name 
from customer
join invoice 
on customer.customer_id = invoice.customer_id
join invoice_line
on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
    where genre.name = "Rock"
)
order by email;

-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that 
-- returns the Artist name and total track count of the top 10 rock bands  
select * from track;
select * from album;
select * from artist;
select * from genre;

select artist.artist_id ,artist.name , count(artist.artist_id) as total_track
from track
join
album on album.album_id = track.album_id
join
artist on artist.artist_id = album.artist_id
join
genre on genre.genre_id = track.genre_id
where genre.name like "Rock"
group by artist.artist_id
order by total_track desc
limit 10;
# there are tha emusic bands thoes play there music most of the time




-- 8. Return all the track names that have a song length longer than the average song length.- 
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest 
-- songs listed first 
select * from track;

select name,milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_len from track)
order by milliseconds desc;
# it gives the more then avg track len values


-- Advance
-- 9. Find how much amount is spent by each customer on artists? Write a query to return 
-- customer name, artist name and total spent 
-- cutomer name = cutomer table
-- artist name = artist table
-- total spend = involve table
-- invoice_line = [use to find total invoice] to get accurate total spent amount we also (multiply unitPrice and quantity) 
 select * from customer;
 select * from artist;
 select * from invoice_line; # total_price { unite_price ex[track price =1000 ,track_quantity = 3 ] }
 select * from invoice; # note[do not use total from invoice bec there values are different from total_price]
# for temporary table
# common table expression is for getting total_sales
with best_selling_artist as(
	select artist.artist_id as artist_id, artist.name as artist_name, 
    sum(invoice_line.unit_price*invoice_line.quantity) as total_sales from invoice_line
    join
    track on track.track_id = invoice_line.track_id
    join
    album on album.album_id = track.album_id
    join
    artist on artist.artist_id = album.artist_id
    group by 1
    order by 3 desc
    limit 1
    )
   select c.customer_id, c.first_name , c.last_name,  bsa.artist_name,
   sum(inv_line.unit_price * inv_line.quantity) as amount_spent from invoice 
   join
   customer as c on c.customer_id = invoice.customer_id
   join
   invoice_line as inv_line on inv_line.invoice_id = invoice.invoice_id
   join
   track as t on t.track_id = inv_line.track_id
   join
   album as alb on alb.album_id = t.album_id
   join
   best_selling_artist as bsa on bsa.artist_id = alb.artist_id
   group by 1,2,3,4
   order by 5 desc;
    
-- note: based on artist_id we group and set group by 1 because we want to get only one artist name
-- note: order by total_sales 


-- 10. We want to find out the most popular music Genre for each country. We determine the most 
-- popular genre as the genre with the highest amount of purchases. Write a query that returns 
-- each country along with the top Genre. For countries where the maximum number of purchases 
-- is shared, return all Genres
with popular_genre as(
select count(invoice_line.quantity) as purchases, customer.country , genre.name, genre.genre_id,
row_number() over (partition by customer.country order by count(invoice_line.quantity)desc) as RowNo
from invoice_line
join 
invoice on invoice.invoice_id = invoice_line.invoice_id
join
customer on customer.customer_id = invoice.customer_id
join
track on track.track_id = invoice_line.track_id
join
genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc , 1 desc
)
select * from popular_genre where RowNo <=1;

 -- note : row_number() : for getting the singe highest value by using categories
 
-- 11. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how much they 
-- spent. For countries where the top amount spent is shared, provide all customers who spent this 
-- amount

with customer_with_country as(
 select customer.customer_id , first_name ,last_name, billing_country,sum(total) as total_spending,
 row_number() over (partition by billing_country  order by sum(total)desc) as RowNo
 from invoice
 join
 customer on customer.customer_id = invoice.customer_id
 group by 1,2,3,4
 order by 4 asc , 5 desc)
 select * from customer_with_country where rowno<=1;