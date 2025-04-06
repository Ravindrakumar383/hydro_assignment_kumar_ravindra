from dagster import asset, DailyPartitionsDefinition, Output, AssetExecutionContext
from typing import List, Tuple
from datetime import datetime, timedelta
from src.utils.geospatial_utils import GeospatialProcessor
from src.utils.logging import setup_logger
from src.models.geospatial_models import BoundingBox, RawFieldData, ProcessedFieldData

PARTITIONS_DEF = DailyPartitionsDefinition(start_date="2025-01-01")

class FieldDataAsset:
    def __init__(self, bounding_box: BoundingBox, raw_data: List[RawFieldData], s3_io_manager):
        self.bounding_box = bounding_box
        self.raw_data = raw_data
        self.processor = GeospatialProcessor(bounding_box)
        self.logger = setup_logger(__name__)
        self.s3_io_manager = s3_io_manager

    def _parse_partition_datetime(self, partition_date: str) -> datetime:
        return datetime.strptime(partition_date, "%Y-%m-%d")

    def _is_late_arrival(self, arrival_time: datetime, partition_dt: datetime) -> bool:
        return arrival_time > partition_dt + timedelta(days=1)

    def _get_intended_partition_date(self, field: dict) -> str:
        """Determine the intended partition date for the field."""
        return field["processing_date"]

    def _create_processed_field(
        self, field_row: dict, partition_date: str, days_since_planting: int
    ) -> ProcessedFieldData:
        return ProcessedFieldData(
            field_id=field_row["field_id"],
            days_since_planting=days_since_planting,
            partition_date=partition_date,
            arrival_time=field_row["arrival_time"]
        )

    def _store_late_data(self, late_field: dict, intended_partition_date: str, context: AssetExecutionContext):
        """Store late data in S3 and log the intended partition date."""
        s3_key = f"late_data/{intended_partition_date}/{late_field['field_id']}.json"
        self.s3_io_manager._write(late_field, s3_key)
        self.logger.info(
            f"Stored late data for field {late_field['field_id']} for partition {intended_partition_date} at {s3_key}"
        )
        context.log.info(
            f"Triggering backfill for partition {intended_partition_date} due to late data for field {late_field['field_id']}"
        )

    def process_fields(self, partition_date: str, context: AssetExecutionContext) -> Tuple[List[ProcessedFieldData], bool, List[dict]]:
        partition_dt = self._parse_partition_datetime(partition_date)
        filtered_gdf = self.processor.filter_fields_in_bbox(self.raw_data)

        processed_fields: List[ProcessedFieldData] = []
        late_fields: List[dict] = []
        has_late_data = False

        for _, row in filtered_gdf.iterrows():
            arrival_time = datetime.strptime(row["arrival_time"], "%Y-%m-%dT%H:%M:%S")
            intended_partition_date = self._get_intended_partition_date(row)

            # Check if the field is intended for this partition
            if intended_partition_date != partition_date:
                # Field is not meant for this partition; consider it late if it arrives after its intended partition
                intended_partition_dt = self._parse_partition_datetime(intended_partition_date)
                if arrival_time > intended_partition_dt + timedelta(days=1):
                    has_late_data = True
                    self.logger.warning(
                        f"Late data detected for field {row['field_id']} intended for partition {intended_partition_date}"
                    )
                    late_field = row.to_dict()
                    late_field["intended_partition_date"] = intended_partition_date
                    late_fields.append(late_field)
                    self._store_late_data(late_field, intended_partition_date, context)
                continue

            # Process the field if it's not late for this partition
            if self._is_late_arrival(arrival_time, partition_dt):
                has_late_data = True
                self.logger.warning(
                    f"Late data detected for field {row['field_id']} in partition {partition_date}"
                )
                late_field = row.to_dict()
                late_field["intended_partition_date"] = intended_partition_date
                late_fields.append(late_field)
                self._store_late_data(late_field, intended_partition_date, context)
            else:
                days_since_planting = self.processor.get_days_since_planting(
                    row["planting_date"], partition_date
                )
                processed_field = self._create_processed_field(row, partition_date, days_since_planting)
                processed_fields.append(processed_field)

        return processed_fields, has_late_data, late_fields

def _load_raw_data() -> List[RawFieldData]:
    return [
        # For 2025-01-01
        RawFieldData(
            field_id="field_1",
            planting_date="2024-12-01",
            geometry="POLYGON((-120 35, -119 35, -119 36, -120 36, -120 35))",
            arrival_time="2025-01-01T12:00:00",
            processing_date="2025-01-01"
        ),
        RawFieldData(
            field_id="field_2",
            planting_date="2024-12-15",
            geometry="POLYGON((-119.5 35.5, -119 35.5, -119 36, -119.5 36, -119.5 35.5))",
            arrival_time="2025-01-03T12:00:00",
            processing_date="2025-01-01"
        ),
        # For 2025-01-02
        RawFieldData(
            field_id="field_3",
            planting_date="2024-12-10",
            geometry="POLYGON((-119.8 35.2, -119.7 35.2, -119.7 35.3, -119.8 35.3, -119.8 35.2))",
            arrival_time="2025-01-02T12:00:00",
            processing_date="2025-01-02"
        ),
        RawFieldData(
            field_id="field_4",
            planting_date="2024-12-20",
            geometry="POLYGON((-119.9 35.8, -119.8 35.8, -119.8 35.9, -119.9 35.9, -119.9 35.8))",
            arrival_time="2025-01-03T12:00:00",
            processing_date="2025-01-02"
        ),
        # For 2025-01-03
        RawFieldData(
            field_id="field_5",
            planting_date="2024-12-05",
            geometry="POLYGON((-119.6 35.4, -119.5 35.4, -119.5 35.5, -119.6 35.5, -119.6 35.4))",
            arrival_time="2025-01-03T12:00:00",
            processing_date="2025-01-03"
        ),
        RawFieldData(
            field_id="field_6",
            planting_date="2024-12-25",
            geometry="POLYGON((-119.7 35.6, -119.6 35.6, -119.6 35.7, -119.7 35.7, -119.7 35.6))",
            arrival_time="2025-01-05T12:00:00",
            processing_date="2025-01-03"
        )
    ]

def _create_bounding_box() -> BoundingBox:
    return BoundingBox(min_x=-120, max_x=-119, min_y=35, max_y=36)

def _log_late_data_warning(context: AssetExecutionContext) -> None:
    context.log.info("Late data detected. Consider triggering a backfill for earlier partitions.")

@asset(
    partitions_def=PARTITIONS_DEF,
    io_manager_key="s3_io_manager",
    metadata={"bounding_box": "square/rectangular extent"}
)
def field_data(context: AssetExecutionContext) -> Output:
    partition_date = context.partition_key
    raw_data = _load_raw_data()
    bounding_box = _create_bounding_box()

    asset_processor = FieldDataAsset(bounding_box, raw_data, context.resources.s3_io_manager)
    processed_fields, has_late_data, late_fields = asset_processor.process_fields(partition_date, context)

    if has_late_data:
        _log_late_data_warning(context)

    return Output(
        value=processed_fields,
        metadata={
            "num_fields_processed": len(processed_fields),
            "late_data_detected": has_late_data,
            "late_fields": late_fields
        }
    )