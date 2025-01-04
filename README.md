# Incremental_loading
Unlocking Efficient Data Integration with Incremental Load Using Azure Data Factory
Certainly! Below is a detailed `README.md` file that you can include in your GitHub repository to document the implementation of your incremental load process using Azure SQL Database, Azure Data Factory (ADF), and Azure Data Lake Storage Gen2 (ADLS Gen2).

```markdown
# Incremental Load with Azure SQL Database, Azure Data Factory, and ADLS Gen2

This repository contains the implementation of a fully parameterized incremental load process using Azure SQL Database, Azure Data Factory (ADF), and Azure Data Lake Storage Gen2 (ADLS Gen2). The process ensures that only new or modified data is loaded, saving time, reducing costs, and optimizing performance.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Pipeline Configuration](#pipeline-configuration)
- [Sample Data](#sample-data)
- [Results](#results)
- [Key Takeaways](#key-takeaways)
- [Next Steps](#next-steps)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Incremental loading is crucial for efficient data management. This project demonstrates how to implement a fully parameterized incremental load process using Azure SQL Database, Azure Data Factory (ADF), and Azure Data Lake Storage Gen2 (ADLS Gen2).

## Prerequisites

- Azure Subscription
- Azure SQL Database
- Azure Data Factory
- Azure Data Lake Storage Gen2
- Basic knowledge of SQL, Azure Data Factory, and Azure Storage

## Setup

### Step 1: Set Up Azure SQL Database

1. **Create Source and Destination Tables**:
   ```sql
   CREATE TABLE Sales (
       SaleID INT PRIMARY KEY,
       ProductID INT,
       SaleDate DATETIME,
       Amount DECIMAL(10, 2),
       LastModifiedDate DATETIME
   );
   ```

2. **Create Watermark Table**:
   ```sql
   CREATE TABLE WatermarkTable (
       TableName NVARCHAR(255),
       LastModifiedDate DATETIME
   );
   ```

3. **Insert Initial Watermark Value**:
   ```sql
   INSERT INTO WatermarkTable (TableName, LastModifiedDate)
   VALUES ('Sales', '1900-01-01');
   ```

### Step 2: Create Linked Services in Azure Data Factory

1. **Source Linked Service**: Create a linked service for the source Azure SQL Database.
2. **Destination Linked Service**: Create a linked service for the destination Azure SQL Database.
3. **ADLS Gen2 Linked Service**: Create a linked service for the Azure Data Lake Storage Gen2.

### Step 3: Create Datasets in Azure Data Factory

1. **Source Dataset**: Create a dataset for the source `Sales` table.
2. **Destination Dataset**: Create a dataset for the destination `Sales` table.
3. **Watermark Dataset**: Create a dataset for the `WatermarkTable`.
4. **ADLS Gen2 Dataset**: Create a dataset for the ADLS Gen2 storage.

### Step 4: Create a Pipeline in Azure Data Factory

1. **Define Pipeline Parameters**:
   - `TableName` (Type: String)
   - `LastModifiedDate` (Type: String)

2. **Lookup Activity for Watermark**:
   - **Name**: `LookupLastModifiedDate`
   - **Source Dataset**: Watermark Dataset
   - **Query**:
     ```sql
     SELECT LastModifiedDate FROM WatermarkTable WHERE TableName = '@{pipeline().parameters.TableName}'
     ```

3. **Lookup Activity for Max Last Modified Date**:
   - **Name**: `LookupMaxLastModifiedDate`
   - **Source Dataset**: Source Dataset
   - **Query**:
     ```sql
     SELECT MAX(LastModifiedDate) AS MaxLastModifiedDate FROM @{pipeline().parameters.TableName}
     ```

4. **Copy Data Activity**:
   - **Name**: `CopyIncrementalData`
   - **Source**:
     - **Source Dataset**: Source Dataset
     - **Query**:
       ```sql
       SELECT * FROM @{pipeline().parameters.TableName} WHERE LastModifiedDate > '@{activity('LookupLastModifiedDate').output.firstRow.LastModifiedDate}'
       ```
   - **Sink**:
     - **Sink Dataset**: ADLS Gen2 Dataset

5. **Stored Procedure Activity to Update Watermark**:
   - **Name**: `UpdateWatermark`
   - **Linked Service**: Destination Linked Service
   - **Stored Procedure Name**: `UpdateWatermark`
   - **Parameters**:
     - `@TableName`: `@{pipeline().parameters.TableName}`
     - `@LastModifiedDate`: `@{activity('LookupMaxLastModifiedDate').output.firstRow.MaxLastModifiedDate}`

### Step 5: Schedule the Pipeline

1. **Create a Trigger**:
   - Go to the "Triggers" tab.
   - Click on "+ New trigger" -> "New/Edit".
   - Set the schedule (e.g., daily) and associate it with the pipeline.

## Sample Data

### Sales Table

```sql
INSERT INTO Sales (SaleID, ProductID, SaleDate, Amount, LastModifiedDate) VALUES
(1, 101, '2023-01-01 10:00:00', 100.00, '2023-01-01 10:00:00'),
(2, 102, '2023-01-02 11:00:00', 150.00, '2023-01-02 11:00:00'),
(3, 103, '2023-01-03 12:00:00', 200.00, '2023-01-03 12:00:00'),
(4, 104, '2023-01-04 13:00:00', 250.00, '2023-01-04 13:00:00'),
(5, 105, '2023-01-05 14:00:00', 300.00, '2023-01-05 14:00:00'),
(6, 106, '2023-01-06 15:00:00', 350.00, '2023-01-06 15:00:00'),
(7, 107, '2023-01-07 16:00:00', 400.00, '2023-01-07 16:00:00'),
(8, 108, '2023-01-08 17:00:00', 450.00, '2023-01-08 17:00:00'),
(9, 109, '2023-01-09 18:00:00', 500.00, '2023-01-09 18:00:00'),
(10, 110, '2023-01-10 19:00:00', 550.00, '2023-01-10 19:00:00');
```

### Watermark Table

```sql
INSERT INTO WatermarkTable (TableName, LastModifiedDate) VALUES
('Sales', '2023-01-01 00:00:00');
```

## Results

- **Efficient Data Loading**: Only new or modified data was loaded, reducing the load time significantly.
- **Dynamic Parameters**: The pipeline was fully parameterized to handle different tables, dates, and scenarios dynamically.
- **Automated Updates**: The watermark table was automatically updated with the latest modification date.
- **Scalable Storage**: Using ADLS Gen2 ensured scalable and cost-effective storage for the incremental data in Parquet format.
- **Flexibility**: The parameterized approach allowed for easy adjustments and scalability for future requirements.

## Key Takeaways

- **Parameterization**: Essential for making the pipeline flexible, reusable, and adaptable to different scenarios.
- **Lookup Activities**: Crucial for fetching dynamic data and ensuring the pipeline runs efficiently.
- **Stored Procedures**: Effective for updating watermark tables and maintaining data integrity.
- **ADLS Gen2**: Provided a robust and scalable storage solution for managing large datasets.

## Next Steps

- **Monitoring and Optimization**: Continuous monitoring and optimization to ensure the pipeline runs smoothly.
- **Scalability**: Exploring ways to scale the solution for larger datasets and more complex scenarios.
- **Enhancements**: Adding more parameters and dynamic configurations to handle additional use cases.

## Contributing

Contributions are welcome! Please feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License.

---

You can copy and paste this content into a `README.md` file in your GitHub repository. This will provide a comprehensive guide for anyone looking to understand or replicate your incremental load process.
