create database music;
use music;

create table employee(
employee_id int auto_increment primary key,
last_name varchar(50),
first_name varchar(50),
title varchar(100),
reports_to int,
levels varchar(30),
birthdate varchar(50),
hire_date varchar(50),
address varchar(100),
city varchar(50),
state varchar(20),
country varchar(50),
postal_code varchar (50),
phone varchar(100) ,
fax varchar(100),
email varchar(100));

describe employee; 

update employee
set reports_to=Null
where employee_id=9;

alter table employee
add constraint fk_reports_to
foreign key (reports_to)
references employee(employee_id);

select* from employee;

create table customer(
customer_id int auto_increment primary key,
first_name varchar(50),
last_name varchar(50),
company varchar(100),
address varchar(100),
city varchar(50),
state varchar(30),
country varchar(30),
postal_code varchar(50),
phone varchar(50),
fax varchar(50),
email varchar(100),
support_rep_id int,
foreign key (support_rep_id)
references employee(employee_id));

select* from customer;

create table invoice(
invoice_id int  NOT NULL auto_increment primary key,
customer_id int,
invoice_date varchar(200),
billing_address varchar(200),
billing_city varchar(200),
billing_state varchar(200),
billing_country varchar(200),
billing_postal_code varchar(200),
total int,
foreign key(customer_id)
references customer(customer_id));

select* from invoice;

create table media_type(
media_type_id int  NOT NULL auto_increment primary key,
Name varchar(100));

select* from media_type;

create table genre(
genre_id int primary key,
name varchar(50));

select* from genre;

create table artist(
artist_id int auto_increment primary key,
name varchar(100));

select* from artist;

create table album(
album_id int auto_increment primary key,
title varchar(100),
artist_id int,
foreign key (artist_id)
references artist(artist_id)
);

select* from album;

create table track(
track_id int primary key,
name varchar(200),
album_id int,
media_type_id int,
genre_id int,
composer varchar(1000) default null,
milliseconds varchar(100),
bytes varchar(100),
unit_price varchar(100),
foreign key (album_id)
references album(album_id),
foreign key (media_type_id)
references media_type(media_type_id),
foreign key (genre_id)
references genre(genre_id)
);

select* from track;

create table invoice_lininvoice_linee(
invoice_line_id int auto_increment primary key,
invoice_id int,
track_id int,
unit_price float,
quantity int,
foreign key (invoice_id)
references invoice(invoice_id),
foreign key (track_id)
references track(track_id)
);

select* from invoice_line;

create table playlist(
playlist_id int auto_increment primary key,
name varchar(50));

select* from playlist;

create table playlist_track(
playlist_id int,
track_id int,
foreign key (playlist_id)
references playlist(playlist_id),
foreign key (track_id)
references track(track_id)
);

select* from playlist_track;


-- =================================================Easy======================================================


-- 1. Who is the senior most employee based on job title?

select max(title) as max_title,concat(first_name,' ',last_name) as employee_name from employee
where title=(select max(title) from employee)
group by employee_name
order by max_title;

-- 2. Which countries have the most Invoices?

select c.country,i.total
from customer c join invoice i
on c.customer_id=i.customer_id
where total=(select max(total) from invoice);

-- 3. What are top 3 values of total invoice?

select total from invoice limit 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

select c.city,sum(i.total) as max_total
from customer c join invoice i
on c.customer_id=i.customer_id
group by city
order by max_total desc limit 1;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money

select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,sum(il.unit_price*il.quantity) as money_spent
from customer c join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
group by customer_id
order by money_spent desc limit 1;

-- ============================================= Moderate ===============================================

-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

select distinct c.email,concat(c.first_name,' ',c.last_name) as person,g.name
from customer c join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
join track t
on il.track_id=t.track_id
join genre g
on t.genre_id=g.genre_id
where g.name='rock' and c.email like 'a%'
order by email asc;

-- 2. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select a.name,a.artist_id,count(*) as track_count
from artist a join album al
on a.artist_id=al.artist_id
join track t
on al.album_id=t.album_id
join genre g
on t.genre_id=g.genre_id
where g.name='rock'
group by a.artist_id
order by track_count desc limit 10;

-- 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name,milliseconds
from track
where milliseconds>(select avg(milliseconds)from track)
order by milliseconds desc;

-- ================================================== Advance ============================================================

-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select concat(c.first_name,' ',c.last_name) as customer_name,a.name,sum(il.unit_price*il.quantity) as total_spent
from customer c join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
join track t
on il.track_id=t.track_id
join album al
on  al.album_id=t.album_id
join artist a
on al.artist_id=a.artist_id
group by c.customer_id,a.artist_id
order by total_spent desc;

-- 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the 
-- highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres

with tb1 as(select g.name as Popular_genre,c.country,sum(il.quantity) as purchases
from customer c join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
join track t
on il.track_id=t.track_id
join genre g
on t.genre_id=g.genre_id
group by g.name,c.country
order by c.country ,purchases desc)
select country,coalesce(max(popular_genre),'unknown') as max_purchases from tb1
group by country;

-- 3. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount 
-- spent is shared, provide all customers who spent this amount

with tb2 as(select c.country,concat(c.first_name,' ',c.last_name) as customer_name,sum(il.unit_price*il.quantity) as top_spent
from customer c join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
group by c.customer_id, c.country)
select country,customer_name,top_spent from tb2
where (country,top_spent) in (select country,max(top_spent) as max_spent from tb2 group by country)
order by country;


