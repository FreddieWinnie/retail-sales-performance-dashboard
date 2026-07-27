/*============================================================

Project:
Retail Sales Business Intelligence Case Study

Author:
Namuwaya Winfred

Tools:
MySQL 8.0

Dataset:
Superstore Sales Dataset (2014-2017)

Description:
This project analyzes retail sales performance using SQL to
generate executive-level business insights across customers,
products, regions, discounts, shipping, categories and
time-based trends.

============================================================*/

-- SECTION 1: Executive KPIs
/*=========================================================
Business Question:
What is the company's overall business performance?

Business Objective:
Provide executives with a high-level summary of sales,
profitability, customers, orders and product demand.

Business Insight:
This query calculates the organization's key performance
indicators (KPIs), providing an overview of overall
financial performance.

Business Value:
These KPIs serve as the foundation for executive reporting
and performance monitoring.

Recommendation:
Monitor these KPIs regularly and compare them with previous
periods to evaluate business growth and profitability.
=========================================================*/
SELECT 
      ROUND(SUM(sales),2) AS total_sales,
	  ROUND(SUM(profit),2) AS total_profit,
	  ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin,
      SUM(quantity) AS total_quantity,
      COUNT(DISTINCT order_id) AS total_orders,
      COUNT(DISTINCT customer_id) AS total_customers
FROM orders;

-- SECTION 2: Geographical Performance Analysis
/*=========================================================
Business Question:
Which regions generate the highest sales and profits?

Business Objective:
Evaluate regional performance and identify strong and weak
markets.

Business Insight:
Regions differ in both revenue generation and profitability.
High sales do not always translate into high profit margins.

Business Value:
Helps management prioritize investment, marketing efforts
and pricing strategies by region.

Recommendation:
Maintain successful strategies in high-performing regions
while reviewing pricing and cost structures in lower-
performing regions.
=========================================================*/
SELECT 
      region,
      ROUND(SUM(sales),2) AS total_sales,
	  ROUND(SUM(profit),2) AS total_profit,
	  ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY region
ORDER BY SUM(sales) DESC;

-- 2.1 Best performing region by sales
WITH  regional_summary AS
(
SELECT
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY region
),
regional_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM regional_summary
)
SELECT *
FROM regional_ranking
WHERE sales_rank =1;

-- 2.2 Best performing region by profits
WITH  regional_summary AS
(
SELECT
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY region
),
regional_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit DESC) AS profit_rank
FROM regional_summary
)
SELECT *
FROM regional_ranking
WHERE profit_rank =1;

-- 2.3 Best performing region by profit_margin
WITH  regional_summary AS
(
SELECT
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY region
),
regional_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS margin_rank
FROM regional_summary
)
SELECT *
FROM regional_ranking
WHERE margin_rank =1;

-- 2.4 Top 10 States by Sales
WITH  regional_summary AS
(
SELECT state,
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY state, region
),
state_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM regional_summary
)
SELECT *
FROM state_ranking
WHERE sales_rank <=10;

-- 2.5 Top 10 States by profit
WITH  regional_summary AS
(
SELECT state,
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY state, region
),
state_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit DESC) AS profit_rank
FROM regional_summary
)
SELECT *
FROM state_ranking
WHERE profit_rank <=10;

-- 2.6 States Losing Money
SELECT state,
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY state, region
HAVING SUM(profit) < 0
ORDER BY SUM(sales) DESC;

-- SECTION 3: Customer Analysis
/*=========================================================
Business Question:
Who are the company's most valuable customers?

Business Objective:
Identify customers that generate the highest revenue,
highest profit and strongest profit margins.

Business Insight:
Customer profitability varies considerably. Some customers
generate substantial sales but relatively low profits,
indicating possible pricing or discount issues.

Business Value:
Supports customer segmentation, loyalty programs and
account management decisions.

Recommendation:
Retain highly profitable customers while reviewing pricing,
discounts and product mix for customers with high sales but
low profitability.
=========================================================*/
-- 3.1 Top 10 Customers by Sales
WITH customer_summary AS
(
SELECT 
      customer_name,
      ROUND(SUM(sales),2) AS total_sales,
      ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY customer_name
),
sales_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) sales_rank
FROM customer_summary 
) 
SELECT *
FROM sales_ranking
WHERE sales_rank <= 10;

-- 3.2 Top 10 Customers by Profit
WITH customer_summary AS
(
SELECT 
      customer_name,
      ROUND(SUM(sales),2) AS total_sales,
      ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY customer_name
),
profit_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit DESC) profit_rank
FROM customer_summary
) 
SELECT *
FROM profit_ranking
WHERE profit_rank <= 10;

-- 3.3 Customers with High Sales but Low Profit
WITH customer_summary AS
(
SELECT 
      customer_name,
      ROUND(SUM(sales),2) AS total_sales,
      ROUND(SUM(profit),2) AS total_profit,
      ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY customer_name
)
SELECT *
FROM customer_summary
WHERE total_sales>10000 AND profit_margin < 10
ORDER BY total_sales DESC;

-- 3.4 Customers Receiving High Discounts
WITH customer_summary AS
(
SELECT 
      customer_name,
      ROUND(AVG(discount)*100,2) AS average_discount,
      ROUND(SUM(sales),2) AS total_sales,
      ROUND(SUM(profit),2) AS total_profit,
      ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY customer_name
),
customer_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY average_discount DESC) AS discount_rank
FROM customer_summary
)
SELECT * 
FROM customer_ranking
WHERE discount_rank <=10;

-- SECTION 4: Product Perfomance Analysis
/*=========================================================
Business Question:
Which products contribute most to business performance?

Business Objective:
Evaluate product performance using sales, profit and
profitability.

Business Insight:
Some products generate high revenue but weak profit margins,
while others generate lower sales but excellent
profitability.

Business Value:
Supports inventory planning, pricing strategies and product
portfolio optimization.

Recommendation:
Expand investment in highly profitable products and review
pricing, supplier costs and discount strategies for
products with low profitability.
=========================================================*/
-- 4.1 Top 10 Products by Sales
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
),
ranked_sales AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM product_summary
) 
SELECT *
FROM
ranked_sales
WHERE sales_rank <= 10;

-- 4.2 Top 10 Products by Profit
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
),
ranked_profit AS
(
SELECT *,
       DENSE_RANK() OVER( ORDER BY total_profit DESC) AS profit_rank
FROM product_summary
) 
SELECT *
FROM ranked_profit
WHERE profit_rank <=10;

-- 4.3 Top 10 Products by Profit Margin
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
HAVING total_sales >5000
),
ranked_margin AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS margin_rank
FROM product_summary
)
SELECT *
FROM ranked_margin
WHERE margin_rank <= 10;

-- 4.4 High Revenue, High Margin Products
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
)
SELECT *
FROM product_summary
WHERE total_sales >5000 AND profit_margin>=10
ORDER BY profit_margin DESC;

-- 4.5 High Revenue, Low Margin Products
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
)
SELECT *
FROM product_summary
WHERE total_sales>5000 AND profit_margin <10
ORDER BY  total_sales DESC;

-- 4.6 Loss-Making Products
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
)
SELECT *
FROM product_summary 
WHERE total_profit < 0
ORDER BY total_sales DESC, profit_margin;

-- 4.7 Top Products Within Each Category by Sales
WITH  product_summary AS
(
SELECT product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category
),
product_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY category ORDER BY total_sales DESC) AS sales_rank
FROM product_summary
)
SELECT *
FROM product_ranking
WHERE sales_rank <=10;

-- 4.8 Top Products Within Each region by Sales
WITH  product_summary AS
(
SELECT product_name,
       category,
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_name, category,region
),
regional_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY region ORDER BY total_sales DESC) AS sales_rank
FROM product_summary
)
SELECT *
FROM regional_ranking
WHERE sales_rank <=10;


-- Section 5: Category Performance Analysis
/*=========================================================
Business Question:
How do product categories contribute to company
performance?

Business Objective:
Compare categories based on sales, profits, efficiency and
their contribution to total business revenue.

Business Insight:
Categories differ in revenue contribution and profitability.
High revenue categories are not always the most efficient.

Business Value:
Helps management determine which categories deserve
additional investment and which require operational review.

Recommendation:
Increase focus on highly profitable categories while
reviewing pricing and discount strategies for categories
with weak margins.
=========================================================*/
-- 5.1 Category Ranking by Revenue
WITH category_summary AS
(
SELECT category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY category
),
revenue_rank AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM category_summary
)
SELECT *
FROM revenue_rank;

-- 5.2 Category Ranking by Profit
WITH category_summary AS
(
SELECT category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY category
),
profit_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit DESC) AS profit_rank
FROM category_summary
)
SELECT *
FROM profit_ranking;

-- 5.3 Category Efficiency
WITH category_summary AS
(
SELECT category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY category
),
margin_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS margin_rank
FROM category_summary
)
SELECT *
FROM margin_ranking;

-- 5.4 Category Contribution to Sales
WITH category_summary AS
(
SELECT category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY category
),
contribution AS
(
SELECT category,
       total_sales,
       total_profit,
       ROUND(total_sales/
       SUM(total_sales) OVER()*100,2) AS category_contribution_percent
FROM category_summary
)
SELECT *
FROM contribution
ORDER BY category_contribution_percent DESC;

-- 5.5 Category Contribution to Profits
WITH category_summary AS
(
SELECT category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY category
),
profit_contribution AS
(
SELECT category,
       total_sales,
       total_profit,
       ROUND(total_profit/
       SUM(total_profit) OVER()*100,2) AS profit_contribution_percent
FROM category_summary
)
SELECT *
FROM profit_contribution
ORDER BY profit_contribution_percent DESC;


-- Section 6: Discount Analysis
/*=========================================================
Business Question:
How do discounts affect sales and profitability?

Business Objective:
Evaluate the effectiveness of the company's pricing and
discount strategies.

Business Insight:
Higher discounts generally increase sales volume but reduce
profitability. Medium and high discounts may even generate
financial losses.

Business Value:
Supports data-driven pricing decisions and promotional
planning.

Recommendation:
Limit excessive discounting and prioritize pricing
strategies that maximize long-term profitability rather
than short-term sales growth.
=========================================================*/
-- 6.1 Which discount group generates the highest sales?
WITH  discount_summary AS
(
SELECT 
	CASE
    WHEN discount = 0 THEN 'No discount'
    WHEN discount <= 0.2 THEN 'Low (1-20%)'
    WHEN discount <= 0.4 THEN 'Medium (21-40%)'
    ELSE 'High discount'
END AS discount_groups,
    ROUND(AVG(discount)*100,2) AS average_discount,
	ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY discount_groups
),
discount_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales Desc) AS sales_rank
FROM discount_summary
)
SELECT * from discount_ranking
WHERE sales_rank =1;

-- 6.2 Which discount group generates the highest profits?
WITH  discount_summary AS
(
SELECT 
	CASE
    WHEN discount = 0 THEN 'No discount'
    WHEN discount <= 0.2 THEN 'Low (1-20%)'
    WHEN discount <= 0.4 THEN 'Medium (21-40%)'
    ELSE 'High discount'
END AS discount_groups,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY discount_groups
),
discount_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit Desc) AS profit_rank
FROM discount_summary
)
SELECT * from discount_ranking
WHERE profit_rank =1;

-- 6.3 Which categories are most affected by discounts?
WITH  discount_summary AS
(
SELECT category,
	CASE
    WHEN discount = 0 THEN 'No discount'
    WHEN discount <= 0.2 THEN 'Low (1-20%)'
    WHEN discount <= 0.4 THEN 'Medium (21-40%)'
    ELSE 'High discount'
END AS discount_groups,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY category,discount_groups
),
discount_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin ASC) AS margin_rank
FROM discount_summary
)
SELECT * from discount_ranking;

-- 6.4 Which customer segments lose the most money from discounts?
WITH  discount_summary AS
(
SELECT segment,
	CASE
    WHEN discount = 0 THEN 'No discount'
    WHEN discount <= 0.2 THEN 'Low (1-20%)'
    WHEN discount <= 0.4 THEN 'Medium (21-40%)'
    ELSE 'High discount'
END AS discount_groups,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY segment,discount_groups
HAVING total_sales>1000 AND total_profit<0
),
discount_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit ASC) AS profit_rank
FROM discount_summary
)
SELECT * 
FROM discount_ranking
WHERE profit_rank <=10;

-- 6.5 Which regions lose the most money from discounts?
WITH  discount_summary AS
(
SELECT region,
	CASE
    WHEN discount = 0 THEN 'No discount'
    WHEN discount <= 0.2 THEN 'Low (1-20%)'
    WHEN discount <= 0.4 THEN 'Medium (21-40%)'
    ELSE 'High discount'
END AS discount_groups,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY region,discount_groups
HAVING total_sales>1000 AND total_profit<0
),
discount_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit ASC) AS profit_rank
FROM discount_summary
)
SELECT * 
FROM discount_ranking
WHERE profit_rank <=10;

-- Section 7: Customer Segment Analysis
/*=========================================================
Business Question:
Which customer segments generate the highest business
value?

Business Objective:
Compare Consumer, Corporate and Home Office segments using
sales, profit and profit margins.

Business Insight:
Segments differ in efficiency. High sales segments do not
necessarily generate the highest profit margins.

Business Value:
Supports customer targeting, marketing allocation and
pricing decisions.

Recommendation:
Maintain pricing strategies for highly profitable segments
while reviewing discount policies for segments with lower
profitability.
=========================================================*/
-- 7.1 Which segment generates the highest revenue?
WITH  segment_summary AS
(
SELECT segment,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY segment
),
segment_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales desc) AS sales_rank
FROM segment_summary
)
SELECT * 
FROM segment_ranking
WHERE sales_rank =1;

-- 7.2 Which segment generates the highest profit?
WITH  segment_summary AS
(
SELECT segment,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY segment
),
segment_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit desc) AS profit_rank
FROM segment_summary
)
SELECT * 
FROM segment_ranking
WHERE profit_rank =1;

-- 7.3 Which segment has the highest profit margin?
WITH  segment_summary AS
(
SELECT segment,
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY segment
),
segment_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin desc) AS margin_rank
FROM segment_summary
)
SELECT * 
FROM segment_ranking
WHERE margin_rank =1;

-- Section 8: Time Analysis
/*=========================================================
Business Question:
How has business performance changed over time?

Business Objective:
Identify seasonal trends, monthly performance and long-term
business growth.

Business Insight:
Sales fluctuate throughout the year. Some high-sales months
generate relatively low profit margins, suggesting seasonal
pricing or discount effects.

Business Value:
Supports forecasting, budgeting and inventory planning.

Recommendation:
Investigate pricing, promotions and product mix during
months with strong sales but weak profitability before
planning future seasonal campaigns.
=========================================================*/
-- 8.1 Monthly sales Performance
WITH monthly_summary AS
(
SELECT month_number,
       order_month,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM orders
GROUP BY order_month, month_number
)
SELECT *
FROM monthly_summary
ORDER BY month_number;

-- 8.2 Quarterly Sales Performance
WITH monthly_summary AS
(
SELECT quarter,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM orders
GROUP BY quarter
)
SELECT *
FROM monthly_summary
ORDER BY quarter;

-- 8.3 Annual Sales Performance
WITH monthly_summary AS
(
SELECT order_year,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM orders
GROUP BY order_year
)
SELECT *
FROM monthly_summary
ORDER BY order_year;

-- 8.4 Best Month by Sales
WITH monthly_summary AS
(
SELECT order_month,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM orders
GROUP BY order_month
),
monthly_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM monthly_summary
)
SELECT *
FROM monthly_ranking
WHERE sales_rank = 1;

-- 8.5 Worst Month by Sales
WITH monthly_summary AS
(
SELECT order_month,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM orders
GROUP BY order_month
),
monthly_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales ASC) AS sales_rank
FROM monthly_summary
)
SELECT *
FROM monthly_ranking
WHERE sales_rank = 1;

-- 8.6 Year-over-Year growth
WITH monthly_summary AS
(
SELECT order_year,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin,
       ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY order_year
),
yearly_growth AS
(
SELECT *,
       ROUND(total_sales - LAG(total_sales) OVER(ORDER BY order_year),2) AS growth
FROM monthly_summary
)
SELECT *,
       ROUND(growth/LAG(total_sales) OVER(ORDER BY order_year)*100,2) AS growth_percentage
FROM yearly_growth;

-- 8.7 Month over Month Growth
WITH monthly_summary AS
(
SELECT order_month,
	   month_number,
       ROUND(SUM(profit),2) AS total_profit,
	   ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin,
       ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY order_month, month_number
),
monthly_growth AS
(
SELECT *,
       ROUND(total_sales - LAG(total_sales) OVER(ORDER BY month_number),2) AS growth
FROM monthly_summary
)
SELECT *,
       ROUND(growth/LAG(total_sales) OVER(ORDER BY month_number)*100,2) AS growth_percentage
FROM monthly_growth;

-- 8.8 Cumulative Sales
WITH yearly_summary AS
(
SELECT order_year,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY order_year
)
SELECT *,
       ROUND(SUM(total_sales) OVER(ORDER BY order_year),2) AS cumulative_sales
FROM yearly_summary;

-- SECTION 9 : Shipping Analysis
/*=========================================================
Business Question:
How does shipping method affect business performance?

Business Objective:
Evaluate the relationship between shipping methods, sales
and profitability.

Business Insight:
Different shipping methods contribute differently to
revenue and profit, indicating varying operational
efficiency.

Business Value:
Supports logistics planning and shipping policy decisions.

Recommendation:
Promote shipping methods that consistently generate strong
profitability while reviewing the operational costs of less
efficient shipping options.
=========================================================*/
-- 9.1 Which ship mode generates the most sales?
WITH shipping_summary AS
(
SELECT ship_mode,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY ship_mode
), 
ship_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM shipping_summary
)
SELECT *
FROM ship_ranking
WHERE sales_rank = 1;

-- 9.2 Which ship mode is most profitable?
WITH shipping_summary AS
(
SELECT ship_mode,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY ship_mode
), 
ship_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY total_profit DESC) AS profit_rank
FROM shipping_summary
)
SELECT *
FROM ship_ranking
WHERE profit_rank = 1;

-- 9.3 Which ship mode has the highest profit margin?
WITH shipping_summary AS
(
SELECT ship_mode,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY ship_mode
), 
ship_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS margin_rank
FROM shipping_summary
)
SELECT *
FROM ship_ranking
WHERE margin_rank = 1;

-- 9.4 Sales and Profit by ship mode
SELECT ship_mode,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- Section 10: Strategic Opportunities
/*=========================================================
Business Question:
Where are the greatest opportunities to improve business
performance?

Business Objective:
Identify customers and products that combine high revenue
with strong profitability.

Business Insight:
Profit efficiency varies significantly across customers and
products, highlighting opportunities for growth and pricing
optimization.

Business Value:
Supports strategic investment decisions and resource
allocation.

Recommendation:
Prioritize highly efficient customers and products while
reviewing those generating substantial sales but weak
returns.
=========================================================*/
-- 10.1 Top 10 Customers by Profit Efficiency
WITH customer_summary AS
(
SELECT customer_id,
       customer_name,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY customer_id, customer_name
HAVING total_sales > 5000
),
customer_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS margin_rank
FROM customer_summary
)
SELECT *
FROM customer_ranking
WHERE margin_rank <= 10;

-- 10.2 Top 10 Products
WITH product_summary AS
(
SELECT product_id,
       product_name,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_id, product_name
HAVING total_sales > 5000
),
product_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS margin_rank
FROM product_summary
)
SELECT *
FROM product_ranking
WHERE margin_rank <= 10;

-- 10.3 Top 5 Products per Category
WITH product_summary AS
(
SELECT product_id,
       product_name,
       category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_id, product_name,category
HAVING total_sales> 5000
),
product_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY category ORDER BY profit_margin DESC) AS margin_rank
FROM product_summary
)
SELECT *
FROM product_ranking
WHERE margin_rank <= 5;

-- 10.4 Top 3 Customers per Region
WITH customer_summary AS
(
SELECT customer_id,
       customer_name,
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY customer_id, customer_name,region
HAVING total_sales > 5000
),
customer_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY region ORDER BY profit_margin DESC) AS margin_rank
FROM customer_summary
)
SELECT *
FROM customer_ranking
WHERE margin_rank <= 3;

-- 10.5 Top 5 Products per Region
WITH product_summary AS
(
SELECT product_id,
       product_name,
       region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders
GROUP BY product_id, product_name,region
HAVING total_sales > 5000
),
product_ranking AS
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY region ORDER BY profit_margin DESC) AS margin_rank
FROM product_summary
)
SELECT *
FROM product_ranking
WHERE margin_rank <= 5;


       
       











