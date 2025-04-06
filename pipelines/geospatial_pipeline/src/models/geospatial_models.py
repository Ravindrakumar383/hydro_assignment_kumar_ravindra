from pydantic import BaseModel, Field, field_validator, ValidationInfo
from datetime import datetime
from typing import ClassVar

class BoundingBox(BaseModel):
    min_x: float = Field(..., description="Minimum X coordinate")
    max_x: float = Field(..., description="Maximum X coordinate")
    min_y: float = Field(..., description="Minimum Y coordinate")
    max_y: float = Field(..., description="Maximum Y coordinate")

    @field_validator("max_x")
    @classmethod
    def validate_max_x(cls, max_x: float, info: ValidationInfo) -> float:
        data = info.data
        if "min_x" in data and max_x <= data["min_x"]:
            raise ValueError("max_x must be greater than min_x")
        return max_x

    @field_validator("max_y")
    @classmethod
    def validate_max_y(cls, max_y: float, info: ValidationInfo) -> float:
        data = info.data
        if "min_y" in data and max_y <= data["min_y"]:
            raise ValueError("max_y must be greater than min_y")
        return max_y

class RawFieldData(BaseModel):
    field_id: str = Field(..., description="Unique identifier for the field")
    planting_date: str = Field(..., description="Planting date in YYYY-MM-DD format")
    geometry: str = Field(..., description="Geometry in WKT format")
    arrival_time: str = Field(..., description="Arrival time in YYYY-MM-DDTHH:MM:SS format")
    processing_date: str = Field(..., description="Intended processing date in YYYY-MM-DD format")

    @field_validator("planting_date")
    @classmethod
    def validate_planting_date(cls, value: str) -> str:
        try:
            datetime.strptime(value, "%Y-%m-%d")
            return value
        except ValueError:
            raise ValueError("planting_date must be in YYYY-MM-DD format")

    @field_validator("arrival_time")
    @classmethod
    def validate_arrival_time(cls, value: str) -> str:
        try:
            datetime.strptime(value, "%Y-%m-%dT%H:%M:%S")
            return value
        except ValueError:
            raise ValueError("arrival_time must be in YYYY-MM-DDTHH:MM:SS format")

    @field_validator("processing_date")
    @classmethod
    def validate_processing_date(cls, value: str) -> str:
        try:
            datetime.strptime(value, "%Y-%m-%d")
            return value
        except ValueError:
            raise ValueError("processing_date must be in YYYY-MM-DD format")

class ProcessedFieldData(BaseModel):
    field_id: str = Field(..., description="Unique identifier for the field")
    days_since_planting: int = Field(..., description="Days since planting")
    partition_date: str = Field(..., description="Partition date in YYYY-MM-DD format")
    arrival_time: str = Field(..., description="Arrival time in YYYY-MM-DDTHH:MM:SS format")

    model_config: ClassVar[dict] = {"arbitrary_types_allowed": True}