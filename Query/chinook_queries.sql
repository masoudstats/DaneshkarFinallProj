-- 1. Top 10 songs that earned the most revenue 
select invce.TrackId, tk.Name, sum(invce.UnitPrice * Quantity) TotalPrice 
from track tk
join invoiceline invce on tk.TrackId = invce.TrackId
group by invce.TrackId
order by Totalprice desc
limit 10


-- 2. Most popular genre, in order of number of albums sold
select ge.Name, count(invce.TrackId) as CountBuy, sum(invce.UnitPrice * Quantity) as TotalPrice 
from invoiceline invce
join track tk on invce.TrackId = tk.TrackId
join genre ge on tk.GenreId = ge.GenreId
group by ge.Name
order by CountBuy desc, TotalPrice desc


-- 3. Users who have never made a purchase
select invce.CustomerId, cust.CustomerId, Total
from invoice as invce
left join customer as cust on invce.CustomerId = cust.CustomerId 
where Total = Null


-- 4. Average song time per album
select alb.Title, avg(tk.Milliseconds) / 1000 as AvgTimeSeconds
from track tk
join album alb on tk.AlbumId = alb.AlbumId
group by tk.AlbumId


-- 5. The employee who had the highest number of sales
select concat(emp.LastName, " ",emp.FirstName) FullName, count(inv.InvoiceId) CntProduct 
from employee emp
join customer cus on emp.EmployeeId = cus.SupportRepId
join invoice inv on cus.CustomerId = inv.CustomerId
group by cus.SupportRepId
order by FullName desc


-- 6. Users who shopped from more than one genre
select inv.CustomerId, count(distinct ge.GenreId) CntGenre
from invoice inv
join invoiceline invl on inv.InvoiceId = invl.InvoiceId
join track tk on invl.TrackId = tk.TrackId
join genre ge on tk.GenreId = ge.GenreId
group by inv.CustomerId
having CntGenre > 1


-- 7. Top three songs in terms of sales revenue for each genre
with cte1 as(
select ge.Name GenreName, tk.Name TrackName, (invce.UnitPrice * invce.Quantity) Price
from track tk
join invoiceline invce on tk.TrackId = invce.TrackId
join genre ge on tk.GenreId = ge.GenreId
), cte2 as (
    select GenreName, TrackName, sum(Price) TotalPrice,
	row_number() over (partition by GenreName ORDER BY sum(Price) desc) as MyRank
	from cte1
	group by GenreName, TrackName
)
select GenreName, TrackName, TotalPrice
from cte2
where MyRank <= 3  
order by  GenreName, TotalPrice desc


-- 8. The number of songs sold cumulatively in each year separately
with cte as(
select 
	InvoiceDate, 
	year(InvoiceDate) YearInvoiceDate,
	sum(Quantity) CntTrackBuy
from invoice inv
join invoiceline invl on inv.InvoiceId = invl.InvoiceId
group by InvoiceDate
)
select 
	YearInvoiceDate, 
	CntTrackBuy,
    sum(CntTrackBuy) over (partition by YearInvoiceDate order by InvoiceDate) as CumSum
from cte


-- 9. Users whose total purchases are higher than the average total purchases of all users.
with cte as(
select inv.CustomerId CustomerId, sum(Total) TotalBuy
from customer cus
join invoice inv on cus.CustomerId = inv.CustomerId
group by inv.CustomerId
)
select CustomerId, TotalBuy
from cte
where TotalBuy > (select avg(TotalBuy) from cte)
order by CustomerId



