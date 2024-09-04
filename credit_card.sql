-- https://sqliteonline.com/

SELECT *
FROM CREDIT_CARD
LIMIT 10;

-- Users who pay off balances in full
SELECT CUST_ID
FROM CREDIT_CARD
WHERE PRC_FULL_PAYMENT = 1.0;

-- Customers paying above the minimum payment 
SELECT CUST_ID, MINIMUM_PAYMENTS, PAYMENTS, 
       CASE 
          WHEN PAYMENTS > MINIMUM_PAYMENTS THEN 'Above Minimum'
          ELSE 'Below or Equal to Minimum'
       END AS PAYMENT_BEHAVIOR
FROM CREDIT_CARD
WHERE MINIMUM_PAYMENTS IS NOT NULL;

-- Customers with high spending relative to credit limit 
SELECT CUST_ID, 
	(PURCHASES / CREDIT_LIMIT) * 100 AS SPENDING_PERCENTAGE
FROM CREDIT_CARD
ORDER BY SPENDING_PERCENTAGE DESC;

-- Customer with the highest spending percentage identified in the previous query
SELECT *
FROM CREDIT_CARD
WHERE CUST_ID = 'C10131';

-- Customers at risk of default (high balance -> higher minimum payment)
SELECT CUST_ID, BALANCE, MINIMUM_PAYMENTS,
	CASE
    	WHEN PRC_FULL_PAYMENT < 0.3 AND BALANCE > 2000 THEN 'High Risk'
        ELSE 'Low Risk'
    END AS DEFAULT_RISK
FROM CREDIT_CARD
ORDER BY DEFAULT_RISK DESC;


-- Customer segmentation based on purchase frequency and on-off purchase frequency
SELECT 
	CASE
    	WHEN PURCHASES_FREQUENCY >= 0.75 THEN 'High Purchase Frequency'
        WHEN PURCHASES_FREQUENCY BETWEEN 0.5 AND 0.75 THEN 'Medium Purchase Frequency'
        ELSE 'Low Frequency'
    END AS Purchase_Segmentation,
    CASE
    	WHEN ONEOFF_PURCHASES_FREQUENCY > 0.5 THEN 'High One-Off Frequency'
        WHEN ONEOFF_PURCHASES_FREQUENCY BETWEEN 0.25 AND 0.5 THEN 'Medium One-Off Frequency'
        ELSE 'Low One-Off Frequency'
    END AS OneOff_Purchase_Segmentation,
    COUNT(*)
 FROM CREDIT_CARD
 GROUP BY Purchase_Segmentation, OneOff_Purchase_Segmentation;
 
 -- Customer segmentation based on purchase and payment patterns
 WITH customer_segments AS (
    SELECT CUST_ID, 
           CASE 
               WHEN PURCHASES > 5000 THEN 'High Spender'
               WHEN PURCHASES BETWEEN 1000 AND 5000 THEN 'Medium Spender'
               ELSE 'Low Spender'
           END AS SPENDING_CATEGORY,
           CASE 
               WHEN PAYMENTS >= PURCHASES THEN 'Pays in Full'
               WHEN PAYMENTS < PURCHASES THEN 'Partial Payer'
           END AS PAYMENT_CATEGORY
    FROM CREDIT_CARD
)
SELECT SPENDING_CATEGORY, PAYMENT_CATEGORY, COUNT(CUST_ID) AS NUM_CUSTOMERS
FROM customer_segments
GROUP BY SPENDING_CATEGORY, PAYMENT_CATEGORY
ORDER BY NUM_CUSTOMERS DESC;

 
