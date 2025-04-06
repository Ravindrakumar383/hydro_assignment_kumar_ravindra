from typing import List
import geopandas as gpd
from datetime import datetime
from src.models.geospatial_models import BoundingBox, RawFieldData
from src.utils.logging import setup_logger

class GeospatialProcessor:
    """Handles geospatial data processing within a bounding box."""

    def __init__(self, bounding_box: BoundingBox):
        self.bounding_box = bounding_box
        self.logger = setup_logger(__name__)

    def _create_geodataframe(self, fields: List[RawFieldData]) -> gpd.GeoDataFrame:
        """Create a GeoDataFrame from raw field data."""
        try:
            return gpd.GeoDataFrame(
                [field.model_dump() for field in fields],
                geometry=gpd.GeoSeries.from_wkt([field.geometry for field in fields])
            )
        except Exception as e:
            self.logger.error(f"Error creating GeoDataFrame: {str(e)}")
            raise

    def _filter_by_bbox(self, gdf: gpd.GeoDataFrame) -> gpd.GeoDataFrame:
        """Filter GeoDataFrame to include only fields within the bounding box."""
        filtered_gdf = gdf.cx[
            self.bounding_box.min_x:self.bounding_box.max_x,
            self.bounding_box.min_y:self.bounding_box.max_y
        ]
        self.logger.info(f"Filtered {len(filtered_gdf)} fields within bounding box.")
        return filtered_gdf

    def filter_fields_in_bbox(self, fields: List[RawFieldData]) -> gpd.GeoDataFrame:
        """Filter fields within the bounding box using GeoPandas."""
        gdf = self._create_geodataframe(fields)
        return self._filter_by_bbox(gdf)

    def get_days_since_planting(self, planting_date: str, partition_date: str) -> int:
        """Calculate the number of days between planting and partition dates."""
        try:
            planting_dt = datetime.strptime(planting_date, "%Y-%m-%d")
            partition_dt = datetime.strptime(partition_date, "%Y-%m-%d")
            return (partition_dt - planting_dt).days
        except ValueError as e:
            self.logger.error(f"Error parsing dates: {str(e)}")
            raise