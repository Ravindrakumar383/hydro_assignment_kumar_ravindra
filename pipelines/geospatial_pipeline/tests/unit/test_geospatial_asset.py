import pytest
from typing import List
from src.assets.geospatial_asset import FieldDataAsset
from src.models.geospatial_models import RawFieldData
from datetime import datetime, timedelta
from unittest.mock import MagicMock

def test_process_fields_2025_01_01(bounding_box, sample_raw_data):
    """Test processing fields for 2025-01-01."""
    mock_context = MagicMock()
    mock_context.resources.s3_io_manager._write = MagicMock()
    asset_instance = FieldDataAsset(bounding_box, sample_raw_data, mock_context.resources.s3_io_manager)
    processed_fields, has_late_data, late_fields = asset_instance.process_fields("2025-01-01", mock_context)

    assert len(processed_fields) == 1  # field_1 is processed
    assert processed_fields[0].field_id == "field_1"
    assert processed_fields[0].days_since_planting == 31
    assert has_late_data is True
    assert len(late_fields) == 3  
    assert late_fields[0]["intended_partition_date"] == "2025-01-01"

def test_process_fields_2025_01_02(bounding_box, sample_raw_data):
    """Test processing fields for 2025-01-02."""
    mock_context = MagicMock()
    mock_context.resources.s3_io_manager._write = MagicMock()
    asset_instance = FieldDataAsset(bounding_box, sample_raw_data, mock_context.resources.s3_io_manager)
    processed_fields, has_late_data, late_fields = asset_instance.process_fields("2025-01-02", mock_context)

    assert len(processed_fields) == 1  # field_3 is processed
    assert processed_fields[0].field_id == "field_3"
    assert processed_fields[0].days_since_planting == 23
    assert has_late_data is True
    assert len(late_fields) == 3
   

def test_process_fields_2025_01_03(bounding_box, sample_raw_data):
    """Test processing fields for 2025-01-03."""
    mock_context = MagicMock()
    mock_context.resources.s3_io_manager._write = MagicMock()
    asset_instance = FieldDataAsset(bounding_box, sample_raw_data, mock_context.resources.s3_io_manager)
    processed_fields, has_late_data, late_fields = asset_instance.process_fields("2025-01-03", mock_context)
    print(late_fields)
    assert len(processed_fields) == 1  # field_5 is processed
    assert processed_fields[0].field_id == "field_5"
    assert processed_fields[0].days_since_planting == 29
    assert has_late_data is True
    assert len(late_fields) == 3  
  

def test_process_fields_no_late_data(bounding_box, sample_raw_data):
    """Test processing fields with no late-arriving data."""
    sample_raw_data[1] = RawFieldData(
        field_id="field_2",
        planting_date="2024-12-15",
        geometry="POLYGON((-119.5 35.5, -119 35.5, -119 36, -119.5 36, -119.5 35.5))",
        arrival_time="2025-01-01T12:00:00",
        processing_date="2025-01-01"
    )
    sample_raw_data[3] = RawFieldData(
        field_id="field_4",
        planting_date="2024-12-20",
        geometry="POLYGON((-119.9 35.8, -119.8 35.8, -119.8 35.9, -119.9 35.9, -119.9 35.8))",
        arrival_time="2025-01-02T12:00:00",
        processing_date="2025-01-02"
    )
    sample_raw_data[5] = RawFieldData(
        field_id="field_6",
        planting_date="2024-12-25",
        geometry="POLYGON((-119.7 35.6, -119.6 35.6, -119.6 35.7, -119.7 35.7, -119.7 35.6))",
        arrival_time="2025-01-03T12:00:00",
        processing_date="2025-01-03"
    )
    mock_context = MagicMock()
    mock_context.resources.s3_io_manager._write = MagicMock()
    asset_instance = FieldDataAsset(bounding_box, sample_raw_data, mock_context.resources.s3_io_manager)
    processed_fields, has_late_data, late_fields = asset_instance.process_fields("2025-01-03", mock_context)
    assert len(processed_fields) == 2  # field_5 and field_6 are processed
    assert has_late_data is False
    assert len(late_fields) == 0

def test_invalid_raw_data():
    """Test validation of invalid raw data."""
    with pytest.raises(ValueError, match="planting_date must be in YYYY-MM-DD format"):
        RawFieldData(
            field_id="field_1",
            planting_date="invalid-date",
            geometry="POLYGON((-120 35, -119 35, -119 36, -120 36, -120 35))",
            arrival_time="2025-01-03T12:00:00",
            processing_date="2025-01-03"
        )