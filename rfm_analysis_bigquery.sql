-- RFM Analysis for Customer Segmentation
-- Platform: Google BigQuery
-- Project: Retail Data Analysis
-- Author: [Your Name]

-- Step 1: Compute total amount per product
SELECT
  InvoiceNo,
  StockCode,
  Quantity,
  UnitPrice,
  (Quantity * UnitPrice) AS amount
FROM
  `project.dataset.sales`;

-- Step 2: Calculate total bill per invoice
WITH bills AS (
  SELECT
    InvoiceNo,
    (Quantity * UnitPrice) AS amount
  FROM
    `project.dataset.sales`
)
SELECT
  InvoiceNo,
  SUM(amount) AS total
FROM
  bills
GROUP BY
  InvoiceNo;

-- Step 3: Compute RFM base values per customer
SELECT
  CustomerID,
  DATE(MAX(InvoiceDate)) AS last_purchase_date,
  DATE(MIN(InvoiceDate)) AS first_purchase_date,
  COUNT(DISTINCT InvoiceNo) AS num_purchases,
  SUM(total) AS monetary
FROM (
  SELECT
    s.CustomerID,
    s.InvoiceDate,
    s.InvoiceNo,
    b.total,
    ROW_NUMBER() OVER(PARTITION BY s.InvoiceNo ORDER BY s.InvoiceNo) AS RN
  FROM
    `project.dataset.sales` s
  LEFT JOIN
    `project.dataset.bill` b
  ON
    s.InvoiceNo = b.InvoiceNo
) A
WHERE
  A.RN = 1
GROUP BY
  CustomerID;

-- Step 4: Compute recency and frequency rate
SELECT
  *,
  DATE_DIFF(reference_date, last_purchase_date, DAY) AS recency,
  num_purchases / months_cust AS frequency
FROM (
  SELECT
    *,
    MAX(last_purchase_date) OVER () + 1 AS reference_date,
    DATE_DIFF(last_purchase_date, first_purchase_date, MONTH) + 1 AS months_cust
  FROM
    `project.dataset.monetary`
)
ORDER BY
  CustomerID;

-- Step 5: Determine R, F, M quintile thresholds
SELECT
  a.*,
  b.percentiles[OFFSET(20)] AS m20,
  b.percentiles[OFFSET(40)] AS m40,
  b.percentiles[OFFSET(60)] AS m60,
  b.percentiles[OFFSET(80)] AS m80,
  b.percentiles[OFFSET(100)] AS m100,
  c.percentiles[OFFSET(20)] AS f20,
  c.percentiles[OFFSET(40)] AS f40,
  c.percentiles[OFFSET(60)] AS f60,
  c.percentiles[OFFSET(80)] AS f80,
  c.percentiles[OFFSET(100)] AS f100,
  d.percentiles[OFFSET(20)] AS r20,
  d.percentiles[OFFSET(40)] AS r40,
  d.percentiles[OFFSET(60)] AS r60,
  d.percentiles[OFFSET(80)] AS r80,
  d.percentiles[OFFSET(100)] AS r100
FROM
  `project.dataset.RFM` a,
  (SELECT APPROX_QUANTILES(monetary, 100) AS percentiles FROM `project.dataset.RFM`) b,
  (SELECT APPROX_QUANTILES(frequency, 100) AS percentiles FROM `project.dataset.RFM`) c,
  (SELECT APPROX_QUANTILES(recency, 100) AS percentiles FROM `project.dataset.RFM`) d;

-- Step 6: Assign R, F, M scores based on quintiles
SELECT
  CustomerID,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  CAST(ROUND((f_score + m_score) / 2, 0) AS INT64) AS fm_score
FROM (
  SELECT
    *,
    CASE
      WHEN monetary <= m20 THEN 1
      WHEN monetary <= m40 THEN 2
      WHEN monetary <= m60 THEN 3
      WHEN monetary <= m80 THEN 4
      ELSE 5
    END AS m_score,
    CASE
      WHEN frequency <= f20 THEN 1
      WHEN frequency <= f40 THEN 2
      WHEN frequency <= f60 THEN 3
      WHEN frequency <= f80 THEN 4
      ELSE 5
    END AS f_score,
    CASE
      WHEN recency <= r20 THEN 5
      WHEN recency <= r40 THEN 4
      WHEN recency <= r60 THEN 3
      WHEN recency <= r80 THEN 2
      ELSE 1
    END AS r_score
  FROM
    `project.dataset.Quintiles`
);

-- Step 7: Segment customers into personas
SELECT
  CustomerID,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  fm_score,
  CASE
    WHEN (r_score = 5 AND fm_score >= 4) THEN 'Champions'
    WHEN (r_score = 5 AND fm_score = 3)
      OR (r_score = 4 AND fm_score = 4)
      OR (r_score = 3 AND fm_score = 5) THEN 'Loyal Customers'
    WHEN (r_score >= 3 AND fm_score = 2) THEN 'Potential Loyalists'
    WHEN (r_score = 5 AND fm_score = 1) THEN 'Recent Customers'
    WHEN (r_score IN (3, 4) AND fm_score = 1) THEN 'Promising'
    WHEN (r_score IN (2, 3) AND fm_score IN (2, 3)) THEN 'Customers Needing Attention'
    WHEN (r_score = 2 AND fm_score = 1) THEN 'About to Sleep'
    WHEN (r_score <= 2 AND fm_score >= 3) THEN 'At Risk'
    WHEN (r_score = 1 AND fm_score >= 4) THEN 'Can’t Lose Them'
    WHEN (r_score = 1 AND fm_score = 2) THEN 'Hibernating'
    WHEN (r_score = 1 AND fm_score = 1) THEN 'Lost'
  END AS rfm_segment
FROM
  `project.dataset.score`
ORDER BY
  CustomerID;
