import argparse
import os.path
import sys

import ipv4_generator


def verify_path(path):
    """Verify if a directory of a path exist"""
    dir_name = os.path.dirname(path)
    if dir_name:
        return os.path.exists(dir_name)
    return os.path.exists(path)


def ensure_path(path, msg):
    if not verify_path(path):
        print(msg)
        sys.exit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Mapping IPs to other IPs.')
    parser.add_argument('-m', type=str, dest='mapping', required=True,
                        help='path to mapping csv file')
    parser.add_argument('-s', type=str, dest='source', required=True,
                        help='path to source files of IPs, supports pattern')

    args = parser.parse_args()
    print(args.mapping)
    print(args.source)

    ensure_path(args.mapping,
                'path to mapping csv file %s does not exists' % args.mapping)

    ensure_path(args.source,
                'path to IP source file "%s" does not exists' % args.source)

    ipv4_generator.batch_replace(args.mapping, args.source)
