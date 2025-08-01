# Banking Demo Setup

In this Notebook, we will **set up a complete banking analytics environment** in Snowflake that demonstrates Cortex Analyst capabilities. This environment will include realistic banking data, semantic views, and sample queries that showcase how financial institutions can leverage Snowflake's AI capabilities for data-driven insights.

There are several components we're creating in this solution:
- **Infrastructure**: Database, schema, warehouse, and role setup
- **Git Integration**: Loading data directly from GitHub repository
- **Semantic views**: Business-friendly data models for different banking domains

**Why use this approach?**\
By using Snowflake's Git integration, we can load fresh data directly from the source repository, ensuring everyone has the latest version. This approach is more maintainable and allows for easy updates to the demo data.

**What will be created?**\
We'll create a complete data model with banking data loaded from GitHub that demonstrates how Cortex Analyst can answer natural language questions about customer relationships, transaction patterns, loan portfolios, and risk metrics.

---

## Environment Setup

Let's start by checking your current Snowflake environment and ensuring you have the necessary privileges to create the banking demo.

-- Check current environment
SELECT 
    CURRENT_ROLE() as current_role, 
    CURRENT_USER() as current_user, 
    CURRENT_ACCOUNT() as current_account;

---

## Database & Schema Creation

Now we'll create the foundation for our banking demo environment.

-- Create banking demo database and schema
CREATE DATABASE IF NOT EXISTS BANKING_AI_DEMO;
USE DATABASE BANKING_AI_DEMO;
CREATE SCHEMA IF NOT EXISTS BANKING_SCHEMA;
USE SCHEMA BANKING_SCHEMA;

---

## Warehouse Setup

Setting up a dedicated warehouse for optimal performance during the demo.

-- Create dedicated warehouse for banking demo
CREATE WAREHOUSE IF NOT EXISTS Banking_Intelligence_demo_wh
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Warehouse for Banking AI Demo';

---

## Role & Permissions

Setting up proper access controls for the demo environment.

-- Create role and grant permissions
CREATE ROLE IF NOT EXISTS BANKING_Intelligence_Demo;

GRANT USAGE ON DATABASE BANKING_AI_DEMO TO ROLE BANKING_Intelligence_Demo;
GRANT USAGE ON SCHEMA BANKING_SCHEMA TO ROLE BANKING_Intelligence_Demo;
GRANT USAGE ON WAREHOUSE Banking_Intelligence_demo_wh TO ROLE BANKING_Intelligence_Demo;

---

## Load Banking Data via Snowflake UI

Now we'll load the banking data using Snowflake's web interface. This is the simplest approach for demos and doesn't require any special setup.

### Step 1: Download Data Files

First, download the CSV files from the GitHub repository:

1. **Customer Data**: [customer_dim.csv](https://raw.githubusercontent.com/calebaalexander/cortext_analyst_banking/main/customer_dim.csv)
2. **Account Data**: [account_dim.csv](https://raw.githubusercontent.com/calebaalexander/cortext_analyst_banking/main/account_dim.csv)
3. **Transaction Data**: [finance_transactions.csv](https://raw.githubusercontent.com/calebaalexander/cortext_analyst_banking/main/finance_transactions.csv)

### Step 2: Create Tables in Snowflake

Create the table structures in Snowflake:

-- Create customer dimension table
CREATE OR REPLACE TABLE customer_dim (
    customer_id NUMBER,
    customer_name VARCHAR(100),
    customer_type VARCHAR(50),
    customer_segment VARCHAR(50),
    region VARCHAR(50),
    risk_tier VARCHAR(20),
    industry_sector VARCHAR(50),
    total_assets NUMBER,
    credit_score NUMBER,
    account_open_date DATE,
    last_activity_date DATE,
    status VARCHAR(20)
);

-- Create account dimension table
CREATE OR REPLACE TABLE account_dim (
    account_id STRING,
    customer_id NUMBER,
    account_type VARCHAR(50),
    product_line VARCHAR(50),
    account_status VARCHAR(20),
    balance NUMBER,
    open_date DATE,
    last_transaction_date DATE,
    interest_rate NUMBER,
    overdraft_limit NUMBER,
    account_manager VARCHAR(100),
    region VARCHAR(50)
);

-- Create transaction fact table
CREATE OR REPLACE TABLE transaction_fact (
    transaction_id STRING,
    account_id STRING,
    customer_id NUMBER,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount NUMBER,
    description VARCHAR(200),
    merchant_category VARCHAR(50),
    transaction_status VARCHAR(20),
    reference_number VARCHAR(50),
    channel VARCHAR(50),
    region VARCHAR(50)
);

### Step 3: Upload Data via Snowflake UI

1. **Navigate to your database and schema** in the Snowflake web interface
2. **Select the table** you want to load (e.g., `customer_dim`)
3. **Click "Load Data"** button
4. **Choose "Upload Files"** option
5. **Select your CSV file** and upload
6. **Configure the file format**:
   - **File Format**: CSV
   - **Field Delimiter**: Comma (,)
   - **Skip Header**: 1 row
   - **Date Format**: YYYY-MM-DD
7. **Preview the data** to ensure it looks correct
8. **Click "Load"** to import the data

### Step 4: Verify Data Load

After uploading each file, verify the data was loaded correctly:

**Note**: If you see account IDs with commas (like `1,001`), you can force them to display without commas by casting them to STRING in your queries:

-- Check customer data
SELECT COUNT(*) as customer_count FROM customer_dim;
SELECT * FROM customer_dim LIMIT 5;

-- Check account data
SELECT COUNT(*) as account_count FROM account_dim;
SELECT * FROM account_dim LIMIT 5;

-- Alternative: Display account IDs without commas
SELECT 
    CAST(account_id AS STRING) as account_id,
    customer_id,
    account_type,
    product_line,
    balance
FROM account_dim 
LIMIT 5;

-- Check transaction data
SELECT COUNT(*) as transaction_count FROM transaction_fact;
SELECT * FROM transaction_fact LIMIT 5;

-- Alternative: Display transaction IDs without commas
SELECT 
    CAST(transaction_id AS STRING) as transaction_id,
    CAST(account_id AS STRING) as account_id,
    customer_id,
    transaction_date,
    transaction_type,
    amount,
    description
FROM transaction_fact 
LIMIT 5;

### Alternative: Quick Sample Data

If you prefer to start with sample data for the demo, you can run these commands instead:

-- Insert sample customer data
INSERT INTO customer_dim VALUES
(1, 'Acme Corporation', 'Corporate', 'Premium', 'North America', 'Low', 'Technology', 5000000, 750, '2020-01-15', '2024-01-15', 'Active'),
(2, 'Global Manufacturing Inc', 'Corporate', 'Enterprise', 'North America', 'Medium', 'Manufacturing', 2500000, 680, '2019-03-22', '2024-01-14', 'Active'),
(3, 'Smith Family Trust', 'Wealth Management', 'Ultra High Net Worth', 'North America', 'Low', 'Investment', 15000000, 800, '2018-11-08', '2024-01-15', 'Active'),
(4, 'Main Street Bakery', 'Small Business', 'Commercial', 'North America', 'Medium', 'Food & Beverage', 750000, 650, '2021-06-10', '2024-01-13', 'Active'),
(5, 'Johnson & Associates', 'Small Business', 'Professional Services', 'North America', 'Low', 'Consulting', 1200000, 720, '2020-09-15', '2024-01-15', 'Active');

-- Insert sample account data
INSERT INTO account_dim VALUES
('1001', 1, 'Checking', 'Commercial Banking', 'Active', 1250000.00, '2020-01-15', '2024-01-15', 0.01, 50000.00, 'John Smith', 'North America'),
('1002', 1, 'Savings', 'Commercial Banking', 'Active', 2500000.00, '2020-01-15', '2024-01-15', 0.025, 0.00, 'John Smith', 'North America'),
('1003', 1, 'Loan', 'Commercial Banking', 'Active', -5000000.00, '2020-02-01', '2024-01-15', 0.045, 0.00, 'John Smith', 'North America'),
('1004', 2, 'Checking', 'Commercial Banking', 'Active', 750000.00, '2019-03-22', '2024-01-14', 0.01, 25000.00, 'Sarah Johnson', 'North America'),
('1005', 2, 'Savings', 'Commercial Banking', 'Active', 1200000.00, '2019-03-22', '2024-01-14', 0.025, 0.00, 'Sarah Johnson', 'North America'),
('1006', 3, 'Investment', 'Wealth Management', 'Active', 15000000.00, '2018-11-08', '2024-01-15', 0.035, 0.00, 'Michael Brown', 'North America'),
('1007', 3, 'Trust', 'Wealth Management', 'Active', 5000000.00, '2018-11-08', '2024-01-15', 0.03, 0.00, 'Michael Brown', 'North America'),
('1008', 4, 'Checking', 'Small Business Banking', 'Active', 150000.00, '2021-06-10', '2024-01-13', 0.01, 10000.00, 'Lisa Davis', 'North America'),
('1009', 4, 'Savings', 'Small Business Banking', 'Active', 300000.00, '2021-06-10', '2024-01-13', 0.02, 0.00, 'Lisa Davis', 'North America'),
('1010', 5, 'Checking', 'Small Business Banking', 'Active', 250000.00, '2020-09-15', '2024-01-15', 0.01, 15000.00, 'Robert Wilson', 'North America');

-- Insert sample transaction data
INSERT INTO transaction_fact VALUES
('2001', '1001', 1, '2024-01-15', 'Deposit', 50000.00, 'Wire Transfer - Client Payment', 'Wire Transfer', 'Completed', 'WT20240115001', 'Online', 'North America'),
('2002', '1001', 1, '2024-01-15', 'Withdrawal', -15000.00, 'ACH Payment - Vendor Invoice', 'ACH', 'Completed', 'ACH20240115002', 'Online', 'North America'),
('2003', '1002', 1, '2024-01-15', 'Deposit', 25000.00, 'Interest Payment', 'Interest', 'Completed', 'INT20240115003', 'System', 'North America'),
('2004', '1003', 1, '2024-01-15', 'Payment', -50000.00, 'Loan Payment - Principal', 'Loan Payment', 'Completed', 'LP20240115004', 'Online', 'North America'),
('2005', '1004', 2, '2024-01-14', 'Deposit', 75000.00, 'Check Deposit', 'Check', 'Completed', 'CHK20240114005', 'Branch', 'North America'),
('2006', '1005', 2, '2024-01-14', 'Deposit', 30000.00, 'Interest Payment', 'Interest', 'Completed', 'INT20240114006', 'System', 'North America'),
('2007', '1006', 3, '2024-01-15', 'Deposit', 750000.00, 'Investment Contribution', 'Investment', 'Completed', 'INV20240115007', 'Online', 'North America'),
('2008', '1007', 3, '2024-01-15', 'Deposit', 100000.00, 'Trust Income', 'Trust', 'Completed', 'TRU20240115008', 'System', 'North America'),
('2009', '1008', 4, '2024-01-13', 'Deposit', 15000.00, 'Cash Deposit', 'Cash', 'Completed', 'CASH20240113009', 'Branch', 'North America'),
('2010', '1009', 4, '2024-01-13', 'Deposit', 6000.00, 'Interest Payment', 'Interest', 'Completed', 'INT20240113010', 'System', 'North America');

-- Create loan portfolio data using existing data
CREATE OR REPLACE TABLE loan_portfolio_fact AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY customer_id) as loan_id,
    customer_id,
    NULL as account_id,
    'Commercial Real Estate' as loan_type,
    total_assets * 0.8 as loan_amount,
    total_assets * 0.7 as outstanding_balance,
    0.045 + (RANDOM() % 10) * 0.01 as interest_rate,
    DATEADD(day, -RANDOM() % 1000, CURRENT_DATE()) as origination_date,
    DATEADD(day, 365 * 30, CURRENT_DATE()) as maturity_date,
    'Monthly' as payment_frequency,
    total_assets * 0.9 as collateral_value,
    risk_tier,
    'Active' as loan_status,
    0 as days_past_due,
    industry_sector,
    region
FROM customer_dim
WHERE customer_type IN ('Corporate', 'Small Business')
LIMIT 50;

---

## Create Semantic Views

Now we'll create business-friendly semantic views that provide a clean interface for Cortex Analyst queries. These views combine data from multiple tables and present it in a way that makes sense to business users.

-- Create retail banking semantic view
CREATE OR REPLACE VIEW retail_banking_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.region,
    c.risk_tier,
    a.account_type,
    a.balance,
    a.open_date,
    COUNT(t.transaction_id) as transaction_count,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as total_deposits,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_withdrawals
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
WHERE c.customer_type = 'Retail'
    AND a.product_line = 'Retail Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8;

-- Create commercial banking semantic view
CREATE OR REPLACE VIEW commercial_banking_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.industry_sector,
    c.region,
    c.risk_tier,
    l.loan_amount,
    l.outstanding_balance,
    l.interest_rate,
    l.loan_status,
    a.balance as account_balance,
    COUNT(l.loan_id) as loan_count,
    SUM(l.outstanding_balance) as total_exposure
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
WHERE c.customer_type IN ('Small Business', 'Corporate')
    AND a.product_line = 'Commercial Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

---

## Setup Verification

Let's verify that all our tables and views have been created correctly and contain the expected data.

-- List all created objects
SHOW TABLES;
SHOW VIEWS;

-- Verify data counts
SELECT 
    'customer_dim' as table_name, COUNT(*) as record_count FROM customer_dim
UNION ALL
SELECT 'account_dim', COUNT(*) FROM account_dim
UNION ALL
SELECT 'transaction_fact', COUNT(*) FROM transaction_fact
UNION ALL
SELECT 'loan_portfolio_fact', COUNT(*) FROM loan_portfolio_fact;

---

## Sample Test Queries

Now let's test some sample queries to ensure everything is working correctly and to demonstrate the types of questions you can ask with Cortex Analyst.

-- Test customer overview
SELECT 
    customer_name,
    customer_type,
    customer_segment,
    region,
    total_assets
FROM customer_dim
ORDER BY total_assets DESC
LIMIT 10;

-- Test account balances
SELECT 
    account_type,
    product_line,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance
FROM account_dim
GROUP BY account_type, product_line
ORDER BY total_balance DESC;

-- Test semantic view
SELECT 
    customer_name,
    customer_segment,
    account_type,
    balance,
    transaction_count,
    total_deposits
FROM retail_banking_semantic
ORDER BY total_deposits DESC
LIMIT 10;

---

## Cortex Analyst Testing

Now that our semantic views are ready, you can test them using Cortex Analyst. Navigate to the Cortex Analyst interface in your Snowflake environment and try these natural language queries:

**Example Questions:**
- "What is the total transaction amount for retail customers?"
- "How many active commercial loans do we have?"
- "What is the average account balance by customer segment?"
- "Show me customers with the highest total deposits"
- "What is our total loan exposure by industry sector?"

**Important**: Ensure your current role has access to `BANKING_AI_DEMO.BANKING_SCHEMA` and Cortex Analyst is enabled for your account.

---

## Setup Complete

**Congratulations!** Your Snowflake banking demo environment is now fully set up and ready for use.

**What's been created:**
- **Database**: `BANKING_AI_DEMO` with schema `BANKING_SCHEMA`
- **Warehouse**: `Banking_Intelligence_demo_wh` for compute resources
- **Git Integration**: Connected to the demo repository
- **Tables**: 4 tables with banking data loaded from GitHub
- **Views**: 2 semantic views for business-friendly queries
- **Role**: `BANKING_Intelligence_Demo` for access control

**Next steps:**
1. **Explore the data** using the Snowflake UI
2. **Test Cortex Analyst** with natural language queries
3. **Connect BI tools** to the semantic views for dashboards
4. **Follow along** with the demo presentation

**Cleanup (optional):** After the demo, you can clean up by running:

DROP DATABASE BANKING_AI_DEMO;
DROP WAREHOUSE Banking_Intelligence_demo_wh;
DROP ROLE BANKING_Intelligence_Demo;

You're all set for the banking demo! 🏦✨ 