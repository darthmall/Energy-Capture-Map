#!/usr/bin/env python

from argparse import ArgumentParser
import json


def cane(x):
    return 0.86884 + -0.0083336 * x + 0.00091813 * x ** 2 + 1.418e-5 * x ** 3


def maize(x):
    return 0.20317 + 0.0012365 * x + 0.00041396 * x ** 2 + -7.9757e-7 * x ** 3


def process(func, lower, upper, step, threshold):
    lat = lower

    while lat <= upper:
        v = func(lat)

        if v >= threshold:
            yield (lat, func(lat))

        lat += step


def domain(values):
    return (min(values), max(values))


def band(latitude, height):
    return [[[-180.0, latitude + height / 2], [180.0, latitude + height / 2],
        [180.0, latitude - height / 2], [-180.0, latitude - height / 2],
        [-180.0, latitude + height / 2]]]


def features(crop, data, lower, upper, step, quantization):
    features = []

    for k, v in data.iteritems():
        coordinates = band(k, step)
        q = int(round((v - lower) / (upper - lower) *
            100)) / (100 / (quantization - 1))
        properties = {
            'crop': crop,
            'quantization': 'q-{:d}'.format(int(q))}

        features.append({
            'type': 'Feature',
            'geometry': {
                'type': 'Polygon',
                'coordinates': coordinates},
            'properties': properties,
            'id': '{}-{}'.format(crop, k)
        })

    return features


def main(args):
    cane_capture = dict(process(cane, args.cane[0], args.cane[1], args.step,
        args.threshold))
    maize_capture = dict(process(maize, args.maize[0], args.maize[1],
        args.step, args.threshold))

    cane_lower, cane_upper = domain(cane_capture.values())
    maize_lower, maize_upper = domain(maize_capture.values())

    feature_list = features('cane', cane_capture, cane_lower, cane_upper,
        args.step, args.quantization) + features('maize', maize_capture,
        maize_lower, maize_upper, args.step, args.quantization)

    obj = {
        'type': 'FeatureCollection',
        'features': feature_list
    }

    print json.dumps(obj, indent=2)

if __name__ == '__main__':
    parser = ArgumentParser(
        'Generate GeoJSON defining latitude bands of energy capture')
    parser.add_argument('-t', '--threshold', default=1.0, type=float,
        help='Min threshold for energy capture ratio')
    parser.add_argument('--cane', default=[-33.0, 35.0], nargs=2, type=float,
        help='Latitude range to consider for cane in the regression')
    parser.add_argument('--maize', default=[-43.0, 53.0], nargs=2, type=float,
        help='Latitude range to consider for maize in the regression')
    parser.add_argument('--step', default=3.0, type=float,
        help='Step size in degrees for bands')
    parser.add_argument('--quantization', default=5, type=int,
        help='Number of buckets to quantize the values into')

    args = parser.parse_args()

    main(args)
