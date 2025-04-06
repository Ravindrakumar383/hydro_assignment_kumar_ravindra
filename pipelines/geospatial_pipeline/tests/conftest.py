import pytest
from typing import List
from src.models.geospatial_models import BoundingBox, RawFieldData

@pytest.fixture
def sample_raw_data() -> List[RawFieldData]:
    """Fixture for sample raw data."""
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

@pytest.fixture
def bounding_box() -> BoundingBox:
    """Fixture for a sample bounding box."""
    return BoundingBox(min_x=-120, max_x=-119, min_y=35, max_y=36)