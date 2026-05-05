# 🏥 Enterprise Hospital Data Warehouse & BI Analytics

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![SSIS](https://img.shields.io/badge/SSIS-ETL_Pipeline-blue?style=for-the-badge)
![SSAS](https://img.shields.io/badge/SSAS-OLAP_Cube-purple?style=for-the-badge)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

## 📌 Project Overview
Welcome to my end-to-end **Data Warehousing and Business Intelligence (DWBI)** solution designed specifically for Healthcare Analytics. This project transforms raw, fragmented hospital data from multiple sources into a highly optimized multidimensional model, delivering actionable insights through interactive dashboards.

## 🏗️ System Architecture
The solution architecture is built on a robust 5-layer framework:
1. **Data Sources:** Extracted data from 16 heterogeneous tables (SQL Server, CSV files, and high-volume TXT files).
2. **Staging Area:** A dedicated SQL Server landing zone for data cleansing and extraction decoupling.
3. **ETL Engine (SSIS):** Complex integration pipelines utilizing Data Conversions, Lookups, and Derived Columns.
4. **Data Warehouse:** A highly optimized **Snowflake Schema** central repository.
5. **BI & Reporting:** Multidimensional **SSAS OLAP Cubes** and interactive **Power BI** dashboards.

*(Note: Please refer to the `Architecture_Diagrams` folder for the complete system and ER diagrams).*

## 🗄️ Dimensional Modeling
The core of this Data Warehouse utilizes a **Snowflake Schema**:
*   **Fact Table:** `Fact_Admission_Billing` (Accumulating Snapshot grain).
*   **Dimensions (8):** `Dim_Patient`, `Dim_Ward`, `Dim_Department`, `Dim_Bed`, `Dim_Disease`, `Dim_Drug`, `Dim_Employee`, and `Dim_Date`.

## ✨ Key Features & Technical Highlights
*   **Slowly Changing Dimensions (SCD):** Successfully implemented **SCD Type 1** for standard demographic updates and **SCD Type 2** for strict historical tracking of patient insurance policies.
*   **Accumulating Snapshot Fact Tables:** Engineered fact tables to track the entire patient lifecycle from admission to discharge, enabling the calculation of critical duration metrics like *Length of Stay* and *Transaction Processing Hours*.
*   **OLAP Cube Development:** Built an SSAS cube with predefined measures and logical hierarchies (Year -> Quarter -> Month -> Day) for rapid Slice, Dice, Drill-down, and Roll-up operations.
*   **Live Power BI Connections:** Developed dynamic dashboards connected live to the SSAS cube, featuring matrix visuals, cascading slicers, and drill-through reporting.

## 📂 Repository Structure
*   📁 **`Dataset/`** - Raw source files (CSV, TXT, Excel).
*   📁 **`Database_and_ETL/`** - SQL scripts (DDL) and the complete SSIS ETL project.
*   📁 **`SSAS_Cube/`** - SQL Server Analysis Services multidimensional cube project files.
*   📁 **`Dashboards_and_Reports/`** - Power BI (.pbix) files and Excel analytical reports.
*   📄 **`Final_Project_Report.pdf`** - Comprehensive project documentation and methodology.

## 👩‍💻 About the Author
**Kaveesha Kithmini Senadeera**  
*3rd-Year Data Science Undergraduate @ SLIIT (Sri Lanka Institute of Information Technology)*  

I am passionate about Data Engineering, BI Development, and turning complex data into strategic business value. Feel free to explore the code, and don't hesitate to reach out if you have any questions or suggestions!

I am passionate about Data Engineering, BI Development, and turning complex data into strategic business value. Feel free to explore the code, and don't hesitate to reach out if you have any questions or suggestions!
