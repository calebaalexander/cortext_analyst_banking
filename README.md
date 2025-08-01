# Snowflake Banking Intelligence Demo

A comprehensive demonstration package for showcasing Snowflake Cortex AI and Semantic Models in banking environments.

## 🏦 What's Included

- **Complete Banking Demo Environment** - Ready-to-run Snowflake setup
- **60-Minute Presentation Script** - Banking-focused presentation flow
- **Live Demo Materials** - Step-by-step demonstration guide
- **Q&A Preparation** - Banking-specific questions and responses
- **Setup Scripts** - Automated environment creation

## 🚀 Quick Start

1. **Clone this repository**
   ```bash
   git clone https://github.com/calebaalexander/cortext_analyst_banking.git
   cd cortext_analyst_banking
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up your Snowflake environment**
   - Open `demo_setup_notebook.py`
   - Update the `SNOWFLAKE_CONFIG` with your credentials
   - Run the notebook to automatically set up your environment

4. **Follow along with the demo**
   - Use `customer_setup_guide.md` for detailed setup instructions
   - Use `follow_along_demo.md` to build the demo alongside the presenter

## 📊 Banking Domains Covered

- **Retail Banking** - Customer accounts, transactions, branch performance
- **Commercial Banking** - Business loans, industry exposure, risk assessment  
- **Risk & Compliance** - NPL rates, regulatory reporting, capital adequacy
- **Wealth Management** - Investment portfolios, AUM, performance tracking

## 🎯 Perfect For

- Banking executive presentations
- Financial services demos
- Snowflake Cortex Analyst showcases
- Semantic model implementations
- Banking data analytics demonstrations

## 📁 Repository Structure

```
├── README.md                           # This file - main documentation
├── demo_setup_notebook.py              # Automated setup script
├── customer_setup_guide.md             # Setup instructions
├── follow_along_demo.md                # Hands-on demo guide
├── requirements.txt                    # Python dependencies
└── .gitignore                          # Git ignore file
```

## 🔧 Setup Instructions

### Prerequisites
- Snowflake account with Cortex Analyst enabled
- Access to create databases, warehouses, and roles
- Basic SQL knowledge

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/calebaalexander/cortext_analyst_banking.git
   cd cortext_analyst_banking
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up the demo environment:**
   - Open `demo_setup_notebook.py` in Jupyter or your preferred Python environment
   - Update the `SNOWFLAKE_CONFIG` dictionary with your Snowflake credentials
   - Run the notebook to automatically set up your complete demo environment

4. **Verify setup:**
   - The notebook will automatically verify that database `BANKING_AI_DEMO` is created
   - Confirm all tables, views, and sample data are loaded
   - Test the setup with sample queries

## 📋 Demo Components

### Data Infrastructure
- **Database**: `BANKING_AI_DEMO` with schema `BANKING_SCHEMA`
- **Warehouse**: `Banking_Intelligence_demo_wh` (XSMALL with auto-suspend/resume)
- **Realistic Banking Data**: 210,000+ records across all banking domains

### Semantic Views (4 Business Domains)
1. **Retail Banking Semantic View** - Customer accounts, transactions, products, branches
2. **Commercial Banking Semantic View** - Business accounts, loan portfolios, credit facilities
3. **Risk & Compliance Semantic View** - Credit risk metrics, regulatory reporting, compliance monitoring
4. **Wealth Management Semantic View** - Investment portfolios, asset allocation, performance tracking

### Banking Intelligence Agent
- **Multi-Domain Banking Analysis** - Combines all banking business lines
- **Regulatory Compliance** - Built-in compliance checking and reporting
- **Risk Assessment** - Automated risk analysis across portfolios
- **Customer 360** - Complete customer view across all banking relationships

## 🎭 Presentation Flow

### Part 1: Slides - Setting the Strategic Context (15 Minutes)
- Banking data challenges and pain points
- Snowflake solution overview
- Cortex Analyst and semantic models introduction

### Part 2: Live Demo - Banking Intelligence in Action (40 Minutes)
- **Setting the Stage** - Show banking data infrastructure
- **Semantic Models** - Demonstrate banking metrics and KPIs
- **Cortex Analyst** - Natural language queries for banking
- **Cross-Domain Intelligence** - Complex banking scenarios

### Part 3: Q&A (5 Minutes)
- Banking-specific questions and concerns
- Implementation path forward
- Next steps and follow-up

## 🔍 Sample Demo Queries

### Retail Banking
- "What was our total deposit growth last quarter by branch?"
- "Show me the number of new checking accounts opened this year by customer segment"
- "Which branches had the highest transaction volumes last month?"

### Commercial Banking
- "What is our total commercial loan exposure by industry sector?"
- "Show me the average loan size by region and industry"
- "Which commercial customers have the highest credit utilization?"

### Risk & Compliance
- "What is our non-performing loan rate by loan type and region?"
- "Show me our capital adequacy ratio trends over the past year"
- "Which customers have multiple accounts with high-risk indicators?"

### Wealth Management
- "What is our total assets under management by investment type?"
- "Show me the top 10 wealth management clients by portfolio value"
- "Which investment products have the highest performance this year?"

## 📈 Success Metrics

### Immediate Benefits (First 30 days)
- **Time savings**: Banking users get answers in seconds vs. days
- **Reduced IT backlog**: Fewer requests for custom reports
- **Faster decision-making**: Real-time insights for banking operations

### Quantifiable ROI Examples
- **Time savings**: 20-30 hours per week saved on report generation
- **IT efficiency**: 40-60% reduction in ad-hoc report requests
- **Decision velocity**: 3-5x faster time to insight
- **Data accuracy**: 100% consistency across all banking reporting

## 🔒 Security & Compliance

This demo environment includes:
- **Enterprise-grade security** features
- **Regulatory compliance** capabilities
- **Data governance** and audit trails
- **Role-based access control**
- **Encryption** at rest and in transit

## 🤝 Contributing

This demo is designed for educational and presentation purposes. Feel free to:
- Adapt the scenarios for your specific banking environment
- Modify the data models to match your business requirements
- Extend the semantic views for additional banking domains
- Share improvements and enhancements

## 📞 Support

For questions or support:
- Review the `customer_setup_guide.md` for detailed setup instructions
- Check the `follow_along_demo.md` for troubleshooting tips
- Refer to Snowflake documentation for technical details

## 📄 License

This project is provided as-is for educational and demonstration purposes. Please ensure compliance with your organization's data governance policies when using this demo.

## 🙏 Acknowledgments

- Based on the comprehensive [Snowflake AI Demo](https://github.com/NickAkincilar/Snowflake_AI_DEMO) by Nick Akincilar
- Adapted specifically for banking and financial services use cases
- Designed for executive presentations and technical demonstrations

---

**Ready to transform your banking data intelligence?** 🚀

Start with the setup script and follow the presentation guide to deliver a compelling banking-focused Snowflake Cortex demonstration. 