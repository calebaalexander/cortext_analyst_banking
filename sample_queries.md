# 🏦 Banking Sample Queries

## 📋 **Overview**

This file contains comprehensive banking-specific queries organized by business domain. Use these examples to demonstrate Cortex Analyst capabilities and provide reference for common banking analytics scenarios.

---

## 🏦 **Retail Banking Queries**

### **Customer Analysis**

-- Customer segmentation analysis
SELECT 
    customer_segment,
    COUNT(*) as customer_count,
    AVG(total_assets) as avg_assets,
    AVG(credit_score) as avg_credit_score
FROM customer_dim
WHERE customer_type = 'Retail'
GROUP BY customer_segment
ORDER BY avg_assets DESC;

-- High-value customer identification
SELECT 
    customer_name,
    customer_segment,
    total_assets,
    credit_score,
    region
FROM customer_dim
WHERE customer_type = 'Retail'
    AND total_assets > 1000000
ORDER BY total_assets DESC;

### **Account Performance**

-- Account balance analysis by type
SELECT 
    account_type,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance,
    MIN(balance) as min_balance,
    MAX(balance) as max_balance
FROM account_dim
WHERE product_line = 'Retail Banking'
GROUP BY account_type
ORDER BY total_balance DESC;

-- Account growth trends
SELECT 
    DATE_TRUNC('month', open_date) as month,
    COUNT(*) as new_accounts,
    SUM(balance) as new_balance
FROM account_dim
WHERE product_line = 'Retail Banking'
    AND open_date >= DATEADD(month, -12, CURRENT_DATE())
GROUP BY month
ORDER BY month;

### **Transaction Analysis**

-- Transaction volume by channel
SELECT 
    channel,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM transaction_fact t
JOIN account_dim a ON t.account_id = a.account_id
WHERE a.product_line = 'Retail Banking'
GROUP BY channel
ORDER BY total_amount DESC;

-- Monthly transaction trends
SELECT 
    DATE_TRUNC('month', transaction_date) as month,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    COUNT(DISTINCT customer_id) as unique_customers
FROM transaction_fact
WHERE transaction_date >= DATEADD(month, -6, CURRENT_DATE())
GROUP BY month
ORDER BY month;

---

## 🏢 **Commercial Banking Queries**

### **Loan Portfolio Analysis**

-- Loan exposure by industry
SELECT 
    industry_sector,
    COUNT(*) as loan_count,
    SUM(loan_amount) as total_loan_amount,
    SUM(outstanding_balance) as total_outstanding,
    AVG(interest_rate) as avg_interest_rate
FROM loan_portfolio_fact l
JOIN customer_dim c ON l.customer_id = c.customer_id
WHERE c.customer_type IN ('Corporate', 'Small Business')
GROUP BY industry_sector
ORDER BY total_outstanding DESC;

-- Risk tier analysis
SELECT 
    risk_tier,
    COUNT(*) as loan_count,
    SUM(loan_amount) as total_loan_amount,
    SUM(outstanding_balance) as total_outstanding,
    AVG(interest_rate) as avg_interest_rate,
    (SUM(outstanding_balance) / SUM(loan_amount)) * 100 as utilization_rate
FROM loan_portfolio_fact
GROUP BY risk_tier
ORDER BY total_outstanding DESC;

### **Commercial Account Analysis**

-- Commercial account balances
SELECT 
    customer_type,
    account_type,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance
FROM account_dim a
JOIN customer_dim c ON a.customer_id = c.customer_id
WHERE c.customer_type IN ('Corporate', 'Small Business')
GROUP BY customer_type, account_type
ORDER BY total_balance DESC;

-- Account manager performance
SELECT 
    account_manager,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance,
    COUNT(DISTINCT customer_id) as unique_customers
FROM account_dim
WHERE product_line = 'Commercial Banking'
GROUP BY account_manager
ORDER BY total_balance DESC;

---

## 🎯 **Risk & Compliance Queries**

### **Credit Risk Analysis**

-- High-risk customer identification
SELECT 
    customer_name,
    customer_type,
    total_assets,
    credit_score,
    risk_tier,
    COUNT(a.account_id) as account_count,
    SUM(a.balance) as total_balance
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
WHERE credit_score < 650 OR risk_tier = 'High'
GROUP BY 1, 2, 3, 4, 5
ORDER BY credit_score ASC;

-- Concentration risk analysis
SELECT 
    industry_sector,
    COUNT(*) as customer_count,
    SUM(total_assets) as total_exposure,
    AVG(credit_score) as avg_credit_score,
    COUNT(CASE WHEN credit_score < 650 THEN 1 END) as high_risk_customers
FROM customer_dim
WHERE customer_type IN ('Corporate', 'Small Business')
GROUP BY industry_sector
ORDER BY total_exposure DESC;

### **Transaction Monitoring**

-- Large transaction identification
SELECT 
    transaction_id,
    customer_id,
    transaction_date,
    transaction_type,
    amount,
    channel,
    description
FROM transaction_fact
WHERE ABS(amount) > 100000
ORDER BY ABS(amount) DESC;

-- Unusual transaction patterns
SELECT 
    customer_id,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount,
    COUNT(DISTINCT channel) as channels_used
FROM transaction_fact
WHERE transaction_date >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY customer_id
HAVING transaction_count > 50 OR ABS(total_amount) > 500000
ORDER BY transaction_count DESC;

---

## 💰 **Wealth Management Queries**

### **Investment Portfolio Analysis**

-- High net worth customer analysis
SELECT 
    customer_name,
    customer_segment,
    total_assets,
    credit_score,
    COUNT(a.account_id) as account_count,
    SUM(a.balance) as total_balance
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
WHERE customer_type = 'Wealth Management'
    AND total_assets > 10000000
GROUP BY 1, 2, 3, 4
ORDER BY total_assets DESC;

-- Investment account performance
SELECT 
    account_type,
    COUNT(*) as account_count,
    SUM(balance) as total_balance,
    AVG(balance) as avg_balance,
    AVG(interest_rate) as avg_interest_rate
FROM account_dim
WHERE product_line = 'Wealth Management'
GROUP BY account_type
ORDER BY total_balance DESC;

### **Portfolio Diversification**

-- Customer portfolio complexity
SELECT 
    customer_name,
    customer_segment,
    COUNT(DISTINCT a.account_id) as account_count,
    COUNT(DISTINCT a.account_type) as account_types,
    SUM(a.balance) as total_balance,
    COUNT(DISTINCT t.transaction_id) as transaction_count
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
WHERE c.customer_type = 'Wealth Management'
GROUP BY 1, 2
ORDER BY total_balance DESC;

---

## 🌐 **Cross-Domain Intelligence Queries**

### **Customer 360 Analysis**

-- Comprehensive customer view
SELECT 
    c.customer_name,
    c.customer_type,
    c.customer_segment,
    c.industry_sector,
    c.total_assets,
    c.credit_score,
    COUNT(DISTINCT a.account_id) as total_accounts,
    SUM(a.balance) as total_balance,
    COUNT(DISTINCT t.transaction_id) as total_transactions,
    COUNT(DISTINCT l.loan_id) as total_loans,
    SUM(l.outstanding_balance) as total_loan_exposure
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY total_assets DESC;

### **Regional Performance Analysis**

-- Regional business performance
SELECT 
    c.region,
    COUNT(DISTINCT c.customer_id) as customer_count,
    COUNT(DISTINCT a.account_id) as account_count,
    SUM(a.balance) as total_balance,
    COUNT(DISTINCT t.transaction_id) as transaction_count,
    SUM(t.amount) as total_transaction_amount,
    COUNT(DISTINCT l.loan_id) as loan_count,
    SUM(l.outstanding_balance) as total_loan_exposure
FROM customer_dim c
LEFT JOIN account_dim a ON c.customer_id = a.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
LEFT JOIN loan_portfolio_fact l ON c.customer_id = l.customer_id
GROUP BY c.region
ORDER BY total_balance DESC;

### **Product Line Performance**

-- Product line profitability analysis
SELECT 
    a.product_line,
    COUNT(DISTINCT c.customer_id) as customer_count,
    COUNT(DISTINCT a.account_id) as account_count,
    SUM(a.balance) as total_balance,
    AVG(a.balance) as avg_balance,
    COUNT(DISTINCT t.transaction_id) as transaction_count,
    SUM(t.amount) as total_transaction_amount
FROM account_dim a
JOIN customer_dim c ON a.customer_id = c.customer_id
LEFT JOIN transaction_fact t ON a.account_id = t.account_id
GROUP BY a.product_line
ORDER BY total_balance DESC;

---

## 🤖 **Cortex Analyst Natural Language Examples**

### **Customer Questions**
- "What is the total number of customers by type?"
- "Show me customers with the highest total assets"
- "What is the average credit score by customer segment?"
- "Which customers have multiple accounts?"
- "Show me customers with low credit scores but high assets"

### **Account Questions**
- "What is the total balance across all accounts?"
- "Show me account distribution by type and product line"
- "Which account managers have the most accounts?"
- "What is the average account balance by region?"
- "Show me accounts with declining balances"

### **Transaction Questions**
- "What is the total transaction volume by channel?"
- "Show me the largest transactions this month"
- "What is the average transaction amount by type?"
- "Which customers have the highest transaction activity?"
- "Show me unusual transaction patterns"

### **Risk & Compliance Questions**
- "Which customers have multiple accounts with high balances?"
- "Show me customers that might need enhanced due diligence"
- "What is our exposure to high-risk industries?"
- "Which customers have unusual transaction patterns?"
- "Show me our concentration risk by industry"

### **Performance Questions**
- "What is our most profitable customer segment?"
- "Show me growth opportunities in underpenetrated segments"
- "Which regions have the highest growth in deposits?"
- "What is our total loan exposure by industry sector?"
- "Show me customers with the highest credit utilization"

### **Cross-Domain Questions**
- "Show me customers with high assets but low transaction activity"
- "Which customers have both large deposits and significant loan exposure?"
- "What is our concentration risk by industry and region?"
- "Show me account managers with the most diverse portfolios"
- "What is our exposure to high-risk industries by region?"

---

## 📊 **Key Performance Indicators (KPIs)**

### **Customer KPIs**
- Total customer count by segment
- Average customer assets by type
- Customer acquisition rate
- Customer retention rate
- Average credit score by segment

### **Account KPIs**
- Total account balance by product line
- Average account balance by type
- Account growth rate
- Account utilization rate
- Account manager performance

### **Transaction KPIs**
- Total transaction volume by channel
- Average transaction amount by type
- Transaction frequency by customer
- Channel adoption rates
- Transaction growth trends

### **Risk KPIs**
- Non-performing loan rate
- Credit concentration by industry
- High-risk customer count
- Average credit score by risk tier
- Loan utilization rates

### **Performance KPIs**
- Revenue by product line
- Customer profitability by segment
- Regional performance metrics
- Account manager productivity
- Portfolio diversification metrics

---

**Use these queries as a starting point and customize them for your specific banking environment and use cases!** 🏦✨ 