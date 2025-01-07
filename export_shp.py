import shapefile
import json
import sys

def export_shapefile(json_file, output_shp):
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)

        shp = shapefile.Writer(output_shp)
        shp.field('name', 'C') 

        for item in data:
            geometry_type = item['type']
            points = item['points']

            if geometry_type == 'Point':
                shp.point(points[0][0], points[0][1])
                shp.record(item.get('name', 'Unnamed'))
            elif geometry_type == 'LineString':
                shp.line([points])
                shp.record(item.get('name', 'Unnamed'))
            elif geometry_type == 'Polygon':
                shp.poly([points])
                shp.record(item.get('name', 'Unnamed'))

        shp.close()
        return {"status": "success"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == '__main__':
    json_file = sys.argv[1]
    output_shp = sys.argv[2]
    result = export_shapefile(json_file, output_shp)
    print(json.dumps(result))
