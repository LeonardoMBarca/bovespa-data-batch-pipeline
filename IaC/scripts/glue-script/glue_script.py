import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrameCollection
from awsgluedq.transforms import EvaluateDataQuality
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as SqlFuncs

# Script generated for node Custom Transform
def MyTransform(glueContext, dfc) -> DynamicFrameCollection:
    from datetime import datetime
    from pyspark.sql.functions import col, to_date, datediff, lit
    from awsglue.dynamicframe import DynamicFrame, DynamicFrameCollection

    df = dfc.select(list(dfc.keys())[0]).toDF()

    today_date = datetime.today().strftime("%Y-%m-%d")
    df = df.withColumn("actual_date", to_date(lit(today_date)))

    df = df.withColumn("date_pregao_diff", datediff(col("actual_date"), col("pregao_date")))

    output_dyf = DynamicFrame.fromDF(df, glueContext, "df")

    return DynamicFrameCollection({"output": output_dyf}, glueContext)
def sparkAggregate(glueContext, parentFrame, groups, aggs, transformation_ctx) -> DynamicFrame:
    aggsFuncs = []
    for column, func in aggs:
        aggsFuncs.append(getattr(SqlFuncs, func)(column))
    result = parentFrame.toDF().groupBy(*groups).agg(*aggsFuncs) if len(groups) > 0 else parentFrame.toDF().agg(*aggsFuncs)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Default ruleset used by all target nodes with data quality enabled
DEFAULT_DATA_QUALITY_RULESET = """
    Rules = [
        ColumnCount > 0
    ]
"""

# Script generated for node Amazon S3
AmazonS3_node1752120322830 = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": ["s3://datalake-pregao-bovespa-199246429486/raw/"], "recurse": True}, transformation_ctx="AmazonS3_node1752120322830")

# Script generated for node Aggregate
Aggregate_node1752588844009 = sparkAggregate(glueContext, parentFrame = AmazonS3_node1752120322830, groups = ["acao", "data_pregao", "tipo"], aggs = [["qtd_teorica", "sum"], ["part", "avg"]], transformation_ctx = "Aggregate_node1752588844009")

# Script generated for node Change Schema
ChangeSchema_node1752589261980 = ApplyMapping.apply(frame=Aggregate_node1752588844009, mappings=[("acao", "string", "action", "string"), ("data_pregao", "string", "pregao_date", "date"), ("tipo", "string", "type", "string"), ("`sum(qtd_teorica)`", "bigint", "`sum(qtd_teorica)`", "long"), ("`avg(part)`", "double", "participation", "double")], transformation_ctx="ChangeSchema_node1752589261980")

# Script generated for node Custom Transform
CustomTransform_node1752589324565 = MyTransform(glueContext, DynamicFrameCollection({"ChangeSchema_node1752589261980": ChangeSchema_node1752589261980}, glueContext))

# Script generated for node Select From Collection
SelectFromCollection_node1752589757995 = SelectFromCollection.apply(dfc=CustomTransform_node1752589324565, key=list(CustomTransform_node1752589324565.keys())[0], transformation_ctx="SelectFromCollection_node1752589757995")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=SelectFromCollection_node1752589757995, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1752588793627", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1752589777806 = glueContext.getSink(path="s3://datalake-pregao-bovespa-199246429486/refined/", connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=["pregao_date", "action"], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1752589777806")
AmazonS3_node1752589777806.setCatalogInfo(catalogDatabase="refined_bovespa_data",catalogTableName="gold_bovespa")
AmazonS3_node1752589777806.setFormat("glueparquet", compression="snappy")
AmazonS3_node1752589777806.writeFrame(SelectFromCollection_node1752589757995)
job.commit()