#!/usr/bin/env python

from argparse import ArgumentParser
import geojson


def latBand(step):
    lat = -90.0

    while lat <= 90.0:
        yield (lat + step, 180.0, lat, -180.0)

        lat += 2 * step


def longBand(step):
    longitude = -180.0

    while longitude <= 180.0:
        yield (90.0, longitude + step, -90.0, longitude)

        longitude += 2 * step


def main(args):
    features = []

    if args.equator:
        geom = geojson.LineString([[-180, 0], [180, 0]])
        features.append(geojson.Feature('equator', geom))

    if args.tropics:
        cancer = geojson.LineString([[-180, 23.4378], [180, 23.4368]])
        features.append(geojson.Feature('cancer', cancer))

        capricorn = geojson.LineString([[-180, -23.4378], [180, -23.4378]])
        features.append(geojson.Feature('capricorn', capricorn))

    if args.lat:
        for top, right, bottom, left in latBand(args.lat):
            geom = geojson.Polygon([[top, left], [top, right],
                [bottom, right], [bottom, left]])

            features.append(geojson.Feature(geometry=geom))

    if args.long:
        for top, right, bottom, left in longBand(args.long):
            geom = geojson.Polygon([[top, left], [top, right],
                [bottom, right], [bottom, left]])

            features.append(geojson.Feature(geometry=geom))

    collection = geojson.FeatureCollection(features, indent=2)

    print geojson.dumps(collection)

if __name__ == '__main__':
    parser = ArgumentParser(
        'Generate a GeoJSON file containing customized graticules')
    parser.add_argument('--lat', type=float,
        help='Set the band size for latitude bands in degrees')
    parser.add_argument('--long', type=float,
        help='Set the band size for longitude bands in degress')
    parser.add_argument('--equator', action='store_true',
        help='Include a line for the equator in the output')
    parser.add_argument('--tropics', action='store_true',
        help='Include lines for the tropcis in the output')

    args = parser.parse_args()

    main(args)
