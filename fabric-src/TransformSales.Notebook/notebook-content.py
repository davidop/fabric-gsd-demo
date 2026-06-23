# Fabric notebook demo - TransformSales
# This file is intentionally simple for event readability.

from pyspark.sql import functions as F

raw_path = "Files/raw/sales.csv"
bronze_table = "raw_sales"
silver_table = "sales_curated"
gold_table = "sales_kpis"

sales = (
    spark.read
        .option("header", "true")
        .option("inferSchema", "true")
        .csv(raw_path)
)

sales = sales.withColumn("Revenue", F.col("Quantity") * F.col("UnitPrice"))
sales.write.mode("overwrite").format("delta").saveAsTable(bronze_table)

curated = sales.withColumn("OrderDate", F.to_date("OrderDate"))
curated.write.mode("overwrite").format("delta").saveAsTable(silver_table)

kpis = curated.groupBy("Region").agg(
    F.sum("Revenue").alias("TotalRevenue"),
    F.countDistinct("OrderId").alias("Orders"),
    F.sum("Quantity").alias("Units")
)
kpis.write.mode("overwrite").format("delta").saveAsTable(gold_table)
