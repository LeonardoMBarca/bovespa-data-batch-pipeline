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

    # Extrair o DynamicFrame da coleção
    df = dfc.select(list(dfc.keys())[0]).toDF()

    # Adiciona data atual
    data_hoje = datetime.today().strftime("%Y-%m-%d")
    df = df.withColumn("data_atual", to_date(lit(data_hoje)))

    # Calcula a diferença de dias
    df = df.withColumn("dias_desde_pregao", datediff(col("data_atual"), col("data_pregao")))

    # Converte de volta para DynamicFrame
    output_dyf = DynamicFrame.fromDF(df, glueContext, "df")

    # Retorna como DynamicFrameCollection (com uma única saída chamada "output")
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
AmazonS3_node1752329238402 = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": ["s3://terraform-state-bucket-bovespa-410290736227/bovespa/raw/"], "recurse": True}, transformation_ctx="AmazonS3_node1752329238402")

# Script generated for node Aggregate
Aggregate_node1752330350802 = sparkAggregate(glueContext, parentFrame = AmazonS3_node1752329238402, groups = ["acao", "data_pregao", "tipo"], aggs = [["qtd_teorica", "sum"], ["part", "avg"]], transformation_ctx = "Aggregate_node1752330350802")

# Script generated for node Change Schema
ChangeSchema_node1752331170902 = ApplyMapping.apply(frame=Aggregate_node1752330350802, mappings=[("acao", "string", "acao", "string"), ("data_pregao", "string", "data_pregao", "date"), ("tipo", "string", "tipo", "string"), ("`sum(qtd_teorica)`", "bigint", "`sum(qtd_teorica)`", "long"), ("`avg(part)`", "double", "participacao_media", "double")], transformation_ctx="ChangeSchema_node1752331170902")

# Script generated for node Custom Transform
CustomTransform_node1752339344754 = MyTransform(glueContext, DynamicFrameCollection({"ChangeSchema_node1752331170902": ChangeSchema_node1752331170902}, glueContext))

# Script generated for node Select From Collection
SelectFromCollection_node1752339884855 = SelectFromCollection.apply(dfc=CustomTransform_node1752339344754, key=list(CustomTransform_node1752339344754.keys())[0], transformation_ctx="SelectFromCollection_node1752339884855")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=SelectFromCollection_node1752339884855, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1752328624494", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1752335145752 = glueContext.getSink(path="s3://terraform-state-bucket-bovespa-410290736227/bovespa/refined/", connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=["data_pregao", "acao"], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1752335145752")
AmazonS3_node1752335145752.setCatalogInfo(catalogDatabase="refined_bovespa_data",catalogTableName="etd_bovespa")
AmazonS3_node1752335145752.setFormat("glueparquet", compression="snappy")
AmazonS3_node1752335145752.writeFrame(SelectFromCollection_node1752339884855)
job.commit()