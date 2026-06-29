# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# COMMAND ----------

# Sales Data Transformation Notebook
# ===================================
# 
# Phase 1: Medallion Architecture - Silver & Gold Layers
# 
# Input: data/raw/sales.csv (bronze raw data)
# Output: 
#   - silver_sales (enriched, cleaned)
#   - gold_sales_metrics (business-ready KPIs)
# 
# Transformations:
#   - Revenue = Quantity * UnitPrice
#   - Cost = Quantity * EstimatedCostPrice (by product category)
#   - Margin = Revenue - Cost
#   - MarginPercentage = Margin / Revenue * 100 (0 when Revenue = 0)

# COMMAND ----------

import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.functions import when, col, lit, round
from datetime import datetime

# Initialize Spark session
spark = SparkSession.builder.appName("SalesTransformation").getOrCreate()

# COMMAND ----------

# STEP 1: Load raw sales data from CSV
# =====================================

raw_csv_path = "abfss://Files@onelake/data/raw/sales.csv"

try:
    # Load CSV into Spark DataFrame
    sales_raw = spark.read.option("header", "true").option("inferSchema", "true").csv(raw_csv_path)
    print(f"✓ Loaded {sales_raw.count()} raw sales records")
    sales_raw.display()
except Exception as e:
    print(f"Note: Using pandas fallback. Details: {e}")
    # Fallback: read with pandas if Spark path not available (for local testing)
    sales_raw = pd.read_csv("data/raw/sales.csv")
    sales_raw = spark.createDataFrame(sales_raw)
    print(f"✓ Loaded {sales_raw.count()} raw sales records (pandas fallback)")

# COMMAND ----------

# STEP 2: Define product cost estimates
# ======================================
# 
# In real scenarios, cost would come from ERP/supply chain system.
# For this demo, we estimate based on product category and margin expectations.
# 
# Assumption: Standard margins ~70% (cost = ~30% of revenue)
# Adjusted per product for realism.

product_costs = {
    "Laptop": 500.00,        # 47% margin on $950 unit price
    "Monitor": 100.00,       # 54% margin on $220
    "Keyboard": 20.00,       # 55% margin on $45
    "Mouse": 12.00,          # 52% margin on $25
    "Docking Station": 80.00 # 55% margin on $180
}

# Broadcast cost lookup (Spark-native optimization)
cost_lookup = spark.sparkContext.broadcast(product_costs)

# COMMAND ----------

# STEP 3: Enrich with revenue and cost calculations
# ==================================================

sales_enriched = (
    sales_raw
    .withColumn(
        "CostPrice",
        when(col("Product").isin(list(product_costs.keys())), 
             lit(product_costs.get(sales_raw.select("Product").collect()[0][0], 50.00)))
        .otherwise(lit(50.00))  # Default cost estimate
    )
    .withColumn("Revenue", col("Quantity") * col("UnitPrice"))
    .withColumn("Cost", col("Quantity") * col("CostPrice"))
    .withColumn("Margin", col("Revenue") - col("Cost"))
    .withColumn(
        "MarginPercentage",
        when(col("Revenue") == 0, lit(0))
        .otherwise(round((col("Margin") / col("Revenue")) * 100, 2))
    )
    .withColumn("TransformedDate", lit(datetime.now().isoformat()))
)

print(f"✓ Enriched records with Revenue, Cost, Margin, MarginPercentage")
sales_enriched.display()

# COMMAND ----------

# STEP 4: Silver layer - Cleaned and standardized
# ================================================
# 
# Silver tables are integration-ready, with business logic applied.

silver_sales = (
    sales_enriched
    .select(
        "OrderId",
        "OrderDate",
        "CustomerId",
        "Product",
        "Region",
        "Quantity",
        "UnitPrice",
        "CostPrice",
        "Revenue",
        "Cost",
        "Margin",
        "MarginPercentage"
    )
)

print(f"✓ Silver layer ready: {silver_sales.count()} records")

# Save to lakehouse (comment out if not in Fabric environment)
# silver_sales.write.mode("overwrite").option("mergeSchema", "true").parquet("abfss://Tables@onelake/silver/sales")

# COMMAND ----------

# STEP 5: Gold layer - Business-ready metrics
# =============================================
# 
# Gold tables support BI queries: aggregate by Region, Product, Date.

gold_sales_metrics = (
    sales_enriched
    .groupBy("Region", "Product", "OrderDate")
    .agg({
        "Quantity": "sum",
        "Revenue": "sum",
        "Cost": "sum",
        "Margin": "sum",
        "MarginPercentage": "avg"
    })
    .withColumnRenamed("sum(Quantity)", "TotalQuantity")
    .withColumnRenamed("sum(Revenue)", "TotalRevenue")
    .withColumnRenamed("sum(Cost)", "TotalCost")
    .withColumnRenamed("sum(Margin)", "TotalMargin")
    .withColumnRenamed("avg(MarginPercentage)", "AvgMarginPercentage")
    .withColumn("AvgMarginPercentage", round(col("AvgMarginPercentage"), 2))
)

print(f"✓ Gold layer ready: {gold_sales_metrics.count()} aggregated records")
gold_sales_metrics.display()

# Save to lakehouse (comment out if not in Fabric environment)
# gold_sales_metrics.write.mode("overwrite").option("mergeSchema", "true").parquet("abfss://Tables@onelake/gold/sales_metrics")

# COMMAND ----------

# SUMMARY
# =======
# 
# Medallion Architecture Transformation Complete
# 
# Bronze (Input): data/raw/sales.csv
#   └─ Raw, as-is data from source system
# 
# Silver (Intermediate): Enriched sales with calculated cost, revenue, margin
#   └─ Business logic applied
#   └─ Ready for downstream consumption
# 
# Gold (Output): Aggregated regional/product metrics
#   └─ Pre-aggregated for BI queries
#   └─ Optimized for reporting

print("\n" + "="*60)
print("Medallion Architecture Transformation Complete")
print("="*60)
print(f"✓ Silver records: {silver_sales.count()}")
print(f"✓ Gold aggregates: {gold_sales_metrics.count()}")
print(f"✓ Timestamp: {datetime.now().isoformat()}")
print("="*60)
