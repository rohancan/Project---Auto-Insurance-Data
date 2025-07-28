-- Obtain the top 1000 records of this auto insurance data

SELECT TOP (1000) [Customer]
      ,[State]
      ,[Customer Lifetime Value]
      ,[Response]
      ,[Coverage]
      ,[Education]
      ,[Effective To Date]
      ,[EmploymentStatus]
      ,[Gender]
      ,[Income]
      ,[Location Code]
      ,[Marital Status]
      ,[Monthly Premium Auto]
      ,[Months Since Last Claim]
      ,[Months Since Policy Inception]
      ,[Number of Open Complaints]
      ,[Number of Policies]
      ,[Policy Type]
      ,[Policy]
      ,[Renew Offer Type]
      ,[Sales Channel]
      ,[Total Claim Amount]
      ,[Vehicle Class]
      ,[Vehicle Size]
  FROM [model].[dbo].[AutoInsurance];


  -- Obtain the count of people by state and education level
  SELECT 
    State,
    Education,
    COUNT(*) AS PeopleCount
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY State, Education
ORDER BY State, Education;

-- Obtain the cont of people by State, Education, and Employment Status

SELECT 
    State,
    Education,
    EmploymentStatus,
    COUNT(*) AS PeopleCount
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY State, Education, EmploymentStatus
ORDER BY State, Education, EmploymentStatus;

-- Obtain the proportion of employment status by education level per state

WITH EducationEmployment AS (
    SELECT 
        State,
        Education,
        EmploymentStatus,
        COUNT(*) AS PeopleCount
    FROM dbo.AutoInsurance
    WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
    GROUP BY State, Education, EmploymentStatus
),
EducationTotal AS (
    SELECT 
        State,
        Education,
        SUM(PeopleCount) AS TotalPeople
    FROM EducationEmployment
    GROUP BY State, Education
)
SELECT 
    e.State,
    e.Education,
    e.EmploymentStatus,
    e.PeopleCount,
    ROUND((e.PeopleCount * 100.0 / t.TotalPeople), 2) AS PercentageWithinEducation
FROM EducationEmployment e
JOIN EducationTotal t 
    ON e.State = t.State AND e.Education = t.Education
ORDER BY e.State, e.Education, e.EmploymentStatus;

-- Obtain the number of people grouped by state, education, employment status, and marital status

SELECT 
    State,
    Education,
    EmploymentStatus,
    [Marital Status],
    COUNT(*) AS PeopleCount
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY State, Education, EmploymentStatus, [Marital Status]
ORDER BY State, Education, EmploymentStatus, [Marital Status];

-- Obtain the average premium and customer lifetime value by state and education

SELECT 
    State,
    Education,
    AVG(TRY_CAST([Monthly Premium Auto] AS FLOAT)) AS AvgPremium,
    AVG(TRY_CAST([Customer Lifetime Value] AS FLOAT)) AS AvgCLV
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY State, Education
ORDER BY State, Education;

-- Obtain the claim behavior by education and employment

SELECT 
    Education,
    EmploymentStatus,
    SUM(CASE WHEN Response = 'Yes' THEN 1 ELSE 0 END) AS ClaimCount,
    COUNT(*) AS TotalCustomers,
    ROUND( (SUM(CASE WHEN Response = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS ClaimPercentage
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY Education, EmploymentStatus
ORDER BY Education, EmploymentStatus;

-- Assess the impact of marital status on claims

SELECT 
    [Marital Status],
    SUM(CASE WHEN Response = 'Yes' THEN 1 ELSE 0 END) AS ClaimCount,
    COUNT(*) AS TotalCustomers,
    ROUND( (SUM(CASE WHEN Response = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS ClaimPercentage
FROM dbo.AutoInsurance
GROUP BY [Marital Status]
ORDER BY ClaimPercentage DESC;

-- Identify the groups that are more prone to claims or are high-risk segments

SELECT 
    State,
    Education,
    EmploymentStatus,
    [Marital Status],
    COUNT(*) AS Customers,
    SUM(CASE WHEN Response = 'Yes' THEN 1 ELSE 0 END) AS ClaimCount,
    ROUND((SUM(CASE WHEN Response = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS ClaimRate
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY State, Education, EmploymentStatus, [Marital Status]
HAVING COUNT(*) > 10 -- filters very tiny segments
ORDER BY ClaimRate DESC;

-- Analyze revenue contribution by education & employment

SELECT 
    Education,
    EmploymentStatus,
    SUM(TRY_CAST([Monthly Premium Auto] AS FLOAT)) AS TotalPremiumRevenue,
    SUM(TRY_CAST([Customer Lifetime Value] AS FLOAT)) AS TotalCLV,
    COUNT(*) AS CustomerCount
FROM dbo.AutoInsurance
WHERE Education IN ('High School or Below', 'College', 'Bachelors', 'Masters')
GROUP BY Education, EmploymentStatus
ORDER BY TotalPremiumRevenue DESC;

-- Obtain a customer segmentation matrix of policies & premiums

SELECT 
    [Number of Policies],
    AVG(TRY_CAST([Monthly Premium Auto] AS FLOAT)) AS AvgPremium,
    AVG(TRY_CAST([Total Claim Amount] AS FLOAT)) AS AvgClaim,
    COUNT(*) AS CustomerCount
FROM dbo.AutoInsurance
GROUP BY [Number of Policies]
ORDER BY [Number of Policies];

-- Find customers with one policy, no claims, and higher income (potential upsell target)

SELECT 
    Customer,
    Income,
    [Monthly Premium Auto],
    [Number of Policies],
    Response
FROM dbo.AutoInsurance
WHERE [Number of Policies] = 1 
    AND Response = 'No'
    AND Income > 60000
ORDER BY Income DESC;

-- Find customers with multiple complaints and a claim history

SELECT 
    Customer,
    [Number of Open Complaints],
    Response,
    [Months Since Last Claim],
    [Monthly Premium Auto]
FROM dbo.AutoInsurance
WHERE [Number of Open Complaints] >= 2
  AND Response = 'Yes';







