-- *************************************************************** SQL Project ******************************************************************** --
-- Create Database Project;
 use Project;
select * from loan;

create table FLA as 
select * from loan;

-- ********** Basic SQL & Filtering (SELECT, WHERE, ORDER BY) ********** --
-- Q.1) Find the top 10 customers with the highest annual_income whose loan_status = 1, ordered by income descending.
select customer_id,loan_status,max(annual_income) as annual_income
from loan
where loan_status = 1 
group by customer_id
order by annual_income desc
limit 10;

-- Q.2) Retrieve all customers aged between 25 and 40 who have no defaults on file and a credit_score above 700.
select Customer_id,age,defaults_on_file,credit_score
from loan
where age between 25 and 40
and defaults_on_file = 0 
and credit_score >= 700;

-- ********** Aggregate Functions (COUNT, SUM, AVG, MIN, MAX)********** --
-- Q.3) What is the average loan amount and average interest rate for each product_type?
select product_type,avg(loan_amount) as avg_loan , avg(interest_rate) as avg_int
from loan
group by product_type
order by product_type;

-- Q.4)Find the total loan amount approved and total loan amount rejected based on loan_status.
select sum(loan_amount),loan_status
from loan
group by loan_status;

-- ********** GROUP BY & HAVING ********** --
-- Q.5) Identify occupation_status groups where the average credit score is above 680 and average debt_to_income_ratio is below 0.35.
select occupation_status,avg(credit_score) as avg_score, avg(debt_to_income_ratio) as avg_ratio
from loan
where credit_score >= 680 and debt_to_income_ratio < 0.35
group by occupation_status;

-- Q.6) Which loan_intent has more than 3,000 approved loans?
select loan_intent,count(*) as approve_loans
from loan
where loan_status = 1
group by loan_intent 
having count(*) > 3000;

-- ********** Conditional Logic (CASE) ********** --

-- Q.7) Classify customers into Credit Risk categories:
/* Low Risk → credit_score ≥ 720
Medium Risk → 650–719
High Risk → < 650
Then find the approval rate (%) for each risk category.*/
select customer_id,credit_score,
case
	when credit_score >= 720 then 'Low Risk'
    when credit_score between 650 and 719 then 'Medium Risk'
    when credit_score < 650 then 'High Risk'
end as Risk_Category
from loan;

SELECT
  CASE
    WHEN credit_score >= 720 THEN 'Low Risk'
    WHEN credit_score BETWEEN 650 AND 719 THEN 'Medium Risk'
    ELSE 'High Risk'
  END AS risk_category,
  SUM(loan_status) * 100.0 / COUNT(*) AS approval_rate
FROM loan
GROUP BY
  CASE
    WHEN credit_score >= 720 THEN 'Low Risk'
    WHEN credit_score BETWEEN 650 AND 719 THEN 'Medium Risk'
    ELSE 'High Risk'
  END;

-- ********** Subqueries ********** --
-- Q.8) Find customers whose annual_income is above the overall average income but whose loan was rejected.
select customer_id,annual_income,loan_status
from loan
where loan_status = 0 and 
annual_income > (
	select avg(annual_income)
    from loan
    );
	
-- Q.9) Retrieve customers who have a higher loan_amount than the average loan amount for their respective loan_intent.
select customer_id,loan_amount,loan_intent
from loan l
where loan_amount > (
	select avg(loan_amount)
    from loan l2
    where l2.loan_intent = l.loan_intent
    limit 10
);

SELECT l.customer_id,
       l.loan_amount,
       l.loan_intent
FROM loan l
JOIN (
    SELECT loan_intent,
           AVG(loan_amount) AS avg_loan_amount
    FROM loan
    GROUP BY loan_intent
) a
ON l.loan_intent = a.loan_intent
WHERE l.loan_amount > a.avg_loan_amount;

-- ********** Window Functions (OVER, RANK, ROW_NUMBER) ********** --
-- Q.10) Rank customers within each product_type based on loan_amount using RANK().
select customer_id,product_type,loan_amount,
	rank() over(partition by product_type order by loan_amount) as rnk
    from loan;

-- Q.11) For each loan_intent, calculate the running total of approved loan amounts ordered by loan_amount.
select customer_id,loan_intent,loan_amount,
	sum(loan_amount) over(partition by loan_intent order by loan_amount) as Approve_Loan_amount
    from loan
    where loan_status = 1;

-- ********** Analytical EDA Questions ********** --
-- Q.12) Calculate the approval rate (%) for each occupation_status, and order them from highest to lowest.
select occupation_status,SUM(loan_status) * 100.0 / COUNT(*) AS approval_rate
FROM loan
GROUP BY occupation_status
ORDER BY approval_rate DESC;

-- Q.13) Find the top 3 loan intents with the highest average loan_to_income_ratio.
select loan_intent,avg(loan_to_income_ratio)
from loan
group by loan_intent
limit 3;

-- ********** Views ********** --
-- Q.14) Create a VIEW named approved_high_risk_customers that includes customers:
/* loan_status = 1
credit_score < 650
debt_to_income_ratio > 0.4 */
create view approved_high_risk_customers as
select customer_id,loan_status,credit_score,debt_to_income_ratio
FROM loan
WHERE loan_status = 1
  AND credit_score < 650
  AND debt_to_income_ratio > 0.4;
select * from approved_high_risk_customers;

-- ********** Data Modification / Commands (DDL / DML – Conceptual)********** --
-- Q.15) Write a query to update interest_rate by +1% for approved loans where loan_to_income_ratio is greater than 1.5.
SELECT *
FROM loan
WHERE loan_status = 1
  AND loan_to_income_ratio > 1.5;

update loan
set interest_rate = interest_rate + 1
where loan_status = 1
  and loan_to_income_ratio > 1.5;

-- ************************************************************ THANK YOU ********************************************************************** --  