from dagster import define_asset_job
from src.assets.geospatial_asset import field_data, PARTITIONS_DEF

field_data_job = define_asset_job(
    name="field_data_job",
    selection=[field_data],
    partitions_def=PARTITIONS_DEF
)