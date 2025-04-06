import pytest
from typing import List
from src.utils.geospatial_utils import GeospatialProcessor
from src.models.geospatial_models import BoundingBox, RawFieldData

def test_filter_fields_in_bbox(bounding_box: BoundingBox, sample_raw_data: List[RawFieldData]):
    """Test filtering fields within a bounding box."""
    processor = GeospatialProcessor(bounding_box)
    filtered_gdf = processor.filter_fields_in_bbox(sample_raw_data)
    assert len(filtered_gdf) == 6  # All fields are within the bounding box
    assert filtered_gdf["field_id"].tolist() == ["field_1", "field_2", "field_3", "field_4", "field_5", "field_6"]

def test_get_days_since_planting():
    """Test calculating days since planting."""
    processor = GeospatialProcessor(BoundingBox(min_x=0, max_x=1, min_y=0, max_y=1))
    days = processor.get_days_since_planting("2024-12-01", "2025-01-01")
    assert days == 31

def test_get_days_since_planting_invalid_date():
    """Test handling of invalid date formats."""
    processor = GeospatialProcessor(BoundingBox(min_x=0, max_x=1, min_y=0, max_y=1))
    with pytest.raises(ValueError):
        processor.get_days_since_planting("invalid-date", "2025-01-01")

def test_invalid_bounding_box():
    """Test validation of an invalid bounding box."""
    with pytest.raises(ValueError, match="max_x must be greater than min_x"):
        BoundingBox(min_x=1, max_x=0, min_y=0, max_y=1)  # min_x > max_x