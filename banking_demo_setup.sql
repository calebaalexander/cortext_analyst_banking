-- Banking Demo Setup Script for Snowflake Cortex & Semantic Models
-- Adapted from NickAkincilar/Snowflake_AI_DEMO for banking presentation
-- This script creates a comprehensive banking demo environment

-- Create database and schema for banking demo
CREATE DATABASE IF NOT EXISTS BANKING_AI_DEMO;
USE DATABASE BANKING_AI_DEMO;
CREATE SCHEMA IF NOT EXISTS BANKING_SCHEMA;
USE SCHEMA BANKING_SCHEMA;

-- Create warehouse for banking demo
CREATE WAREHOUSE IF NOT EXISTS Banking_Intelligence_demo_wh
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Warehouse for Banking AI Demo';

-- Create role for banking demo
CREATE ROLE IF NOT EXISTS BANKING_Intelligence_Demo;
GRANT USAGE ON DATABASE BANKING_AI_DEMO TO ROLE BANKING_Intelligence_Demo;
GRANT USAGE ON SCHEMA BANKING_SCHEMA TO ROLE BANKING_Intelligence_Demo;
GRANT USAGE ON WAREHOUSE Banking_Intelligence_demo_wh TO ROLE BANKING_Intelligence_Demo;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA BANKING_SCHEMA TO ROLE BANKING_Intelligence_Demo;
GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA BANKING_SCHEMA TO ROLE BANKING_Intelligence_Demo;

-- Create banking-specific dimension tables

-- 1. Customer Dimension
CREATE OR REPLACE TABLE customer_dim (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_type VARCHAR(50), -- Retail, Small Business, Corporate, Wealth Management
    customer_segment VARCHAR(50), -- Premium, Standard, Basic
    region VARCHAR(50), -- North, South, East, West, Central
    city VARCHAR(50),
    state VARCHAR(2),
    risk_tier VARCHAR(20), -- Low, Medium, High, Very High
    industry_sector VARCHAR(50), -- Technology, Manufacturing, Healthcare, Energy, etc.
    created_date DATE,
    total_assets NUMBER(15,2),
    credit_score NUMBER(3),
    relationship_manager_id NUMBER
);

-- 2. Account Dimension
CREATE OR REPLACE TABLE account_dim (
    account_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    account_type VARCHAR(50), -- Checking, Savings, Credit Card, Loan, Investment
    product_line VARCHAR(50), -- Retail Banking, Commercial Banking, Wealth Management
    account_status VARCHAR(20), -- Active, Inactive, Suspended, Closed
    open_date DATE,
    close_date DATE,
    branch_id NUMBER,
    balance NUMBER(15,2),
    interest_rate NUMBER(5,4),
    monthly_fee NUMBER(10,2),
    overdraft_limit NUMBER(15,2)
);

-- 3. Product Dimension
CREATE OR REPLACE TABLE product_dim (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR(100),
    product_category VARCHAR(50), -- Deposit, Loan, Investment, Credit Card
    product_line VARCHAR(50), -- Retail, Commercial, Wealth Management
    interest_rate_type VARCHAR(20), -- Fixed, Variable, Tiered
    min_balance NUMBER(15,2),
    monthly_fee NUMBER(10,2),
    product_status VARCHAR(20) -- Active, Inactive, Discontinued
);

-- 4. Branch Dimension
CREATE OR REPLACE TABLE branch_dim (
    branch_id NUMBER PRIMARY KEY,
    branch_name VARCHAR(100),
    branch_code VARCHAR(10),
    region VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(2),
    manager_id NUMBER,
    branch_type VARCHAR(30), -- Full Service, Limited Service, Digital
    open_date DATE,
    total_deposits NUMBER(15,2),
    total_loans NUMBER(15,2)
);

-- 5. Employee Dimension
CREATE OR REPLACE TABLE employee_dim (
    employee_id NUMBER PRIMARY KEY,
    employee_name VARCHAR(100),
    job_title VARCHAR(100),
    department VARCHAR(50), -- Retail, Commercial, Risk, Compliance, IT
    branch_id NUMBER REFERENCES branch_dim(branch_id),
    hire_date DATE,
    salary NUMBER(10,2),
    manager_id NUMBER,
    employee_status VARCHAR(20) -- Active, Inactive, Terminated
);

-- 6. Region Dimension
CREATE OR REPLACE TABLE region_dim (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR(50),
    region_manager_id NUMBER,
    total_branches NUMBER,
    market_size VARCHAR(20) -- Small, Medium, Large
);

-- 7. Industry Dimension
CREATE OR REPLACE TABLE industry_dim (
    industry_id NUMBER PRIMARY KEY,
    industry_name VARCHAR(100),
    industry_sector VARCHAR(50),
    risk_level VARCHAR(20), -- Low, Medium, High
    regulatory_category VARCHAR(50)
);

-- 8. Risk Tier Dimension
CREATE OR REPLACE TABLE risk_tier_dim (
    risk_tier_id NUMBER PRIMARY KEY,
    risk_tier_name VARCHAR(20),
    risk_score_min NUMBER,
    risk_score_max NUMBER,
    interest_rate_adjustment NUMBER(5,4),
    credit_limit_multiplier NUMBER(5,2)
);

-- 9. Transaction Type Dimension
CREATE OR REPLACE TABLE transaction_type_dim (
    transaction_type_id NUMBER PRIMARY KEY,
    transaction_type_name VARCHAR(50),
    transaction_category VARCHAR(50), -- Deposit, Withdrawal, Transfer, Fee, Interest
    is_revenue BOOLEAN,
    is_expense BOOLEAN
);

-- 10. Loan Type Dimension
CREATE OR REPLACE TABLE loan_type_dim (
    loan_type_id NUMBER PRIMARY KEY,
    loan_type_name VARCHAR(100),
    loan_category VARCHAR(50), -- Personal, Business, Mortgage, Auto
    typical_term_months NUMBER,
    typical_interest_rate NUMBER(5,4),
    collateral_required BOOLEAN
);

-- 11. Investment Type Dimension
CREATE OR REPLACE TABLE investment_type_dim (
    investment_type_id NUMBER PRIMARY KEY,
    investment_type_name VARCHAR(100),
    asset_class VARCHAR(50), -- Equity, Fixed Income, Alternative, Cash
    risk_level VARCHAR(20),
    typical_return_rate NUMBER(5,4)
);

-- 12. Compliance Category Dimension
CREATE OR REPLACE TABLE compliance_category_dim (
    compliance_category_id NUMBER PRIMARY KEY,
    category_name VARCHAR(100),
    regulatory_framework VARCHAR(50), -- Basel III, CCAR, AML, KYC
    reporting_frequency VARCHAR(20), -- Daily, Weekly, Monthly, Quarterly
    risk_weight NUMBER(5,4)
);

-- 13. Channel Dimension
CREATE OR REPLACE TABLE channel_dim (
    channel_id NUMBER PRIMARY KEY,
    channel_name VARCHAR(50), -- Branch, ATM, Online, Mobile, Phone
    channel_type VARCHAR(30), -- Physical, Digital, Hybrid
    cost_per_transaction NUMBER(10,2),
    availability_hours VARCHAR(50)
);

-- Create banking-specific fact tables

-- 1. Transaction Fact Table
CREATE OR REPLACE TABLE transaction_fact (
    transaction_id NUMBER PRIMARY KEY,
    account_id NUMBER REFERENCES account_dim(account_id),
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    transaction_date DATE,
    transaction_type_id NUMBER REFERENCES transaction_type_dim(transaction_type_id),
    amount NUMBER(15,2),
    channel_id NUMBER REFERENCES channel_dim(channel_id),
    branch_id NUMBER REFERENCES branch_dim(branch_id),
    employee_id NUMBER REFERENCES employee_dim(employee_id),
    description VARCHAR(200),
    reference_number VARCHAR(50),
    is_fraudulent BOOLEAN DEFAULT FALSE
);

-- 2. Loan Portfolio Fact Table
CREATE OR REPLACE TABLE loan_portfolio_fact (
    loan_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    account_id NUMBER REFERENCES account_dim(account_id),
    loan_type_id NUMBER REFERENCES loan_type_dim(loan_type_id),
    loan_amount NUMBER(15,2),
    outstanding_balance NUMBER(15,2),
    interest_rate NUMBER(5,4),
    origination_date DATE,
    maturity_date DATE,
    payment_frequency VARCHAR(20), -- Monthly, Quarterly, Annually
    collateral_value NUMBER(15,2),
    risk_tier_id NUMBER REFERENCES risk_tier_dim(risk_tier_id),
    loan_status VARCHAR(20), -- Active, Default, Paid Off, Refinanced
    days_past_due NUMBER,
    industry_id NUMBER REFERENCES industry_dim(industry_id)
);

-- 3. Investment Portfolio Fact Table
CREATE OR REPLACE TABLE investment_portfolio_fact (
    investment_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    account_id NUMBER REFERENCES account_dim(account_id),
    investment_type_id NUMBER REFERENCES investment_type_dim(investment_type_id),
    investment_amount NUMBER(15,2),
    current_value NUMBER(15,2),
    purchase_date DATE,
    maturity_date DATE,
    expected_return_rate NUMBER(5,4),
    actual_return_rate NUMBER(5,4),
    risk_score NUMBER(3),
    portfolio_allocation_percent NUMBER(5,2),
    investment_status VARCHAR(20) -- Active, Matured, Sold, Defaulted
);

-- 4. Compliance Fact Table
CREATE OR REPLACE TABLE compliance_fact (
    compliance_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    account_id NUMBER REFERENCES account_dim(account_id),
    compliance_category_id NUMBER REFERENCES compliance_category_dim(compliance_category_id),
    reporting_date DATE,
    risk_weight NUMBER(5,4),
    capital_requirement NUMBER(15,2),
    regulatory_value NUMBER(15,2),
    compliance_status VARCHAR(20), -- Compliant, Non-Compliant, Pending Review
    audit_findings VARCHAR(500),
    corrective_actions VARCHAR(500)
);

-- Create Salesforce CRM integration tables

-- 1. Salesforce Customer Accounts
CREATE OR REPLACE TABLE sf_customer_accounts (
    sf_account_id VARCHAR(50) PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    account_name VARCHAR(100),
    account_type VARCHAR(50),
    industry VARCHAR(50),
    annual_revenue NUMBER(15,2),
    employee_count NUMBER,
    billing_city VARCHAR(50),
    billing_state VARCHAR(2),
    created_date DATE,
    last_activity_date DATE,
    account_status VARCHAR(20)
);

-- 2. Salesforce Loan Applications
CREATE OR REPLACE TABLE sf_loan_applications (
    sf_opportunity_id VARCHAR(50) PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    loan_type VARCHAR(50),
    loan_amount NUMBER(15,2),
    application_date DATE,
    expected_close_date DATE,
    probability_percent NUMBER(5,2),
    stage VARCHAR(50), -- Prospecting, Qualification, Proposal, Negotiation, Closed Won, Closed Lost
    lead_source VARCHAR(50),
    campaign_id VARCHAR(50),
    sales_rep_id NUMBER REFERENCES employee_dim(employee_id)
);

-- 3. Salesforce Investment Opportunities
CREATE OR REPLACE TABLE sf_investment_opportunities (
    sf_opportunity_id VARCHAR(50) PRIMARY KEY,
    customer_id NUMBER REFERENCES customer_dim(customer_id),
    investment_type VARCHAR(50),
    investment_amount NUMBER(15,2),
    opportunity_date DATE,
    expected_close_date DATE,
    probability_percent NUMBER(5,2),
    stage VARCHAR(50),
    lead_source VARCHAR(50),
    campaign_id VARCHAR(50),
    wealth_manager_id NUMBER REFERENCES employee_dim(employee_id)
);

-- Insert sample banking data

-- Insert sample customers
INSERT INTO customer_dim VALUES
(1001, 'John Smith', 'Retail', 'Premium', 'North', 'New York', 'NY', 'Low', 'Technology', '2020-01-15', 50000, 750, 101),
(1002, 'Acme Corporation', 'Corporate', 'Premium', 'South', 'Atlanta', 'GA', 'Medium', 'Manufacturing', '2019-03-20', 2500000, 680, 102),
(1003, 'Sarah Johnson', 'Wealth Management', 'Premium', 'East', 'Boston', 'MA', 'Low', 'Healthcare', '2021-06-10', 1500000, 800, 103),
(1004, 'Bob\'s Hardware Store', 'Small Business', 'Standard', 'West', 'Los Angeles', 'CA', 'Medium', 'Retail', '2020-11-05', 750000, 720, 104),
(1005, 'Global Energy Corp', 'Corporate', 'Premium', 'Central', 'Chicago', 'IL', 'High', 'Energy', '2018-09-12', 5000000, 650, 105),
(1006, 'Mary Wilson', 'Retail', 'Standard', 'North', 'New York', 'NY', 'Low', 'Education', '2021-02-28', 75000, 780, 101),
(1007, 'Tech Startup Inc', 'Small Business', 'Standard', 'East', 'Boston', 'MA', 'High', 'Technology', '2022-01-15', 300000, 700, 103),
(1008, 'Elite Wealth Partners', 'Wealth Management', 'Premium', 'South', 'Atlanta', 'GA', 'Low', 'Finance', '2019-12-01', 3000000, 820, 102);

-- Insert sample branches
INSERT INTO branch_dim VALUES
(1, 'Downtown Main Branch', 'DT001', 'North', 'New York', 'NY', 101, 'Full Service', '2010-01-01', 50000000, 75000000),
(2, 'Southside Plaza Branch', 'SP002', 'South', 'Atlanta', 'GA', 102, 'Full Service', '2012-03-15', 35000000, 45000000),
(3, 'East Coast Financial Center', 'EC003', 'East', 'Boston', 'MA', 103, 'Full Service', '2011-06-20', 40000000, 60000000),
(4, 'West Valley Branch', 'WV004', 'West', 'Los Angeles', 'CA', 104, 'Limited Service', '2015-09-10', 25000000, 30000000),
(5, 'Central Hub Branch', 'CH005', 'Central', 'Chicago', 'IL', 105, 'Full Service', '2009-12-01', 60000000, 90000000);

-- Insert sample employees
INSERT INTO employee_dim VALUES
(101, 'Michael Brown', 'Branch Manager', 'Retail', 1, '2010-01-15', 85000, NULL, 'Active'),
(102, 'Jennifer Davis', 'Commercial Lending Manager', 'Commercial', 2, '2012-03-20', 95000, NULL, 'Active'),
(103, 'Robert Wilson', 'Wealth Management Director', 'Wealth Management', 3, '2011-06-25', 120000, NULL, 'Active'),
(104, 'Lisa Anderson', 'Branch Manager', 'Retail', 4, '2015-09-15', 80000, NULL, 'Active'),
(105, 'David Miller', 'Regional Director', 'Retail', 5, '2009-12-01', 110000, NULL, 'Active');

-- Insert sample accounts
INSERT INTO account_dim VALUES
(2001, 1001, 'Checking', 'Retail Banking', 'Active', '2020-01-15', NULL, 1, 5000, 0.01, 0, 1000),
(2002, 1001, 'Savings', 'Retail Banking', 'Active', '2020-01-15', NULL, 1, 15000, 0.025, 0, 0),
(2003, 1002, 'Business Checking', 'Commercial Banking', 'Active', '2019-03-20', NULL, 2, 500000, 0.005, 25, 50000),
(2004, 1003, 'Investment Account', 'Wealth Management', 'Active', '2021-06-10', NULL, 3, 1500000, 0.03, 0, 0),
(2005, 1004, 'Business Loan', 'Commercial Banking', 'Active', '2020-11-05', NULL, 4, -250000, 0.065, 0, 0),
(2006, 1005, 'Corporate Account', 'Commercial Banking', 'Active', '2018-09-12', NULL, 5, 2000000, 0.01, 100, 100000),
(2007, 1006, 'Checking', 'Retail Banking', 'Active', '2021-02-28', NULL, 1, 3000, 0.01, 0, 500),
(2008, 1007, 'Business Checking', 'Commercial Banking', 'Active', '2022-01-15', NULL, 3, 100000, 0.005, 15, 10000),
(2009, 1008, 'Private Banking', 'Wealth Management', 'Active', '2019-12-01', NULL, 2, 3000000, 0.035, 0, 0);

-- Insert sample transactions
INSERT INTO transaction_fact VALUES
(3001, 2001, 1001, '2024-01-15', 1, 1000, 1, 1, 101, 'Salary deposit', 'TXN001', FALSE),
(3002, 2001, 1001, '2024-01-16', 2, -500, 2, 1, 101, 'ATM withdrawal', 'TXN002', FALSE),
(3003, 2002, 1001, '2024-01-15', 5, 75, 1, 1, 101, 'Monthly interest', 'TXN003', FALSE),
(3004, 2003, 1002, '2024-01-15', 1, 50000, 1, 2, 102, 'Business deposit', 'TXN004', FALSE),
(3005, 2004, 1003, '2024-01-15', 3, 100000, 1, 3, 103, 'Investment transfer', 'TXN005', FALSE),
(3006, 2005, 1004, '2024-01-15', 4, -2500, 1, 4, 104, 'Loan payment', 'TXN006', FALSE),
(3007, 2006, 1005, '2024-01-15', 1, 100000, 1, 5, 105, 'Corporate deposit', 'TXN007', FALSE),
(3008, 2007, 1006, '2024-01-15', 1, 2000, 1, 1, 101, 'Salary deposit', 'TXN008', FALSE),
(3009, 2008, 1007, '2024-01-15', 1, 25000, 1, 3, 103, 'Business deposit', 'TXN009', FALSE),
(3010, 2009, 1008, '2024-01-15', 5, 1500, 1, 2, 102, 'Investment income', 'TXN010', FALSE);

-- Insert sample loan portfolio
INSERT INTO loan_portfolio_fact VALUES
(4001, 1001, 2001, 1, 300000, 280000, 0.045, '2020-02-01', '2050-02-01', 'Monthly', 350000, 1, 'Active', 0, 1),
(4002, 1002, 2003, 2, 1000000, 950000, 0.065, '2019-04-01', '2029-04-01', 'Monthly', 1200000, 2, 'Active', 0, 1),
(4003, 1004, 2005, 2, 250000, 240000, 0.075, '2020-12-01', '2025-12-01', 'Monthly', 300000, 2, 'Active', 0, 3),
(4004, 1005, 2006, 2, 2000000, 1900000, 0.055, '2018-10-01', '2028-10-01', 'Monthly', 2500000, 1, 'Active', 0, 4),
(4005, 1006, 2007, 1, 25000, 23000, 0.085, '2021-03-01', '2026-03-01', 'Monthly', 0, 2, 'Active', 0, 5),
(4006, 1007, 2008, 2, 150000, 150000, 0.080, '2022-02-01', '2027-02-01', 'Monthly', 180000, 3, 'Default', 90, 1);

-- Create banking semantic views

-- 1. Retail Banking Semantic View
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
    b.branch_name,
    b.region as branch_region,
    COUNT(t.transaction_id) as transaction_count,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as total_deposits,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_withdrawals,
    AVG(a.balance) as avg_balance
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
JOIN branch_dim b ON a.branch_id = b.branch_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
WHERE c.customer_type = 'Retail'
    AND a.product_line = 'Retail Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

-- 2. Commercial Banking Semantic View
CREATE OR REPLACE VIEW commercial_banking_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.industry_sector,
    c.region,
    c.risk_tier,
    l.loan_type_id,
    l.loan_amount,
    l.outstanding_balance,
    l.interest_rate,
    l.loan_status,
    l.days_past_due,
    a.balance as account_balance,
    COUNT(l.loan_id) as loan_count,
    SUM(l.outstanding_balance) as total_exposure,
    AVG(l.interest_rate) as avg_interest_rate
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
WHERE c.customer_type IN ('Small Business', 'Corporate')
    AND a.product_line = 'Commercial Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12;

-- 3. Risk & Compliance Semantic View
CREATE OR REPLACE VIEW risk_compliance_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.risk_tier,
    c.industry_sector,
    l.loan_status,
    l.days_past_due,
    l.outstanding_balance,
    comp.compliance_status,
    comp.risk_weight,
    comp.capital_requirement,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans,
    SUM(CASE WHEN l.loan_status = 'Default' THEN l.outstanding_balance ELSE 0 END) as defaulted_amount,
    COUNT(l.loan_id) as total_loans,
    CASE 
        WHEN COUNT(l.loan_id) > 0 THEN COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) * 100.0 / COUNT(l.loan_id)
        ELSE 0 
    END as npl_rate_percent
FROM customer_dim c
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
LEFT JOIN compliance_fact comp ON c.customer_id = comp.customer_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

-- 4. Wealth Management Semantic View
CREATE OR REPLACE VIEW wealth_management_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.region,
    i.investment_type_id,
    i.investment_amount,
    i.current_value,
    i.expected_return_rate,
    i.actual_return_rate,
    i.risk_score,
    a.balance as account_balance,
    COUNT(i.investment_id) as investment_count,
    SUM(i.current_value) as total_portfolio_value,
    AVG(i.actual_return_rate) as avg_return_rate,
    SUM(i.current_value - i.investment_amount) as total_gains_losses
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN investment_portfolio_fact i ON c.customer_id = i.customer_id
WHERE c.customer_type = 'Wealth Management'
    AND a.product_line = 'Wealth Management'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;

-- Create calculated metrics views

-- 1. Net Interest Margin
CREATE OR REPLACE VIEW net_interest_margin AS
SELECT 
    DATE_TRUNC('quarter', t.transaction_date) as quarter,
    SUM(CASE WHEN t.amount > 0 AND t.transaction_type_id = 5 THEN t.amount ELSE 0 END) as interest_income,
    SUM(CASE WHEN t.amount < 0 AND t.transaction_type_id = 5 THEN ABS(t.amount) ELSE 0 END) as interest_expense,
    SUM(CASE WHEN t.amount > 0 AND t.transaction_type_id = 5 THEN t.amount ELSE 0 END) - 
    SUM(CASE WHEN t.amount < 0 AND t.transaction_type_id = 5 THEN ABS(t.amount) ELSE 0 END) as net_interest_income,
    AVG(a.balance) as avg_earning_assets,
    CASE 
        WHEN AVG(a.balance) > 0 THEN 
            (SUM(CASE WHEN t.amount > 0 AND t.transaction_type_id = 5 THEN t.amount ELSE 0 END) - 
             SUM(CASE WHEN t.amount < 0 AND t.transaction_type_id = 5 THEN ABS(t.amount) ELSE 0 END)) / AVG(a.balance)
        ELSE 0 
    END as net_interest_margin
FROM transaction_fact t
JOIN account_dim a ON t.account_id = a.account_id
WHERE t.transaction_type_id = 5
GROUP BY 1;

-- 2. Non-Performing Loan Rate
CREATE OR REPLACE VIEW npl_rate AS
SELECT 
    c.region,
    c.industry_sector,
    COUNT(l.loan_id) as total_loans,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans,
    SUM(l.outstanding_balance) as total_loan_amount,
    SUM(CASE WHEN l.loan_status = 'Default' THEN l.outstanding_balance ELSE 0 END) as defaulted_amount,
    CASE 
        WHEN COUNT(l.loan_id) > 0 THEN COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) * 100.0 / COUNT(l.loan_id)
        ELSE 0 
    END as npl_rate_percent,
    CASE 
        WHEN SUM(l.outstanding_balance) > 0 THEN SUM(CASE WHEN l.loan_status = 'Default' THEN l.outstanding_balance ELSE 0 END) * 100.0 / SUM(l.outstanding_balance)
        ELSE 0 
    END as npl_amount_percent
FROM customer_dim c
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY 1, 2;

-- 3. Customer 360 View
CREATE OR REPLACE VIEW customer_360 AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.customer_segment,
    c.region,
    c.risk_tier,
    c.industry_sector,
    COUNT(DISTINCT a.account_id) as total_accounts,
    SUM(a.balance) as total_balance,
    COUNT(DISTINCT l.loan_id) as total_loans,
    SUM(l.outstanding_balance) as total_loan_exposure,
    COUNT(DISTINCT i.investment_id) as total_investments,
    SUM(i.current_value) as total_investment_value,
    COUNT(t.transaction_id) as total_transactions,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as total_deposits,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_withdrawals,
    CASE 
        WHEN SUM(a.balance) > 0 THEN SUM(l.outstanding_balance) / SUM(a.balance)
        ELSE 0 
    END as leverage_ratio
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
LEFT JOIN investment_portfolio_fact i ON c.customer_id = i.customer_id
LEFT JOIN transaction_fact t ON c.customer_id = t.customer_id
GROUP BY 1, 2, 3, 4, 5, 6, 7;

-- Grant permissions for demo
GRANT USAGE ON DATABASE BANKING_AI_DEMO TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA BANKING_SCHEMA TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA BANKING_SCHEMA TO ROLE PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA BANKING_SCHEMA TO ROLE PUBLIC;

-- Create sample queries for Cortex Analyst demo

-- Example 1: Total deposits by branch
-- "What was our total deposit growth last quarter by branch?"
SELECT 
    b.branch_name,
    b.region,
    SUM(a.balance) as total_deposits,
    COUNT(DISTINCT c.customer_id) as customer_count
FROM branch_dim b
JOIN account_dim a ON b.branch_id = a.branch_id
JOIN customer_dim c ON a.customer_id = c.customer_id
WHERE a.account_type IN ('Checking', 'Savings')
    AND a.account_status = 'Active'
GROUP BY b.branch_id, b.branch_name, b.region
ORDER BY total_deposits DESC;

-- Example 2: New accounts by customer segment
-- "Show me the number of new checking accounts opened this year by customer segment"
SELECT 
    c.customer_segment,
    COUNT(*) as new_accounts
FROM account_dim a
JOIN customer_dim c ON a.customer_id = c.customer_id
WHERE a.account_type = 'Checking'
    AND a.open_date >= '2024-01-01'
GROUP BY c.customer_segment
ORDER BY new_accounts DESC;

-- Example 3: Commercial loan exposure by industry
-- "What is our total commercial loan exposure by industry sector?"
SELECT 
    c.industry_sector,
    COUNT(l.loan_id) as loan_count,
    SUM(l.outstanding_balance) as total_exposure,
    AVG(l.interest_rate) as avg_interest_rate,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans
FROM customer_dim c
JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
WHERE c.customer_type IN ('Small Business', 'Corporate')
    AND l.loan_status = 'Active'
GROUP BY c.industry_sector
ORDER BY total_exposure DESC;

-- Example 4: NPL rates by region
-- "What is our non-performing loan rate by loan type and region?"
SELECT 
    c.region,
    lt.loan_type_name,
    COUNT(l.loan_id) as total_loans,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans,
    CASE 
        WHEN COUNT(l.loan_id) > 0 THEN COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) * 100.0 / COUNT(l.loan_id)
        ELSE 0 
    END as npl_rate_percent
FROM customer_dim c
JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
JOIN loan_type_dim lt ON l.loan_type_id = lt.loan_type_id
GROUP BY c.region, lt.loan_type_id, lt.loan_type_name
ORDER BY npl_rate_percent DESC;

-- Example 5: Wealth management portfolio performance
-- "What is our total assets under management by investment type?"
SELECT 
    it.investment_type_name,
    it.asset_class,
    COUNT(i.investment_id) as investment_count,
    SUM(i.current_value) as total_aum,
    AVG(i.actual_return_rate) as avg_return_rate,
    SUM(i.current_value - i.investment_amount) as total_gains_losses
FROM investment_portfolio_fact i
JOIN investment_type_dim it ON i.investment_type_id = it.investment_type_id
WHERE i.investment_status = 'Active'
GROUP BY it.investment_type_id, it.investment_type_name, it.asset_class
ORDER BY total_aum DESC;

-- Example 6: Customer 360 analysis
-- "Show me a complete view of customer John Smith across all our banking relationships"
SELECT 
    c.customer_name,
    c.customer_type,
    c.customer_segment,
    c.risk_tier,
    COUNT(DISTINCT a.account_id) as total_accounts,
    SUM(a.balance) as total_balance,
    COUNT(DISTINCT l.loan_id) as total_loans,
    SUM(l.outstanding_balance) as total_loan_exposure,
    COUNT(DISTINCT i.investment_id) as total_investments,
    SUM(i.current_value) as total_investment_value,
    COUNT(t.transaction_id) as total_transactions
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
LEFT JOIN investment_portfolio_fact i ON c.customer_id = i.customer_id
LEFT JOIN transaction_fact t ON c.customer_id = t.customer_id
WHERE c.customer_name = 'John Smith'
GROUP BY c.customer_id, c.customer_name, c.customer_type, c.customer_segment, c.risk_tier; 