# 🏦 Banking Demo - Follow Along Guide

*Build the banking demo alongside the presenter and explore Snowflake Cortex AI capabilities*

---

## 🎯 Demo Overview

In this hands-on session, you'll build a complete banking analytics environment using Snowflake Cortex AI and Semantic Models. You'll follow along with the presenter to:

1. **Set up the banking data model**
2. **Create semantic views for business users**
3. **Use Cortex Analyst for natural language queries**
4. **Build interactive dashboards**
5. **Explore advanced analytics capabilities**

---

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] **Environment Setup Complete** - Run the `demo_setup_notebook.py` script
- [ ] **Snowflake Access** - Logged into your Snowflake instance
- [ ] **Cortex Analyst Enabled** - Available in your Snowflake interface
- [ ] **Worksheet Ready** - New worksheet open for queries

---

## 🚀 Demo Flow

### Part 1: Data Model Exploration (10 minutes)

#### Step 1: Explore the Banking Data Structure

```sql
-- 1.1 View all tables in our banking schema
SHOW TABLES;

-- 1.2 Examine the customer dimension table
DESCRIBE TABLE customer_dim;

-- 1.3 Look at sample customer data
SELECT 
    customer_name,
    customer_type,
    customer_segment,
    region,
    risk_tier,
    industry_sector
FROM customer_dim
LIMIT 10;
```

**Expected Output:**
```
+------------------+------------------+------------------+------------------+------------------+------------------+
| CUSTOMER_NAME    | CUSTOMER_TYPE    | CUSTOMER_SEGMENT | REGION           | RISK_TIER        | INDUSTRY_SECTOR  |
+------------------+------------------+------------------+------------------+------------------+------------------+
| John Smith       | Retail           | Premium          | North            | Low              | Technology       |
| Acme Corporation | Corporate        | Premium          | South            | Medium           | Manufacturing    |
| Sarah Johnson    | Wealth Management| Premium          | East             | Low              | Healthcare       |
| ...              | ...              | ...              | ...              | ...              | ...              |
+------------------+------------------+------------------+------------------+------------------+------------------+
```

#### Step 2: Explore Account and Transaction Data

```sql
-- 2.1 View account types and balances
SELECT 
    account_type,
    product_line,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance
FROM account_dim
GROUP BY account_type, product_line
ORDER BY total_balance DESC;

-- 2.2 Analyze transaction patterns
SELECT 
    transaction_date,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM transaction_fact
GROUP BY transaction_date
ORDER BY transaction_date;
```

#### Step 3: Explore Loan Portfolio

```sql
-- 3.1 Loan portfolio overview
SELECT 
    loan_status,
    COUNT(*) as loan_count,
    SUM(loan_amount) as total_loan_amount,
    SUM(outstanding_balance) as total_outstanding,
    AVG(interest_rate) as avg_interest_rate
FROM loan_portfolio_fact
GROUP BY loan_status;

-- 3.2 Risk analysis by customer type
SELECT 
    c.customer_type,
    COUNT(l.loan_id) as loan_count,
    SUM(l.outstanding_balance) as total_exposure,
    AVG(l.interest_rate) as avg_rate,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans
FROM customer_dim c
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY c.customer_type;
```

---

### Part 2: Semantic Views Creation (15 minutes)

#### Step 1: Create Retail Banking Semantic View

```sql
-- Create a business-friendly view for retail banking
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
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_withdrawals,
    AVG(a.balance) as avg_balance
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
WHERE c.customer_type = 'Retail'
    AND a.product_line = 'Retail Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8;
```

**Test the view:**
```sql
-- Query the retail banking semantic view
SELECT 
    customer_name,
    customer_segment,
    account_type,
    balance,
    transaction_count,
    total_deposits,
    total_withdrawals
FROM retail_banking_semantic
LIMIT 5;
```

#### Step 2: Create Commercial Banking Semantic View

```sql
-- Create a business-friendly view for commercial banking
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
    SUM(l.outstanding_balance) as total_exposure,
    AVG(l.interest_rate) as avg_interest_rate
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
WHERE c.customer_type IN ('Small Business', 'Corporate')
    AND a.product_line = 'Commercial Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
```

**Test the view:**
```sql
-- Query the commercial banking semantic view
SELECT 
    customer_name,
    industry_sector,
    loan_count,
    total_exposure,
    avg_interest_rate,
    loan_status
FROM commercial_banking_semantic
WHERE loan_count > 0;
```

#### Step 3: Create Risk & Compliance Semantic View

```sql
-- Create a business-friendly view for risk and compliance
CREATE OR REPLACE VIEW risk_compliance_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.risk_tier,
    c.industry_sector,
    l.loan_status,
    l.days_past_due,
    l.outstanding_balance,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans,
    SUM(CASE WHEN l.loan_status = 'Default' THEN l.outstanding_balance ELSE 0 END) as defaulted_amount,
    COUNT(l.loan_id) as total_loans,
    CASE 
        WHEN COUNT(l.loan_id) > 0 THEN COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) * 100.0 / COUNT(l.loan_id)
        ELSE 0 
    END as npl_rate_percent
FROM customer_dim c
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY 1, 2, 3, 4, 5, 6, 7;
```

**Test the view:**
```sql
-- Query the risk and compliance semantic view
SELECT 
    customer_name,
    risk_tier,
    industry_sector,
    total_loans,
    defaulted_loans,
    npl_rate_percent
FROM risk_compliance_semantic
WHERE total_loans > 0
ORDER BY npl_rate_percent DESC;
```

---

### Part 3: Cortex Analyst Exploration (20 minutes)

#### Step 1: Access Cortex Analyst

1. **Navigate to Cortex Analyst** in your Snowflake interface
2. **Look for "Cortex Analyst"** in the left sidebar
3. **Click to open** the Cortex Analyst interface

#### Step 2: Test Simple Queries

Try these natural language queries in Cortex Analyst:

**Query 1:** "What was our total deposit growth last quarter by branch?"

**Query 2:** "Show me the number of new checking accounts opened this year by customer segment"

**Query 3:** "Which branches had the highest transaction volumes last month?"

#### Step 3: Test Complex Queries

**Query 4:** "What is our total commercial loan exposure by industry sector?"

**Query 5:** "Show me the average loan size by region and industry"

**Query 6:** "Which commercial customers have the highest credit utilization?"

#### Step 4: Test Risk & Compliance Queries

**Query 7:** "What is our non-performing loan rate by loan type and region?"

**Query 8:** "Show me our capital adequacy ratio trends over the past year"

**Query 9:** "Which customers have multiple accounts with high-risk indicators?"

#### Step 5: Test Wealth Management Queries

**Query 10:** "What is our total assets under management by investment type?"

**Query 11:** "Show me the top 10 wealth management clients by portfolio value"

**Query 12:** "Which investment products have the highest performance this year?"

---

### Part 4: Advanced Analytics (15 minutes)

#### Step 1: Customer 360 Analysis

```sql
-- Create a comprehensive customer view
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
LEFT JOIN transaction_fact t ON c.customer_id = t.customer_id
GROUP BY 1, 2, 3, 4, 5, 6, 7;
```

**Test the Customer 360 view:**
```sql
-- Query the customer 360 view
SELECT 
    customer_name,
    customer_type,
    total_accounts,
    total_balance,
    total_loans,
    total_loan_exposure,
    leverage_ratio
FROM customer_360
ORDER BY total_balance DESC
LIMIT 10;
```

#### Step 2: Cross-Domain Analysis

```sql
-- Analyze customer relationships across all business lines
SELECT 
    c.customer_type,
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) as customer_count,
    SUM(a.balance) as total_deposits,
    SUM(l.outstanding_balance) as total_loans,
    AVG(c.credit_score) as avg_credit_score,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY c.customer_type, c.customer_segment
ORDER BY total_deposits DESC;
```

#### Step 3: Risk Aggregation

```sql
-- Aggregate risk exposure across all business lines
SELECT 
    c.industry_sector,
    c.risk_tier,
    COUNT(DISTINCT c.customer_id) as customer_count,
    SUM(a.balance) as total_deposits,
    SUM(l.outstanding_balance) as total_loan_exposure,
    COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) as defaulted_loans,
    CASE 
        WHEN SUM(l.outstanding_balance) > 0 THEN COUNT(CASE WHEN l.loan_status = 'Default' THEN 1 END) * 100.0 / COUNT(l.loan_id)
        ELSE 0 
    END as npl_rate_percent
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY c.industry_sector, c.risk_tier
ORDER BY total_loan_exposure DESC;
```

---

### Part 5: Interactive Exploration (10 minutes)

#### Step 1: Try Your Own Queries

Now it's your turn! Try asking Cortex Analyst questions like:

- "What is the average account balance by customer segment?"
- "Which regions have the highest loan default rates?"
- "Show me customers with both checking accounts and loans"
- "What is our total exposure to the technology sector?"

#### Step 2: Explore the Semantic Views

Query the semantic views you created:

```sql
-- Explore retail banking patterns
SELECT * FROM retail_banking_semantic WHERE total_deposits > 1000;

-- Explore commercial banking exposure
SELECT * FROM commercial_banking_semantic WHERE total_exposure > 500000;

-- Explore risk patterns
SELECT * FROM risk_compliance_semantic WHERE npl_rate_percent > 0;
```

#### Step 3: Build Custom Analytics

Create your own custom queries and views:

```sql
-- Create a custom view for your specific analysis
CREATE OR REPLACE VIEW my_custom_analysis AS
SELECT 
    -- Add your custom logic here
    customer_name,
    customer_type,
    -- ... your custom fields
FROM customer_dim
-- ... your custom joins and filters;
```

---

## 🎯 Key Learning Objectives

By the end of this demo, you should understand:

1. **Data Modeling** - How to structure banking data for analytics
2. **Semantic Views** - Creating business-friendly data layers
3. **Cortex Analyst** - Natural language querying capabilities
4. **Cross-Domain Analysis** - Combining data from multiple business lines
5. **Risk Management** - Building risk and compliance analytics
6. **Customer 360** - Creating comprehensive customer views

---

## 🔧 Troubleshooting

### Common Issues:

**Issue:** Cortex Analyst not available
- **Solution:** Contact your Snowflake administrator to enable Cortex Analyst

**Issue:** Queries returning no results
- **Solution:** Check that your database context is set to `BANKING_AI_DEMO.BANKING_SCHEMA`

**Issue:** Permission errors
- **Solution:** Ensure you have SELECT privileges on all tables and views

**Issue:** Slow query performance
- **Solution:** Increase warehouse size temporarily: `ALTER WAREHOUSE Banking_Intelligence_demo_wh SET WAREHOUSE_SIZE = 'SMALL';`

---

## 📊 Expected Results

After completing this demo, you should have:

- ✅ **Complete banking data model** with sample data
- ✅ **4 semantic views** for different business domains
- ✅ **Customer 360 view** for comprehensive analysis
- ✅ **Experience with Cortex Analyst** natural language queries
- ✅ **Understanding of cross-domain analytics**
- ✅ **Working knowledge** of Snowflake Cortex AI capabilities

---

## 🧹 Cleanup (Optional)

After the demo, you can clean up your environment:

```sql
-- Drop the demo database and related objects
DROP DATABASE BANKING_AI_DEMO;
DROP WAREHOUSE Banking_Intelligence_demo_wh;
DROP ROLE BANKING_Intelligence_Demo;
```

---

**🎉 Congratulations! You've successfully built a complete banking analytics environment using Snowflake Cortex AI and Semantic Models!**

*This hands-on experience demonstrates the power of Snowflake's AI capabilities for banking and financial services analytics.* 