# 🏦 Snowflake Banking Demo - Customer Setup Guide

*Follow along with the live banking demonstration by setting up your own Snowflake environment*

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Demo Data Installation](#demo-data-installation)
- [Verification Steps](#verification-steps)
- [Troubleshooting](#troubleshooting)
- [Presentation Preparation](#presentation-preparation)

---

## ✅ Prerequisites

Before you begin, ensure you have:

- [ ] **Snowflake Account Access**
  - Active Snowflake account with admin privileges
  - Access to create databases, warehouses, and roles
  - Web browser access to Snowflake interface

- [ ] **Cortex Analyst Enabled**
  - Verify Cortex Analyst is available in your Snowflake instance
  - Contact your Snowflake administrator if not enabled

- [ ] **Basic SQL Knowledge**
  - Familiarity with basic SQL commands
  - Understanding of database concepts

- [ ] **Presentation Materials**
  - Access to the demo repository: [https://github.com/calebaalexander/cortext_analyst_banking.git](https://github.com/calebaalexander/cortext_analyst_banking.git)
  - Copy of the `banking_demo_setup.sql` script

---

## 🚀 Environment Setup

### Step 1: Access Snowflake Web Interface

1. **Open your web browser** and navigate to your Snowflake instance
2. **Sign in** with your credentials
3. **Navigate to Worksheets** in the left sidebar

### Step 2: Create New Worksheet

1. **Click "New Worksheet"** or the "+" button
2. **Name your worksheet**: `Banking Demo Setup`
3. **Set your context** to ensure you're in the right account/region

### Step 3: Verify Your Role and Permissions

```sql
-- Check your current role and permissions
SHOW ROLES;
SHOW GRANTS TO ROLE YOUR_ROLE_NAME;

-- Ensure you have the following privileges:
-- CREATE DATABASE
-- CREATE WAREHOUSE
-- CREATE ROLE
-- CREATE SCHEMA
-- CREATE TABLE
-- CREATE VIEW
```

**Expected Output:**
```
+------------------+------------------+------------------+
| ROLE             | PRIVILEGE        | GRANTED_ON       |
+------------------+------------------+------------------+
| YOUR_ROLE_NAME   | CREATE DATABASE  | ACCOUNT          |
| YOUR_ROLE_NAME   | CREATE WAREHOUSE | ACCOUNT          |
| YOUR_ROLE_NAME   | CREATE ROLE      | ACCOUNT          |
+------------------+------------------+------------------+
```

---

## 📊 Demo Data Installation

### Step 1: Copy the Setup Script

1. **Open the setup script**: `banking_demo_setup.sql`
2. **Copy the entire contents** of the file
3. **Paste into your Snowflake worksheet**

### Step 2: Execute the Setup Script

1. **Select all the SQL code** in your worksheet
2. **Click "Run"** or press Ctrl+Enter (Cmd+Enter on Mac)
3. **Monitor the execution** - this may take 2-3 minutes

**What the script creates:**
- Database: `BANKING_AI_DEMO`
- Schema: `BANKING_SCHEMA`
- Warehouse: `Banking_Intelligence_demo_wh`
- Role: `BANKING_Intelligence_Demo`
- 13 dimension tables
- 4 fact tables
- 4 semantic views
- Sample data for all tables

### Step 3: Monitor Progress

Watch for these success messages:
```
✅ Database BANKING_AI_DEMO created successfully
✅ Schema BANKING_SCHEMA created successfully
✅ Warehouse Banking_Intelligence_demo_wh created successfully
✅ Role BANKING_Intelligence_Demo created successfully
✅ All tables created successfully
✅ Sample data inserted successfully
✅ Semantic views created successfully
```

---

## 🔍 Verification Steps

### Step 1: Verify Database Creation

```sql
-- Check that the database was created
SHOW DATABASES LIKE 'BANKING_AI_DEMO';

-- Use the database
USE DATABASE BANKING_AI_DEMO;
USE SCHEMA BANKING_SCHEMA;
```

**Expected Output:**
```
+------------------+------------------+------------------+
| DATABASE_NAME    | OWNER            | COMMENT          |
+------------------+------------------+------------------+
| BANKING_AI_DEMO  | YOUR_ROLE_NAME   |                  |
+------------------+------------------+------------------+
```

### Step 2: Verify Tables Created

```sql
-- Check all tables were created
SHOW TABLES;

-- You should see 17 tables:
-- customer_dim, account_dim, product_dim, branch_dim, employee_dim,
-- region_dim, industry_dim, risk_tier_dim, transaction_type_dim,
-- loan_type_dim, investment_type_dim, compliance_category_dim,
-- channel_dim, transaction_fact, loan_portfolio_fact,
-- investment_portfolio_fact, compliance_fact
```

**Expected Output:**
```
+------------------+------------------+------------------+
| TABLE_NAME       | TABLE_TYPE       | COMMENT          |
+------------------+------------------+------------------+
| CUSTOMER_DIM     | TABLE            |                  |
| ACCOUNT_DIM      | TABLE            |                  |
| PRODUCT_DIM      | TABLE            |                  |
| ...              | ...              | ...              |
+------------------+------------------+------------------+
```

### Step 3: Verify Sample Data

```sql
-- Check sample data was loaded
SELECT COUNT(*) as customer_count FROM customer_dim;
SELECT COUNT(*) as account_count FROM account_dim;
SELECT COUNT(*) as transaction_count FROM transaction_fact;
SELECT COUNT(*) as loan_count FROM loan_portfolio_fact;
```

**Expected Output:**
```
+------------------+
| CUSTOMER_COUNT   |
+------------------+
| 8                |
+------------------+

+------------------+
| ACCOUNT_COUNT    |
+------------------+
| 9                |
+------------------+

+---------------------+
| TRANSACTION_COUNT   |
+---------------------+
| 10                  |
+---------------------+

+------------------+
| LOAN_COUNT       |
+------------------+
| 6                |
+------------------+
```

### Step 4: Verify Semantic Views

```sql
-- Check semantic views were created
SHOW VIEWS;

-- You should see 4 semantic views:
-- retail_banking_semantic, commercial_banking_semantic,
-- risk_compliance_semantic, wealth_management_semantic
```

**Expected Output:**
```
+---------------------------+------------------+------------------+
| VIEW_NAME                 | OWNER            | COMMENT          |
+---------------------------+------------------+------------------+
| RETAIL_BANKING_SEMANTIC   | YOUR_ROLE_NAME   |                  |
| COMMERCIAL_BANKING_SEMANTIC | YOUR_ROLE_NAME |                  |
| RISK_COMPLIANCE_SEMANTIC  | YOUR_ROLE_NAME   |                  |
| WEALTH_MANAGEMENT_SEMANTIC | YOUR_ROLE_NAME  |                  |
+---------------------------+------------------+------------------+
```

### Step 5: Test Sample Queries

```sql
-- Test a simple query
SELECT 
    customer_name,
    customer_type,
    customer_segment,
    region
FROM customer_dim
LIMIT 5;
```

**Expected Output:**
```
+------------------+------------------+------------------+------------------+
| CUSTOMER_NAME    | CUSTOMER_TYPE    | CUSTOMER_SEGMENT | REGION           |
+------------------+------------------+------------------+------------------+
| John Smith       | Retail           | Premium          | North            |
| Acme Corporation | Corporate        | Premium          | South            |
| Sarah Johnson    | Wealth Management| Premium          | East             |
| Bob's Hardware Store | Small Business | Standard        | West             |
| Global Energy Corp | Corporate      | Premium          | Central          |
+------------------+------------------+------------------+------------------+
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Issue 1: "Insufficient privileges" Error

**Problem:** You don't have permission to create databases/warehouses

**Solution:**
```sql
-- Contact your Snowflake administrator to grant these privileges:
GRANT CREATE DATABASE ON ACCOUNT TO ROLE YOUR_ROLE_NAME;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE YOUR_ROLE_NAME;
GRANT CREATE ROLE ON ACCOUNT TO ROLE YOUR_ROLE_NAME;
```

#### Issue 2: "Cortex Analyst not available" Error

**Problem:** Cortex Analyst is not enabled in your Snowflake instance

**Solution:**
- Contact your Snowflake administrator
- Verify your Snowflake edition supports Cortex Analyst
- Ensure Cortex Analyst is enabled for your account

#### Issue 3: "Table already exists" Error

**Problem:** Tables from a previous setup attempt still exist

**Solution:**
```sql
-- Drop existing database and recreate
DROP DATABASE IF EXISTS BANKING_AI_DEMO;
-- Then re-run the setup script
```

#### Issue 4: "Warehouse not found" Error

**Problem:** Warehouse was not created or is suspended

**Solution:**
```sql
-- Check warehouse status
SHOW WAREHOUSES LIKE 'Banking_Intelligence_demo_wh';

-- Resume warehouse if suspended
ALTER WAREHOUSE Banking_Intelligence_demo_wh RESUME;
```

#### Issue 5: "Role not found" Error

**Problem:** Role was not created or you don't have access

**Solution:**
```sql
-- Check if role exists
SHOW ROLES LIKE 'BANKING_Intelligence_Demo';

-- Grant role to your user if needed
GRANT ROLE BANKING_Intelligence_Demo TO USER YOUR_USERNAME;
```

### Performance Optimization

If queries are running slowly:

```sql
-- Increase warehouse size temporarily
ALTER WAREHOUSE Banking_Intelligence_demo_wh SET WAREHOUSE_SIZE = 'SMALL';

-- After demo, return to XSMALL
ALTER WAREHOUSE Banking_Intelligence_demo_wh SET WAREHOUSE_SIZE = 'XSMALL';
```

---

## 🎯 Presentation Preparation

### Before the Presentation

1. **Test Cortex Analyst Access**
   ```sql
   -- Navigate to Cortex Analyst in Snowflake
   -- Look for "Cortex Analyst" in the left sidebar
   -- If not visible, contact your administrator
   ```

2. **Prepare Sample Questions**
   - Have these questions ready to test during the demo:
     - "What was our total deposit growth last quarter by branch?"
     - "Show me the number of new checking accounts opened this year"
     - "What is our non-performing loan rate by region?"

3. **Familiarize Yourself with the Data**
   ```sql
   -- Explore the data structure
   DESCRIBE TABLE customer_dim;
   DESCRIBE TABLE transaction_fact;
   DESCRIBE TABLE loan_portfolio_fact;
   ```

### During the Presentation

1. **Follow Along with Queries**
   - Execute the same queries as demonstrated
   - Compare your results with the presenter's results
   - Note any differences or questions

2. **Test Your Own Queries**
   - Try asking questions in natural language
   - Experiment with different banking scenarios
   - Explore the semantic views

3. **Take Notes**
   - Document any issues or questions
   - Note interesting features or capabilities
   - Record potential use cases for your organization

### After the Presentation

1. **Clean Up (Optional)**
   ```sql
   -- If you want to remove the demo environment
   DROP DATABASE BANKING_AI_DEMO;
   DROP WAREHOUSE Banking_Intelligence_demo_wh;
   DROP ROLE BANKING_Intelligence_Demo;
   ```

2. **Document Learnings**
   - Review your notes
   - Identify potential applications in your organization
   - Prepare questions for follow-up discussions

---

## 📞 Support Resources

### Snowflake Documentation
- [Cortex Analyst Documentation](https://docs.snowflake.com/en/user-guide/cortex-analyst)
- [Semantic Models Guide](https://docs.snowflake.com/en/user-guide/semantic-models)
- [SQL Reference](https://docs.snowflake.com/en/sql-reference)

### Demo Repository
- [Banking Demo Repository](https://github.com/calebaalexander/cortext_analyst_banking.git)
- Complete setup scripts and documentation
- Sample queries and scenarios

### Contact Information
- **Snowflake Support**: Contact your Snowflake administrator
- **Demo Questions**: Ask during the presentation Q&A session
- **Technical Issues**: Use the troubleshooting section above

---

## ✅ Setup Checklist

- [ ] Snowflake account access verified
- [ ] Cortex Analyst enabled and accessible
- [ ] Setup script executed successfully
- [ ] Database and tables created
- [ ] Sample data loaded
- [ ] Semantic views created
- [ ] Test queries executed successfully
- [ ] Ready to follow along with the presentation

---

**🎉 You're all set! Enjoy the banking demo presentation!**

*This guide ensures you have a fully functional Snowflake environment to follow along with the live demonstration of Snowflake Cortex AI and Semantic Models in banking.* 