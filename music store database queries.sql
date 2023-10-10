
	/* Question Set 1 - Easy */

/* 1. Who is the senior most employee based on job title? */

select first_name,last_name
from employee
order by levels desc
limit 1;

/* 2. Which countries have the most Invoices? */

select billing_country,count(invoice_id)
from invoice
group by billing_country
order by 2 desc
limit 1;

/* 3. What are top 3 values of total invoice? */

select total
from invoice
order by total desc
limit 3;

/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals. */

select billing_city,sum(total) as c
from invoice
group by billing_city
order by c desc
limit 1;

/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money. */

select c.first_name,c.last_name,sum(i.total)
from customer c
join invoice i
on c.customer_id=i.customer_id
group by c.customer_id
order by 3 desc
limit 1;

	/* Question Set 2 – Moderate */
							
/* 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A. */

select distinct(c.email),c.first_name,c.last_name,g.name as genre
from customer c
join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
join track t 
on il.track_id=t.track_id
join genre g
on t.genre_id=g.genre_id
where g.name='Rock'
order by email;

/* 2. Lets invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.name,count(t.track_id) as count
from artist a
join album alb
on a.artist_id=alb.artist_id
join track t
on alb.album_id=t.album_id
join genre g
on t.genre_id=g.genre_id
where g.name='Rock'
group by a.name
order by 2 desc
limit 10;

/* 3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select t.name,t.milliseconds
from track t
where t.milliseconds>(select avg(milliseconds)
					 from track)
order by 2 desc;

	/* Question Set 3 – Advance */
							
/* 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent. */

WITH temp AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, temp.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN temp ON temp.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

with earning_per_genre_per_country as (
	select g.genre_id,g.name,i.billing_country,sum(il.unit_price*il.quantity) as earning
	from genre g
	join track t
	on g.genre_id=t.genre_id
	join invoice_line il
	on t.track_id=il.track_id
	join invoice i
	on il.invoice_id=i.invoice_id
	group by g.genre_id,i.billing_country
)
select distinct(e.billing_country),ceil(max(e.earning)) 
from earning_per_genre_per_country e
group by e.billing_country
order by 1;

/* 3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount. */

with temp as 
(
	select c.customer_id,c.first_name,c.last_name,c.country,sum(i.total) as "total_spending",
	rank() over (partition by c.country order by sum(i.total) desc) as "rank"
	from customer c
	join invoice i
	on c.customer_id=i.customer_id
	group by 1,2,3,4
)
select *
from temp
where rank<2;

