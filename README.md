# Exploratory Data Analysis🚀

## ✨ Introduction

Welcome to the **Data Warehouse and Exploratory Data Analytics Project** repository! This project serves as a comprehensive, end-to-end demonstration of building a modern data solution, from initial data ingestion to the delivery of actionable business intelligence. It is designed to showcase industry-standard practices in data engineering, data modeling, and data analysis, making it an ideal portfolio piece for aspiring data professionals.

The core of this project is to transform raw, disparate data from multiple sources into a clean, reliable, and highly-performant data warehouse, which then serves as a single source of truth for powerful analytics and reporting.

---

## 🏗️ Data Architecture: The Medallion Framework

This project implements the industry-recognized **Medallion Architecture**, a multi-layered approach that ensures data quality, reliability, and scalability. This architecture logically organizes data into three distinct layers: Bronze, Silver, and Gold.

### 🥉 Bronze Layer: The Raw Data Zone
This is the initial landing zone for all source data. Data is ingested from its original sources (in this case, CSV files from an ERP and CRM system) and stored **as-is**, preserving the raw, untransformed state. This layer provides a historical archive and a foundation for rebuilding the subsequent layers if needed.

### 🥈 Silver Layer: The Cleansed & Conformed Zone
In the Silver Layer, the raw data undergoes its first stage of transformation. The key processes here include:
* **Data Cleansing:** Handling missing values, correcting data types, and removing duplicates.
* **Standardization:** Conforming data to standard formats (e.g., consistent date formats, standardized naming conventions).
* **Integration:** Merging the datasets from the different source systems (ERP and CRM).

The output is a set of validated, enriched, and integrated tables that serve as an authoritative source for business-level analysis.

### 🥇 Gold Layer: The Business-Ready Zone
The Gold Layer is the final, presentation-ready tier, optimized for analytics and reporting. Data from the Silver Layer is transformed into a **Star Schema** data model, consisting of a central fact table and multiple surrounding dimension tables. This structure is highly denormalized and designed for the efficient querying required by BI tools and analytical reports.

---

## 🗺️ Exploratory Data Analysis (EDA) Workflow

Before modeling, a thorough Exploratory Data Analysis (EDA) was conducted to understand the dataset's characteristics, uncover patterns, and identify potential data quality issues. The structured workflow below was followed.

![image](https://github.com/user-attachments/assets/d11bb702-a305-4ace-bf9b-5b6a2ba73b9d)

Our EDA process is broken down into these key stages:

1.  **Database Exploration:** The initial step to get a high-level overview of the database schema, including table names, column names, and their data types.
2.  **Dimensions Exploration:** Analyzing categorical columns to understand the variety and distribution of their distinct values (e.g., `DISTINCT` countries, product categories).
3.  **Date Exploration:** Investigating the time range of the data by finding the minimum and maximum dates to understand the dataset's temporal boundaries.
4.  **Measures Exploration:** Performing initial aggregations on numeric columns (e.g., `SUM(Sales)`, `AVG(Price)`) to get a sense of the key figures and their scale.
5.  **Magnitude Analysis:** Breaking down key measures by different dimensions to understand their contribution (e.g., `Total Sales by Country`, `Total Orders by Customer`).
6.  **Ranking:** Identifying top and bottom performers using ranking functions to highlight key contributors or outliers (e.g., `Top 10 Products by Sales`).

---

## 🎯 Project Lifecycle & Requirements

This project was executed in two primary phases: Data Engineering to build the warehouse and Data Analysis to extract insights.

### Phase 1: Data Engineering (Building the Data Warehouse)

**Objective:** To construct a robust data warehouse using SQL Server that consolidates sales data from different sources, enabling reliable and efficient analytical reporting.

**Key Specifications:**
* **Data Ingestion:** Import data from two separate source systems (ERP and CRM) provided as CSV files.
* **Data Quality Assurance:** Implement cleansing scripts to identify and resolve data quality issues before the data is loaded into the final model.
* **Data Integration:** Combine the source datasets into a single, cohesive star schema data model.
* **Scope:** The project focuses on the latest available dataset, without the requirement for data historization (slowly changing dimensions).
* **Documentation:** Create clear documentation of the final data model to support its use by analysts and business users.

### Phase 2: BI & Analytics (Reporting & Data Analysis)

**Objective:** To develop a suite of SQL-based analytical queries to uncover actionable insights into key business areas, empowering stakeholders to make data-driven decisions.

**Key Focus Areas:**
* **Customer Behavior:** Analyze customer demographics, purchasing patterns, and value.
* **Product Performance:** Investigate product sales, popularity, and profitability.
* **Sales Trends:** Track sales performance over time to identify trends, seasonality, and growth patterns.

For a more granular breakdown of the business questions and analytical requirements, please see `docs/requirements.md`.

---

## 🛠️ Tools and Technologies

This project was developed exclusively with free and accessible tools.

| Tool | Purpose |
| :--- | :--- |
| **SQL Server Express** | A powerful and free relational database engine to host the data warehouse. |
| **SSMS** | The primary GUI for managing, querying, and developing on SQL Server. |
| **GitHub** | For version control and collaborative development of the project's codebase. |
| **Draw.io** | A versatile online tool used to design the data architecture and workflow diagrams. |
| **Notion** | An all-in-one workspace used for project management, task tracking, and documentation. |

---

## 📂 Repository Structure

The repository is organized to ensure clarity and ease of navigation:

```
.
├── data/                   # Raw source data (CSV files)
├── docs/                   # Project documentation, requirements, and diagrams
├── analytics-queries/      # SQL scripts for final business intelligence and analysis
└── README.md               # This file
```

---

## 🛡️ License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute this project with proper attribution. See the [LICENSE](LICENSE) file for more details.

---

## 🌟 About Me

Hi there! I'm **Yeswanth Sai Tirumalasetty**, a dedicated Business Intelligence Engineer and Developer. I am passionate about crafting robust data solutions and deriving meaningful insights from complex datasets.

Let's stay in touch! Feel free to connect with me on the following platforms:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/yeswanth-sai-tirumalasetty/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/yeswanthsai18)
[![Portfolio](https://img.shields.io/badge/Portfolio-000000?style=for-the-badge&logo=google-chrome&logoColor=white)](https://bento.me/yeswanthsai18)
