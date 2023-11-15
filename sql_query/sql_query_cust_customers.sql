WITH ages AS
  ( SELECT org.Name AS company,
           cust.Year_Subscription AS YEAR,
           FLOOR(DATEDIFF((cust.Subscription_Date), DATE(ppl.Date_of_birth)) / 365) AS age,
           COUNT(*) AS subscribers_count,
           ROW_NUMBER() OVER (PARTITION BY org.Name, cust.Year_Subscription
                              ORDER BY COUNT(*) DESC) AS rn
   FROM organizations_transform AS org
   LEFT JOIN customers_transform AS cust ON org.Website = cust.Website
   JOIN people_transform AS ppl ON ppl.email = cust.email
   GROUP BY org.Name,
            cust.Year_Subscription,
            FLOOR(DATEDIFF((cust.Subscription_Date), DATE(ppl.Date_of_birth)) / 365))
SELECT company,
       YEAR,
       CASE
           WHEN age <= 18 THEN '[0 - 18]'
           WHEN age <= 25 THEN '[19 - 25]'
           WHEN age <= 35 THEN '[26 - 35]'
           WHEN age <= 45 THEN '[36 - 45]'
           WHEN age <= 55 THEN '[46 - 55]'
           ELSE '[55+]'
       END AS age_group
FROM ages
WHERE rn = 1
ORDER BY company,
         YEAR;

