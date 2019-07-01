import argparse

import ipv4_generator


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Reorder sequential IPs in a range.')
    parser.add_argument('net_def', type=str,
                        help='network defintion, e.g. 172.16.0.0/12')
    parser.add_argument('output_fn', type=str,
                        help='path to the result csv file.')

    args = parser.parse_args()

    print('Generating a mapping csv file %s for network %s' %
          (args.output_fn, args.net_def))

    ipv4_generator.dump(
        ipv4_generator.genenerate_shuffle(args.net_def), args.output_fn)
