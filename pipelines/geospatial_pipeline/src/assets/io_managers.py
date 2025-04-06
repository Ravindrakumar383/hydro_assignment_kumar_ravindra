from dagster_aws.s3 import S3PickleIOManager

def get_s3_io_manager(bucket: str, prefix: str) -> S3PickleIOManager:
    """Configure an S3 IO Manager for Dagster assets."""
    return S3PickleIOManager(
        s3_bucket=bucket,
        s3_prefix=prefix
    )