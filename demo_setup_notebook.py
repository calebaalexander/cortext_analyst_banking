# Snowflake Banking Demo - Automated Setup Notebook
# Run this notebook to automatically set up your Snowflake environment

import snowflake.connector
import pandas as pd
import time
from IPython.display import display, HTML, Markdown

# =============================================================================
# CONFIGURATION SECTION
# =============================================================================

# Update these values with your Snowflake credentials
SNOWFLAKE_CONFIG = {
    'user': 'YOUR_USERNAME',
    'password': 'YOUR_PASSWORD',  # Or use environment variables for security
    'account': 'YOUR_ACCOUNT',    # e.g., 'xy12345.us-east-1'
    'warehouse': 'COMPUTE_WH',    # Default warehouse for setup
    'database': 'BANKING_AI_DEMO',
    'schema': 'BANKING_SCHEMA'
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def create_connection():
    """Create Snowflake connection"""
    try:
        conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
        print("✅ Successfully connected to Snowflake!")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return None

def execute_sql(conn, sql, description=""):
    """Execute SQL and return results"""
    try:
        cursor = conn.cursor()
        cursor.execute(sql)
        
        # Try to fetch results if it's a SELECT statement
        try:
            results = cursor.fetchall()
            if results:
                return results
        except:
            pass
        
        cursor.close()
        print(f"✅ {description}")
        return True
    except Exception as e:
        print(f"❌ Error executing SQL: {e}")
        return False

def check_prerequisites(conn):
    """Check if user has necessary privileges"""
    print("🔍 Checking prerequisites...")
    
    checks = [
        ("CREATE DATABASE", "SHOW GRANTS TO ROLE CURRENT_ROLE() LIKE 'CREATE DATABASE'"),
        ("CREATE WAREHOUSE", "SHOW GRANTS TO ROLE CURRENT_ROLE() LIKE 'CREATE WAREHOUSE'"),
        ("CREATE ROLE", "SHOW GRANTS TO ROLE CURRENT_ROLE() LIKE 'CREATE ROLE'")
    ]
    
    all_good = True
    for privilege, sql in checks:
        result = execute_sql(conn, sql, f"Checking {privilege} privilege")
        if not result:
            all_good = False
            print(f"⚠️  Missing {privilege} privilege")
    
    return all_good

# =============================================================================
# SETUP SCRIPT
# =============================================================================

def setup_banking_demo():
    """Main setup function"""
    print("🏦 Setting up Snowflake Banking Demo Environment")
    print("=" * 60)
    
    # Step 1: Connect to Snowflake
    print("\n1️⃣ Connecting to Snowflake...")
    conn = create_connection()
    if not conn:
        return False
    
    # Step 2: Check prerequisites
    print("\n2️⃣ Checking prerequisites...")
    if not check_prerequisites(conn):
        print("❌ Prerequisites not met. Please contact your Snowflake administrator.")
        return False
    
    # Step 3: Create database and schema
    print("\n3️⃣ Creating database and schema...")
    setup_queries = [
        ("CREATE DATABASE IF NOT EXISTS BANKING_AI_DEMO", "Database created"),
        ("USE DATABASE BANKING_AI_DEMO", "Database selected"),
        ("CREATE SCHEMA IF NOT EXISTS BANKING_SCHEMA", "Schema created"),
        ("USE SCHEMA BANKING_SCHEMA", "Schema selected")
    ]
    
    for sql, description in setup_queries:
        if not execute_sql(conn, sql, description):
            return False
    
    # Step 4: Create warehouse
    print("\n4️⃣ Creating warehouse...")
    warehouse_sql = """
    CREATE WAREHOUSE IF NOT EXISTS Banking_Intelligence_demo_wh
        WAREHOUSE_SIZE = 'XSMALL'
        AUTO_SUSPEND = 60
        AUTO_RESUME = TRUE
        COMMENT = 'Warehouse for Banking AI Demo'
    """
    if not execute_sql(conn, warehouse_sql, "Warehouse created"):
        return False
    
    # Step 5: Create role
    print("\n5️⃣ Creating role...")
    role_queries = [
        ("CREATE ROLE IF NOT EXISTS BANKING_Intelligence_Demo", "Role created"),
        ("GRANT USAGE ON DATABASE BANKING_AI_DEMO TO ROLE BANKING_Intelligence_Demo", "Database privileges granted"),
        ("GRANT USAGE ON SCHEMA BANKING_SCHEMA TO ROLE BANKING_Intelligence_Demo", "Schema privileges granted"),
        ("GRANT USAGE ON WAREHOUSE Banking_Intelligence_demo_wh TO ROLE BANKING_Intelligence_Demo", "Warehouse privileges granted")
    ]
    
    for sql, description in role_queries:
        if not execute_sql(conn, sql, description):
            return False
    
    # Step 6: Create tables
    print("\n6️⃣ Creating tables...")
    tables_created = create_tables(conn)
    if not tables_created:
        return False
    
    # Step 7: Insert sample data
    print("\n7️⃣ Inserting sample data...")
    data_inserted = insert_sample_data(conn)
    if not data_inserted:
        return False
    
    # Step 8: Create semantic views
    print("\n8️⃣ Creating semantic views...")
    views_created = create_semantic_views(conn)
    if not views_created:
        return False
    
    # Step 9: Grant permissions
    print("\n9️⃣ Granting permissions...")
    permission_queries = [
        ("GRANT USAGE ON DATABASE BANKING_AI_DEMO TO ROLE PUBLIC", "Public database access granted"),
        ("GRANT USAGE ON SCHEMA BANKING_SCHEMA TO ROLE PUBLIC", "Public schema access granted"),
        ("GRANT SELECT ON ALL TABLES IN SCHEMA BANKING_SCHEMA TO ROLE PUBLIC", "Public table access granted"),
        ("GRANT SELECT ON ALL VIEWS IN SCHEMA BANKING_SCHEMA TO ROLE PUBLIC", "Public view access granted")
    ]
    
    for sql, description in permission_queries:
        if not execute_sql(conn, sql, description):
            return False
    
    # Step 10: Verification
    print("\n🔟 Verifying setup...")
    verification_passed = verify_setup(conn)
    
    conn.close()
    
    if verification_passed:
        print("\n🎉 Setup completed successfully!")
        print("You're ready to follow along with the banking demo!")
        return True
    else:
        print("\n❌ Setup verification failed. Please check the errors above.")
        return False

def create_tables(conn):
    """Create all the banking demo tables"""
    tables = {
        'customer_dim': """
        CREATE OR REPLACE TABLE customer_dim (
            customer_id NUMBER PRIMARY KEY,
            customer_name VARCHAR(100),
            customer_type VARCHAR(50),
            customer_segment VARCHAR(50),
            region VARCHAR(50),
            city VARCHAR(50),
            state VARCHAR(2),
            risk_tier VARCHAR(20),
            industry_sector VARCHAR(50),
            created_date DATE,
            total_assets NUMBER(15,2),
            credit_score NUMBER(3),
            relationship_manager_id NUMBER
        )
        """,
        
        'account_dim': """
        CREATE OR REPLACE TABLE account_dim (
            account_id NUMBER PRIMARY KEY,
            customer_id NUMBER REFERENCES customer_dim(customer_id),
            account_type VARCHAR(50),
            product_line VARCHAR(50),
            account_status VARCHAR(20),
            open_date DATE,
            close_date DATE,
            branch_id NUMBER,
            balance NUMBER(15,2),
            interest_rate NUMBER(5,4),
            monthly_fee NUMBER(10,2),
            overdraft_limit NUMBER(15,2)
        )
        """,
        
        'transaction_fact': """
        CREATE OR REPLACE TABLE transaction_fact (
            transaction_id NUMBER PRIMARY KEY,
            account_id NUMBER REFERENCES account_dim(account_id),
            customer_id NUMBER REFERENCES customer_dim(customer_id),
            transaction_date DATE,
            transaction_type_id NUMBER,
            amount NUMBER(15,2),
            channel_id NUMBER,
            branch_id NUMBER,
            employee_id NUMBER,
            description VARCHAR(200),
            reference_number VARCHAR(50),
            is_fraudulent BOOLEAN DEFAULT FALSE
        )
        """,
        
        'loan_portfolio_fact': """
        CREATE OR REPLACE TABLE loan_portfolio_fact (
            loan_id NUMBER PRIMARY KEY,
            customer_id NUMBER REFERENCES customer_dim(customer_id),
            account_id NUMBER REFERENCES account_dim(account_id),
            loan_type_id NUMBER,
            loan_amount NUMBER(15,2),
            outstanding_balance NUMBER(15,2),
            interest_rate NUMBER(5,4),
            origination_date DATE,
            maturity_date DATE,
            payment_frequency VARCHAR(20),
            collateral_value NUMBER(15,2),
            risk_tier_id NUMBER,
            loan_status VARCHAR(20),
            days_past_due NUMBER,
            industry_id NUMBER
        )
        """
    }
    
    for table_name, sql in tables.items():
        if not execute_sql(conn, sql, f"Table {table_name} created"):
            return False
    
    return True

def insert_sample_data(conn):
    """Insert sample banking data"""
    sample_data = {
        'customer_dim': """
        INSERT INTO customer_dim VALUES
        (1001, 'John Smith', 'Retail', 'Premium', 'North', 'New York', 'NY', 'Low', 'Technology', '2020-01-15', 50000, 750, 101),
        (1002, 'Acme Corporation', 'Corporate', 'Premium', 'South', 'Atlanta', 'GA', 'Medium', 'Manufacturing', '2019-03-20', 2500000, 680, 102),
        (1003, 'Sarah Johnson', 'Wealth Management', 'Premium', 'East', 'Boston', 'MA', 'Low', 'Healthcare', '2021-06-10', 1500000, 800, 103),
        (1004, 'Bob''s Hardware Store', 'Small Business', 'Standard', 'West', 'Los Angeles', 'CA', 'Medium', 'Retail', '2020-11-05', 750000, 720, 104),
        (1005, 'Global Energy Corp', 'Corporate', 'Premium', 'Central', 'Chicago', 'IL', 'High', 'Energy', '2018-09-12', 5000000, 650, 105)
        """,
        
        'account_dim': """
        INSERT INTO account_dim VALUES
        (2001, 1001, 'Checking', 'Retail Banking', 'Active', '2020-01-15', NULL, 1, 5000, 0.01, 0, 1000),
        (2002, 1001, 'Savings', 'Retail Banking', 'Active', '2020-01-15', NULL, 1, 15000, 0.025, 0, 0),
        (2003, 1002, 'Business Checking', 'Commercial Banking', 'Active', '2019-03-20', NULL, 2, 500000, 0.005, 25, 50000),
        (2004, 1003, 'Investment Account', 'Wealth Management', 'Active', '2021-06-10', NULL, 3, 1500000, 0.03, 0, 0),
        (2005, 1004, 'Business Loan', 'Commercial Banking', 'Active', '2020-11-05', NULL, 4, -250000, 0.065, 0, 0)
        """,
        
        'transaction_fact': """
        INSERT INTO transaction_fact VALUES
        (3001, 2001, 1001, '2024-01-15', 1, 1000, 1, 1, 101, 'Salary deposit', 'TXN001', FALSE),
        (3002, 2001, 1001, '2024-01-16', 2, -500, 2, 1, 101, 'ATM withdrawal', 'TXN002', FALSE),
        (3003, 2002, 1001, '2024-01-15', 5, 75, 1, 1, 101, 'Monthly interest', 'TXN003', FALSE),
        (3004, 2003, 1002, '2024-01-15', 1, 50000, 1, 2, 102, 'Business deposit', 'TXN004', FALSE),
        (3005, 2004, 1003, '2024-01-15', 3, 100000, 1, 3, 103, 'Investment transfer', 'TXN005', FALSE)
        """,
        
        'loan_portfolio_fact': """
        INSERT INTO loan_portfolio_fact VALUES
        (4001, 1001, 2001, 1, 300000, 280000, 0.045, '2020-02-01', '2050-02-01', 'Monthly', 350000, 1, 'Active', 0, 1),
        (4002, 1002, 2003, 2, 1000000, 950000, 0.065, '2019-04-01', '2029-04-01', 'Monthly', 1200000, 2, 'Active', 0, 1),
        (4003, 1004, 2005, 2, 250000, 240000, 0.075, '2020-12-01', '2025-12-01', 'Monthly', 300000, 2, 'Active', 0, 3)
        """
    }
    
    for table_name, sql in sample_data.items():
        if not execute_sql(conn, sql, f"Sample data inserted into {table_name}"):
            return False
    
    return True

def create_semantic_views(conn):
    """Create semantic views for the demo"""
    views = {
        'retail_banking_semantic': """
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
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
        """,
        
        'commercial_banking_semantic': """
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
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        """
    }
    
    for view_name, sql in views.items():
        if not execute_sql(conn, sql, f"View {view_name} created"):
            return False
    
    return True

def verify_setup(conn):
    """Verify that the setup was successful"""
    print("🔍 Running verification checks...")
    
    verification_queries = [
        ("SELECT COUNT(*) as customer_count FROM customer_dim", "Customer count"),
        ("SELECT COUNT(*) as account_count FROM account_dim", "Account count"),
        ("SELECT COUNT(*) as transaction_count FROM transaction_fact", "Transaction count"),
        ("SELECT COUNT(*) as loan_count FROM loan_portfolio_fact", "Loan count"),
        ("SHOW VIEWS", "Semantic views")
    ]
    
    all_passed = True
    for sql, description in verification_queries:
        result = execute_sql(conn, sql, f"Verifying {description}")
        if not result:
            all_passed = False
    
    return all_passed

# =============================================================================
# DEMO QUERIES FOR FOLLOW-ALONG
# =============================================================================

def run_demo_queries(conn):
    """Run sample queries for the demo"""
    print("\n🎯 Running sample demo queries...")
    
    demo_queries = [
        {
            'name': 'Customer Overview',
            'sql': 'SELECT customer_name, customer_type, customer_segment, region FROM customer_dim LIMIT 5',
            'description': 'Basic customer information'
        },
        {
            'name': 'Account Balances',
            'sql': 'SELECT account_type, SUM(balance) as total_balance FROM account_dim GROUP BY account_type',
            'description': 'Total balances by account type'
        },
        {
            'name': 'Transaction Summary',
            'sql': 'SELECT COUNT(*) as total_transactions, SUM(amount) as total_amount FROM transaction_fact',
            'description': 'Transaction summary'
        }
    ]
    
    for query in demo_queries:
        print(f"\n📊 {query['name']}: {query['description']}")
        result = execute_sql(conn, query['sql'])
        if result:
            # Display results in a nice format
            try:
                df = pd.DataFrame(result)
                display(df)
            except:
                print("Query executed successfully")

# =============================================================================
# MAIN EXECUTION
# =============================================================================

if __name__ == "__main__":
    # Display welcome message
    display(HTML("""
    <h1>🏦 Snowflake Banking Demo Setup</h1>
    <p>This notebook will automatically set up your Snowflake environment for the banking demo.</p>
    <p><strong>Before running:</strong> Update the SNOWFLAKE_CONFIG dictionary with your credentials.</p>
    """))
    
    # Check if credentials are configured
    if SNOWFLAKE_CONFIG['user'] == 'YOUR_USERNAME':
        display(HTML("""
        <div style="background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 10px; border-radius: 5px;">
        <strong>⚠️ Configuration Required:</strong> Please update the SNOWFLAKE_CONFIG dictionary with your Snowflake credentials before running the setup.
        </div>
        """))
    else:
        # Run the setup
        success = setup_banking_demo()
        
        if success:
            # Create a new connection for demo queries
            conn = create_connection()
            if conn:
                run_demo_queries(conn)
                conn.close()
            
            display(HTML("""
            <div style="background-color: #d4edda; border: 1px solid #c3e6cb; padding: 10px; border-radius: 5px;">
            <h3>🎉 Setup Complete!</h3>
            <p>Your Snowflake environment is ready for the banking demo. You can now follow along with the presentation.</p>
            </div>
            """))
        else:
            display(HTML("""
            <div style="background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 10px; border-radius: 5px;">
            <h3>❌ Setup Failed</h3>
            <p>Please check the error messages above and try again.</p>
            </div>
            """))

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

"""
INSTRUCTIONS FOR GUESTS:

1. Install required packages:
   pip install snowflake-connector-python pandas ipython

2. Update the SNOWFLAKE_CONFIG dictionary with your credentials:
   - user: Your Snowflake username
   - password: Your Snowflake password
   - account: Your Snowflake account identifier
   - warehouse: Your default warehouse name

3. Run this notebook to automatically set up your environment

4. Follow along with the presenter during the demo

5. After the demo, you can clean up by running:
   DROP DATABASE BANKING_AI_DEMO;
   DROP WAREHOUSE Banking_Intelligence_demo_wh;
   DROP ROLE BANKING_Intelligence_Demo;
""" 