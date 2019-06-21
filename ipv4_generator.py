import argparse
import csv
import functools
from ipaddress import IPv4Network, IPv4Address, AddressValueError
from random import getrandbits, sample
import os.path
import sys
from time import time


def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print('=' * 90)
        print('LOGS:')
        start = time()
        result = func(*args, **kwargs)
        print('run time = %.2f' % (time() - start))
        print('=' * 90 + '\n')
        return result
    return wrapper


def prefix_fn(full_path, prefix='mapped_'):
    """prefix a file name with the give full path"""
    head, tail = os.path.split(full_path)
    return os.path.join(head, prefix + tail)


def get_address_number(cidr):
    """Get total number of an IP v4 addresses by a CIDR"""
    subnet = IPv4Network(cidr)
    return 2 ** (subnet.max_prefixlen - subnet.prefixlen)


def get_address_number_native(cidr):
    """Get total number of an IP v4 addresses by a CIDR"""
    net = IPv4Network(cidr)
    return net.num_addresses


def ipv4():
    bits = getrandbits(32)  # generates an integer with 32 random bits
    addr = IPv4Address(bits)  # instances an IPv4Address object from those bits
    addr_str = str(addr)  # get the IPv4Address object's string representation
    return addr_str


def ip_in_subnet(cidr):
    """
    cidr: cidr of the network
    """
    subnet = IPv4Network(cidr)

    # subnet.max_prefixlen contains 32 for IPv4 subnets and 128 for IPv6 subnets
    # subnet.prefixlen is defined in cidr
    bits = getrandbits(subnet.max_prefixlen - subnet.prefixlen)

    # here, we combine the subnet and the random bits
    # to get an IP address from the previously specified subnet
    addr = IPv4Address(subnet.network_address + bits)
    addr_str = str(addr)

    return addr_str


def ip_list(cidr):
    """
    Get a list of IPs in a IP v4 network in random order, most likely, not all unique
    cidr: cidr of the network
    """
    ips = []
    target_number = get_address_number(cidr)
    # print(F'To genenerate {target_number} of random ip in {cidr}')
    i = 0
    while i < target_number:
        ip = ip_in_subnet(cidr)
        ips.append(ip)
        i += 1
        # if ip not in ips:
        #     ips.append(ip)
        #     i += 1

    uniques = list(set(ips))
    # print(F'After clean, unique ip number = {len(uniques)}')
    return uniques


def ip_in_subnet_v2(subnet):
    """
    subnet: IPv4Network instance
    """
    # subnet.max_prefixlen contains 32 for IPv4 subnets and 128 for IPv6 subnets
    # subnet.prefixlen is defined in cidr
    bits = getrandbits(subnet.max_prefixlen - subnet.prefixlen)

    # here, we combine the subnet and the random bits
    # to get an IP address from the previously specified subnet
    addr = IPv4Address(subnet.network_address + bits)
    addr_str = str(addr)

    return addr_str


def random_ip_list(cidr):
    """
    Get a list of IPs in a IP v4 network in random order, most likely, not all unique
    cidr: cidr of the network
    """
    ips = []
    net = IPv4Network(cidr)
    i = 0
    while i < net.num_addresses:
        ip = ip_in_subnet_v2(net)
        ips.append(ip)
        i += 1
        # if ip not in ips:
        #     ips.append(ip)
        #     i += 1

    uniques = list(set(ips))
    # print(F'To genenerate {net.num_addresses} of random ip in {cidr}')
    # print(F'After clean, unique ip number = {len(uniques)}')
    return uniques


def build_until_done(cidr):
    """
    Get a list of unique IPs in a IP v4 network in random order
    cidr: cidr of the network
    """
    tries = 0
    final = []
    target_number = get_address_number(cidr)
    # so_far = ip_in_subnet(cidr)
    # final += so_far
    while len(final) < target_number:
        tries += 1
        # print(F'Try {tries}')
        so_far = ip_list(cidr)
        final += so_far
        final = list(set(final))

    # print(F'We done!')
    return final


def genenerate_all(cidr):
    """
    Get all ip in a range
    cidr: cidr of the network
    """
    return list(IPv4Network(cidr))


def genenerate_shuffle(cidr):
    """Create a list of consecutive ip and shuffle it """
    net = IPv4Network(cidr)
    shuffle = sample(range(net.num_addresses), net.num_addresses)
    return [(str(net[i]), str(net[shuffle[i]])) for i in range(net.num_addresses)]


def dump(mapping, fn='example.csv'):
    """Write a list of two-string tuple"""
    with open(fn, 'wt') as csv_f:
        csv_writer = csv.writer(csv_f)
        csv_writer.writerows(mapping)

# print(ipv4())
# print(ip_in_subnet("10.0.0.0/8"))
# print(ip_in_subnet("172.16.0.0/12"))
# print(ip_in_subnet("192.168.0.0/16"))

# print(get_address_number("10.0.0.0/8"))
# print(get_address_number("172.16.0.0/12"))
# print(get_address_number("192.168.0.0/16"))


# start = time()

# # for ip in build_until_done("172.16.0.0/12"):
# #     # print(ip)
# #     pass

# all_ips = genenerate_all('10.0.0.0/8')
# target_number = len(all_ips)

# p = sample(range(target_number), target_number)

# shuffled = [all_ips[r] for r in p]

# for i in range(255):
#     print(F'{all_ips[i]} vs {shuffled[i]}')

# print(F'It is done in {time() - start:.4f}')

def demo_big_network():
    cidr = '10.0.0.0/8'
    # print('%d vs %d' % (get_address_number(cidr), get_address_number_native(cidr)))
    dump(genenerate_shuffle(cidr))


@timer
def replace_ips(dict_file, part_of_parts):
    # Read csv file into a list of two-string tuple
    with open(dict_file, 'rt') as csv_f:
        csv_reader = csv.reader(csv_f)
        # for row in csv_reader:
        #     print(row)
        mapping = {row[0]: row[1] for row in csv_reader}

    mapped_file = prefix_fn(part_of_parts)
    bunchsize = 10000     # Experiment with different sizes
    bunch = []
    # source_parts should in the mapping file: each subnet has its own
    with open(part_of_parts, 'rt') as r, open(mapped_file, "wt") as w:
        line = r.readline()
        while line:
            source_parts = line.split(',')
            try:
                IPv4Address(source_parts[0])
                source_parts[0] = mapping[source_parts[0]]
                bunch.append(','.join(source_parts))
                if len(bunch) == bunchsize:
                    w.writelines(bunch)
                    bunch = []
            except AddressValueError as err:
                # ignore first field is not an ip, just put it back
                print(err)
                print("first field is not IPv4: %s in %s" % (source_parts[0], line))
                bunch.append(line)
            line = r.readline()
        w.writelines(bunch)


"""
Notes:
split -b YOUR_EXPECTED_SIZES YOUR_FILE_NAME PATTERN_NAME_AS_OUTPUT
cat SPITED_FILES_AS_LIST > NEW_FILE

split -b 100m 6apr.csv parts/6apr.csv.
cat parts/6apr.csv.* > verify.csv
"""


def batch_replace(dict_file, pat):
    import glob
    files = glob.glob(pat)
    for f in files:
        print(f)
        replace_ips('example.csv', f)


def verify_path(path):
    dir_name = os.path.dirname(path)
    if dir_name:
        return os.path.exists(dir_name)
    return os.path.exists(path)


if __name__ == '__main__':
    # replace_ips('example.csv', 'data/parts/6apr.csv.ak')
    # batch_replace('example.csv', 'data/parts/6apr.csv.*')
    parser = argparse.ArgumentParser(description='Mapping IPs to other IPs.')
    parser.add_argument('-m', type=str, dest='mapping', required=True,
                        help='path to mapping csv file')
    parser.add_argument('-s', type=str, dest='source', required=True,
                        help='path to source files of IPs, supports pattern')


    args = parser.parse_args()
    print(args.mapping)
    print(args.source)

    if not verify_path(args.mapping):
        print('path to mapping csv file %s does not exists', args.mapping)
        sys.exit(1)

    if not verify_path(args.source):
        print('path to IP source file %s does not exists', args.source)
        sys.exit(1)
