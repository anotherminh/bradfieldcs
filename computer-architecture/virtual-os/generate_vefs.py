import binascii
import re

# The two are almost identical -- subtract instead of add is a 4 instead of a 3
# and 256 instead of 255 in the first data input
add_255_3 = re.sub(r'\s', '', """
02
00 0d 00
8e 06 0d
010110 010212 030102 02010e ff
0000 ff00 0300""")
sub_256_3 = re.sub(r'\s', '', """
02
00 0d 00
8e 06 0d
010110 010212 040102 02010e ff
0000 0001 0300""")

programs = [("add_255_3.vef", add_255_3), ("sub_256_3.vef", sub_256_3)]

for name, prog in programs:
    with open(name, 'wb') as output_binary:
        output_binary.write(binascii.unhexlify(prog))
