import shapefile
import json
import sys

def import_shapefile(shp_file):
    try:
        sf = shapefile.Reader(shp_file)
        shapes = []
        for shape_record in sf.shapeRecords():
            shape = {
                "type": shape_record.shape.__geo_interface__["type"],
                "points": shape_record.shape.points,
                "record": shape_record.record
            }
            shapes.append(shape)
        return {"status": "success", "data": shapes}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == '__main__':
    shp_file = sys.argv[1]
    result = import_shapefile(shp_file)
    print(json.dumps(result))
