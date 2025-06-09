# 🧩 Customer Segmentation using RFM Analysis (SQL + BigQuery)

This project implements RFM (Recency, Frequency, Monetary) analysis on retail transaction data using **Google BigQuery** and **SQL** to segment customers into targeted marketing groups such as *Champions*, *Loyal Customers*, *At Risk*, and more.

---

## 📌 Objectives

- Identify high-value and at-risk customers using RFM segmentation.
- Enable businesses to personalize marketing strategies based on customer behavior.
- Automate the segmentation process using SQL in BigQuery.

---

## 🛠️ Tools & Technologies

- **Google BigQuery**
- **SQL (Standard)**
- **Retail Sales Dataset (CSV)**
- **RFM Segmentation Techniques**
- **DMA-Based Customer Personas**

---

## 📂 Project Structure

customer-segmentation-sql/
├── data/
│ └── sales_sample.csv
├── queries/
│ └── rfm_analysis_bigquery.sql
├── images/
│ └── rfm_segment_chart.png
└── README.md


---

## 📁 Key Files

- 📄 [`rfm_analysis_bigquery.sql`](queries/rfm_analysis_bigquery.sql) — BigQuery SQL script for RFM segmentation
- 📊 [`sales_sample.csv`](data/sales_sample.csv) — Sample transaction data used for analysis
- 🖼️ [`rfm_segment_chart.png`](images/rfm_segment_chart.png) — Pie chart of customer segmentation

---

## 📈 Methodology

1. **Data Cleaning & Preprocessing**: Load and transform sales data.
2. **RFM Calculation**: Compute recency, frequency, and monetary values per customer.
3. **Quantile Segmentation**: Assign scores from 1–5 based on value distribution.
4. **RFM Scoring**: Derive customer personas (Champions, Loyal, At Risk, etc.).
5. **Visualization**: Present results in a pie chart using Excel.

---

## 📉 Output Segments

| Segment             | Description                                |
|---------------------|--------------------------------------------|
| Champions           | Recent, frequent, high-spending customers  |
| Loyal Customers     | Consistently buy and spend well            |
| At Risk             | High-value customers who haven’t returned  |
| Hibernating         | Inactive customers with low value          |
| Lost                | No recent activity and low spend           |

---




