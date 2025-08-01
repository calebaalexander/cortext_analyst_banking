# 🏦 Hands-On Banking Demo Guide

## 📋 **Demo Overview**

This hands-on guide walks you through a comprehensive banking demonstration using Snowflake Cortex Analyst and Semantic Models. The demo is structured to showcase real-world banking scenarios and demonstrate the power of natural language querying.

**Duration**: 35 minutes  
**Audience**: Banking executives, data leaders, and technical teams  
**Prerequisites**: Completed SQL setup from `banking_demo_notebook.md`

---

## 🎯 **Part 1: Setting the Stage - Show Banking Data Infrastructure**

### **Objective**: Explore the banking data model and understand the data relationships

#### **Step 1: Review Data Model Structure**

Start by understanding the banking data architecture:

-- Explore the complete data model
SELECT 
    'customer_dim' as table_name, COUNT(*) as record_count FROM customer_dim
UNION ALL
SELECT 'account_dim', COUNT(*) FROM account_dim
UNION ALL
SELECT 'transaction_fact', COUNT(*) FROM transaction_fact
UNION ALL
SELECT 'loan_portfolio_fact', COUNT(*) FROM loan_portfolio_fact;

#### **Step 2: Examine Customer Data**

-- Review customer distribution across banking segments
SELECT 
    customer_type,
    customer_segment,
    COUNT(*) as customer_count,
    AVG(total_assets) as avg_assets,
    AVG(credit_score) as avg_credit_score
FROM customer_dim
GROUP BY customer_type, customer_segment
ORDER BY customer_type, avg_assets DESC;

#### **Step 3: Analyze Account Portfolio**

-- Review account distribution and balances
SELECT 
    account_type,
    product_line,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance
FROM account_dim
GROUP BY account_type, product_line
ORDER BY total_balance DESC;

#### **Step 4: Explore Transaction Patterns**

-- Analyze transaction activity by channel and type
SELECT 
    channel,
    transaction_type,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM transaction_fact
GROUP BY channel, transaction_type
ORDER BY total_amount DESC;

---

## 🏗️ **Part 2: Semantic Models - Demonstrate Banking Metrics and KPIs**

### **Objective**: Create business-friendly semantic views and define banking-specific metrics

#### **Step 1: Create Retail Banking Semantic View**

-- Create comprehensive retail banking view
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
    (total_deposits - total_withdrawals) as net_flow
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
WHERE c.customer_type = 'Retail'
    AND a.product_line = 'Retail Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8;

#### **Step 2: Create Commercial Banking Semantic View**

-- Create comprehensive commercial banking view
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
    (l.outstanding_balance / l.loan_amount) * 100 as utilization_rate
FROM customer_dim c
JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
WHERE c.customer_type IN ('Small Business', 'Corporate')
    AND a.product_line = 'Commercial Banking'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

#### **Step 3: Test Semantic Views**

-- Test retail banking semantic view
SELECT 
    customer_name,
    customer_segment,
    account_type,
    balance,
    transaction_count,
    total_deposits,
    net_flow
FROM retail_banking_semantic
ORDER BY total_deposits DESC
LIMIT 10;

-- Test commercial banking semantic view
SELECT 
    customer_name,
    industry_sector,
    loan_amount,
    outstanding_balance,
    utilization_rate,
    total_exposure
FROM commercial_banking_semantic
ORDER BY total_exposure DESC
LIMIT 10;

---

## 🤖 **Part 3: Cortex Analyst - Natural Language Queries for Banking**

### **Objective**: Demonstrate how business users can ask questions in natural language

#### **Step 1: Basic Banking Questions**

Navigate to Cortex Analyst in your Snowflake environment and try these questions:

**Customer Analysis:**
- "What is the total number of customers by type?"
- "Show me customers with the highest total assets"
- "What is the average credit score by customer segment?"

**Account Analysis:**
- "What is the total balance across all accounts?"
- "Show me account distribution by type and product line"
- "Which account managers have the most accounts?"

**Transaction Analysis:**
- "What is the total transaction volume by channel?"
- "Show me the largest transactions this month"
- "What is the average transaction amount by type?"

#### **Step 2: Banking-Specific Questions**

**Retail Banking:**
- "What is our total deposit growth by customer segment?"
- "Show me the number of new accounts opened this year"
- "Which customers have the highest transaction activity?"

**Commercial Banking:**
- "What is our total loan exposure by industry sector?"
- "Show me customers with the highest credit utilization"
- "What is the average loan size by region?"

#### **Step 3: Complex Banking Scenarios**

**Risk Analysis:**
- "Which customers have multiple accounts with high balances?"
- "Show me customers with low credit scores but high assets"
- "What is our exposure to high-risk industries?"

**Performance Analysis:**
- "What is our most profitable customer segment?"
- "Show me accounts with declining balances"
- "Which regions have the highest growth in deposits?"

---

## 🌐 **Part 4: Cross-Domain Intelligence - Complex Banking Scenarios**

### **Objective**: Demonstrate complex multi-domain banking analysis

#### **Step 1: Customer 360 Analysis**

-- Create comprehensive customer view
CREATE OR REPLACE VIEW customer_360_semantic AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.customer_segment,
    c.industry_sector,
    c.region,
    c.risk_tier,
    c.total_assets,
    c.credit_score,
    COUNT(DISTINCT a.account_id) as total_accounts,
    SUM(a.balance) as total_balance,
    COUNT(DISTINCT t.transaction_id) as total_transactions,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as total_deposits,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_withdrawals,
    COUNT(DISTINCT l.loan_id) as total_loans,
    SUM(l.outstanding_balance) as total_loan_exposure,
    CASE 
        WHEN c.total_assets > 10000000 THEN 'Ultra High Net Worth'
        WHEN c.total_assets > 1000000 THEN 'High Net Worth'
        WHEN c.total_assets > 100000 THEN 'Affluent'
        ELSE 'Standard'
    END as wealth_tier
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

#### **Step 2: Test Customer 360 View**

-- Analyze customer portfolio complexity
SELECT 
    customer_name,
    customer_type,
    wealth_tier,
    total_accounts,
    total_balance,
    total_transactions,
    total_loan_exposure,
    (total_loan_exposure / NULLIF(total_assets, 0)) * 100 as leverage_ratio
FROM customer_360_semantic
ORDER BY total_balance DESC
LIMIT 10;

#### **Step 3: Cross-Domain Cortex Analyst Queries**

Try these complex questions in Cortex Analyst:

**Portfolio Management:**
- "Show me customers with high assets but low transaction activity"
- "Which customers have both large deposits and significant loan exposure?"
- "What is our concentration risk by industry and region?"

**Regulatory & Compliance:**
- "Show me customers that might need enhanced due diligence"
- "What is our exposure to high-risk industries by region?"
- "Which customers have unusual transaction patterns?"

**Business Intelligence:**
- "What is our most profitable customer segment by product line?"
- "Show me growth opportunities in underpenetrated segments"
- "Which account managers have the most diverse portfolios?"

---

## 🎯 **Demo Wrap-Up**

### **Key Takeaways**

1. **Data Democratization**: Business users can access insights without SQL expertise
2. **Consistent Metrics**: Semantic models ensure everyone uses the same definitions
3. **Real-Time Insights**: Immediate answers to complex banking questions
4. **Cross-Domain Analysis**: Seamless integration across all banking business lines

### **Next Steps**

1. **Explore Additional Scenarios**: Try your own banking-specific questions
2. **Customize for Your Environment**: Adapt the data model to your specific needs
3. **Connect BI Tools**: Integrate with Tableau, Power BI, or other visualization tools
4. **Scale the Solution**: Extend to production data and additional use cases

### **Success Metrics**

- **Time to Insight**: Reduced from days to seconds
- **User Adoption**: Business users can self-serve analytics
- **Data Consistency**: Single source of truth across all reporting
- **Operational Efficiency**: Reduced IT backlog for custom reports

---

**Congratulations!** You've successfully completed the hands-on banking demo and experienced the power of Snowflake Cortex Analyst and Semantic Models in a real-world financial services context. 🏦✨ 