drop table if exists zepto;

CREATE TABLE zepto (
  cid SERIAL PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp NUMERIC(8,2),
  discountPercent NUMERIC(5,2),
  availableQuantity INTEGER,
  discountedSellingPrice NUMERIC(8,2),
  weightInGms INTEGER,
  outOfStock BOOLEAN,
  quantity INTEGER
);

--1)count rows
select count(*) as row_count from zepto;

--2)sample data
select * from zepto limit 10;

--3)get all categories available
select distinct category from zepto order by category;

--4)product instock vs out of stock
select outofstock,count(cid) from zepto group by outofstock;

SELECT
    COUNT(*) FILTER (WHERE outOfStock = FALSE) AS in_stock_count,
    COUNT(*) FILTER (WHERE outOfStock = TRUE) AS out_of_stock_count
FROM zepto;

--5)prod name present multiple times
select name,count(cid) as "Number of times" 
from zepto
group by name
having count(cid)>1
order by count(cid) desc;

--DATA CLEANING

--6)look forproducts where price might be zero
select * from zepto where mrp=0;

--deleteing the above rows as mrp cannot be zero
delete from zepto 
where mrp =0;


--7)converting paise to Rs
update zepto
set mrp = mrp/100.00,
discountedSellingPrice = discountedSellingPrice /100.00;

select mrp,discountedSellingPrice from zepto;

--8.Find the top 10 best-value products based on the discount percentage. 
select name,mrp,discountpercent
from zepto
order by discountpercent desc
limit 10;


--9.What are the Products with High MRP but Out of Stock
select distinct name ,mrp from zepto
where outofstock = true and mrp >300
order by mrp desc;

--10.Calculate Estimated Revenue for each category
select category,sum(discountedSellingPrice*availablequantity)
as total_revenue
from zepto
group by category
order by total_revenue desc;

--11. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name,mrp,discountpercent
from zepto where mrp>500 and discountpercent<10
order by mrp desc,discountpercent desc;

-- 12. Identify the top 5 categories offering the highest average discount percentage. 
select category ,
round(avg(discountpercent),2) as avg_discount
from zepto
group by category
order by avg_discount desc
limit 5;

--13. Find the price per gram for products above 100g and sort by best value. 
select distinct name,weightingms,discountedSellingPrice,
round((discountedSellingPrice/weightingms),2) as price_per_gram
from zepto where weightingms>=100
order by price_per_gram;



--14. Group the products into categories like Low, Medium, Bulk. 
select distinct name ,weightingms,
case when weightingms <1000 then 'low'
     when weightingms < 5000 then 'medium'
	 else 'bulk'
	 end as weight_category
	 from zepto;
	 
--15.What is the Total Inventory Weight Per Category
select category,sum(weightingms * availablequantity) as total_wt
from zepto
group by category
order by total_wt;

--16)Find the highest discounted products within each category
SELECT 
    category,
    name,
    discountPercent,
    RANK() OVER(
        PARTITION BY category
        ORDER BY discountPercent DESC
    ) AS discount_rank
FROM zepto;

--17)Retrieve the top 3 highest MRP products from every category.
SELECT *
FROM (
    SELECT 
        category,
        name,
        mrp,
        ROW_NUMBER() OVER(
            PARTITION BY category
            ORDER BY mrp DESC
        ) AS rn
    FROM zepto
) t
WHERE rn <= 3;

--18)Find products whose MRP is higher than the average MRP of their category.
SELECT 
    category,
    name,
    mrp,
    AVG(mrp) OVER(PARTITION BY category) AS avg_category_price
FROM zepto
WHERE mrp > (
    SELECT AVG(mrp)
    FROM zepto z2
    WHERE z2.category = zepto.category
);

--19)Find products contributing the highest possible revenue
SELECT 
    name,
    category,
    quantity,
    discountedSellingPrice,
    quantity * discountedSellingPrice AS estimated_revenue
FROM zepto
ORDER BY estimated_revenue DESC
LIMIT 10;

--20)Calculate how much each category contributes to total inventory value.
SELECT 
    category,

    SUM(quantity * discountedSellingPrice) AS category_value,

    ROUND(
        100.0 * SUM(quantity * discountedSellingPrice)
        / SUM(SUM(quantity * discountedSellingPrice)) OVER(),
        2
    ) AS contribution_percentage
FROM zepto
GROUP BY category
ORDER BY contribution_percentage DESC;

--21)duplicate prod names
SELECT 
    name,
    COUNT(*) AS duplicate_count
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1;

--22
SELECT 
    name,
    category,
    discountPercent,

    CASE
        WHEN discountPercent >= 50 THEN 'Heavy Discount'
        WHEN discountPercent >= 20 THEN 'Moderate Discount'
        ELSE 'Low Discount'
    END AS discount_strategy
FROM zepto;

--23)Segment products into quartiles based on MRP.
SELECT 
    name,
    category,
    mrp,

    NTILE(4) OVER(ORDER BY mrp DESC) AS price_bucket
FROM zepto;

--24)
SELECT 
    name,
    category,
    mrp,

    CASE 
        WHEN price_bucket = 1 THEN 'Premium'
        WHEN price_bucket = 2 THEN 'High'
        WHEN price_bucket = 3 THEN 'Medium'
        WHEN price_bucket = 4 THEN 'Budget'
    END AS product_segment

FROM (
    SELECT 
        name,
        category,
        mrp,

        NTILE(4) OVER(ORDER BY mrp DESC) AS price_bucket
    FROM zepto
) t;