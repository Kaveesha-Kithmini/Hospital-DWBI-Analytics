USE Hospital_Source_DB;
GO
ALTER TABLE drug DROP COLUMN manufacturer_id;
GO


--Dimensions and Fact Table creation

USE Hospital_DW_DB;
GO

IF OBJECT_ID('dbo.Dim_Date', 'U') IS NOT NULL DROP TABLE dbo.Dim_Date;
GO

-- create dim date table
CREATE TABLE dbo.Dim_Date (
    date_key INT PRIMARY KEY,       -- Format: YYYYMMDD
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    english_month_name VARCHAR(20) NOT NULL,
    is_weekend BIT NOT NULL         -- 1 = Weekend, 0 = Weekday
);
GO

-- fill the data to dim date
DECLARE @StartDate DATE = '2020-01-01'; 
DECLARE @EndDate DATE = '2030-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dbo.Dim_Date (
        date_key,        
        full_date, 
        day, 
        month, 
        year, 
        quarter, 
        day_name, 
        english_month_name, 
        is_weekend
    )
    VALUES (
        CAST(FORMAT(@StartDate, 'yyyyMMdd') AS INT), 
        @StartDate, 
        DAY(@StartDate), 
        MONTH(@StartDate), 
        YEAR(@StartDate), 
        DATEPART(QUARTER, @StartDate),
        DATENAME(WEEKDAY, @StartDate),
        DATENAME(MONTH, @StartDate),
        CASE WHEN DATEPART(WEEKDAY, @StartDate) IN (1, 7) THEN 1 ELSE 0 END
    );
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
GO

SELECT TOP 50 * FROM dbo.Dim_Date
ORDER BY date_key DESC;
SELECT COUNT(*) AS Total_Days_Generated FROM dbo.Dim_Date;
GO

-- 3. Department Dimension (NVARCHAR damma)
CREATE TABLE Dim_Department (
    department_key INT IDENTITY(1,1) PRIMARY KEY,
    department_id INT NOT NULL, 
    department_name NVARCHAR(100) NULL,
    department_type NVARCHAR(50) NULL,
    floor_number INT NULL,
    status NVARCHAR(50) NULL
);
GO

-- 4. Ward Dimension (NVARCHAR damma)
CREATE TABLE Dim_Ward (
    ward_key INT IDENTITY(1,1) PRIMARY KEY,
    ward_id INT NOT NULL,
    ward_name NVARCHAR(100) NULL,
    ward_type NVARCHAR(50) NULL,
    total_beds INT NULL,
    department_key INT NOT NULL FOREIGN KEY REFERENCES Dim_Department(department_key)
);
GO

-- 5. Bed Dimension (NVARCHAR damma)
CREATE TABLE Dim_Bed (
    bed_key INT IDENTITY(1,1) PRIMARY KEY,
    bed_id INT NOT NULL,
    bed_number NVARCHAR(20) NULL,
    bed_status NVARCHAR(50) NULL,
    ward_key INT NOT NULL FOREIGN KEY REFERENCES Dim_Ward(ward_key)
);
GO

-- 6. Disease Dimension (NVARCHAR damma)
CREATE TABLE Dim_Disease (
    disease_key INT IDENTITY(1,1) PRIMARY KEY,
    disease_id INT NOT NULL,
    disease_name NVARCHAR(100) NULL,
    disease_category NVARCHAR(50) NULL
);
GO

-- 7. Patient Dimension  (NVARCHAR damma + SCD Type 2 columns)
CREATE TABLE Dim_Patient (
    patient_key INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
    patient_id INT NOT NULL,                   -- Business/Natural Key

    -- Fixed Attributes (SCD Type 0)
    gender NVARCHAR(10) NULL,
    date_of_birth DATE NULL,
    blood_group NVARCHAR(10) NULL,

    -- Changing Attributes (SCD Type 1 - Overwrite)
    city NVARCHAR(100) NULL,
    contact_number NVARCHAR(20) NULL,

    -- Historical Attributes (SCD Type 2 - Maintain History)
    insurance_name NVARCHAR(100) NULL,        

    -- SCD Type 2 Metadata Columns
    start_date DATE NOT NULL, 
    end_date DATE NULL, 
    is_current NVARCHAR(3) DEFAULT 'Yes'
);
GO

USE Hospital_DW_DB;
GO
ALTER TABLE Dim_Patient ADD age INT NULL;
GO

-- 8. Employee Dimension (NVARCHAR damma)
CREATE TABLE Dim_Employee (
    employee_key INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,
    employee_name NVARCHAR(100) NULL,
    gender NVARCHAR(10) NULL,
    role NVARCHAR(50) NULL,
    employment_type NVARCHAR(50) NULL,
    date_of_joining DATE NULL,
    department_key INT NOT NULL FOREIGN KEY REFERENCES Dim_Department(department_key)
);
GO

USE Hospital_DW_DB;
GO


IF OBJECT_ID('dbo.Dim_Drug', 'U') IS NOT NULL DROP TABLE dbo.Dim_Drug;
GO

-- Aluth Dim_Drug table eka
CREATE TABLE Dim_Drug (
    drug_key INT IDENTITY(1,1) PRIMARY KEY, 
    drug_id INT NOT NULL,                   
    drug_name NVARCHAR(100) NULL,
    brand_name NVARCHAR(100) NULL,          
    drug_category NVARCHAR(50) NULL,
    unit_cost DECIMAL(10,2) NULL
);
GO

-- 9. Fact Table eka (Foreign keys NULL allow kala!)
CREATE TABLE Fact_Admission_Billing (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    admission_id INT NOT NULL, -- Natural Key
    
    patient_key INT NOT NULL FOREIGN KEY REFERENCES Dim_Patient(patient_key),
    department_key INT NOT NULL FOREIGN KEY REFERENCES Dim_Department(department_key),
    
    -- Me thuna NULL allow karanawa (Source eke NULL thiyenna puluwan nisa)
    ward_key INT NULL FOREIGN KEY REFERENCES Dim_Ward(ward_key),
    bed_key INT NULL FOREIGN KEY REFERENCES Dim_Bed(bed_key),
    disease_key INT NULL FOREIGN KEY REFERENCES Dim_Disease(disease_key),
    
    -- Date Keys
    admission_date_key INT NOT NULL FOREIGN KEY REFERENCES Dim_Date(date_key),
    discharge_date_key INT NULL FOREIGN KEY REFERENCES Dim_Date(date_key), 
    bill_date_key INT NULL FOREIGN KEY REFERENCES Dim_Date(date_key), -- Bill eka passe enna puluwan nisa mekatath NULL dunna
    
    -- Measures
    total_amount DECIMAL(10,2) NULL,
    insurance_amount DECIMAL(10,2) NULL,
    patient_amount DECIMAL(10,2) NULL,
    
    -- Task 6: Accumulating Snapshot Columns
    accm_txn_create_time DATETIME NOT NULL,
    accm_txn_complete_time DATETIME NULL, 
    txn_process_time_hours DECIMAL(10,2) NULL 
);
GO

USE Hospital_DW_DB;
ALTER TABLE Dim_Bed ALTER COLUMN bed_number NVARCHAR(50);

USE Hospital_DW_DB;
ALTER TABLE Dim_Employee ALTER COLUMN gender NVARCHAR(50);

USE Hospital_DW_DB;
ALTER TABLE Dim_Patient ALTER COLUMN contact_number NVARCHAR(50);

USE Hospital_DW_DB;
ALTER TABLE Dim_Patient ALTER COLUMN insurance_name NVARCHAR(MAX);

USE Hospital_DW_DB;
ALTER TABLE Dim_Patient ALTER COLUMN insurance_name NVARCHAR(500);


USE Hospital_Staging_DB;
GO

CREATE TABLE stg_Transaction_Updates (
    admission_id INT PRIMARY KEY, 
    accm_txn_complete_time DATETIME
);


INSERT INTO stg_Transaction_Updates (admission_id, accm_txn_complete_time)
VALUES 
(1, '2026-04-05 10:30:00'),
(2, '2026-04-06 14:15:00'),
(3, '2026-04-07 09:00:00');


USE Hospital_DW_DB;
GO

ALTER TABLE Fact_Admission_Billing 
ADD stay_duration_days INT NULL;
GO


