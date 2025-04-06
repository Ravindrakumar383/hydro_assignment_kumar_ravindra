from dagster import Definitions, ScheduleDefinition, DefaultScheduleStatus
from src.assets.geospatial_asset import field_data
from src.assets.io_managers import get_s3_io_manager
from src.jobs.field_data_job import field_data_job

# Define a schedule to run the field_data_job daily for the current day's partition
daily_field_data_schedule = ScheduleDefinition(
    job=field_data_job,
    cron_schedule="0 0 * * *",  # Run at midnight every day
    default_status=DefaultScheduleStatus.RUNNING,
    execution_timezone="UTC"
)

defs = Definitions(
    assets=[field_data],
    jobs=[field_data_job],
    resources={
        "s3_io_manager": get_s3_io_manager(
            bucket="hydrosat-dagster-assets",
            prefix="field-data"
        )
    },
    schedules=[daily_field_data_schedule]
)