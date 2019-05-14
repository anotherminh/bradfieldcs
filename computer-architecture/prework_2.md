## Data Encoding

|Binary| Hex |
|----|---|
| 0000 | 0 |
| 0001 | 1 |
| 0010 | 2 |
| 0011 | 3 |
| 0100 | 4 |
| 0101 | 5 |
| 0110 | 6 |
| 0111 | 7 |
| 1000 | 8 |
| 1001 | 9 |
| 1010 | a |
| 1011 | b |
| 1100 | c |
| 1101 | d |
| 1110 | e |
| 1111 | f |

Q: Test yourself by converting the numbers 9, 136 and 247 to hexadecimal.
```
9 = 0x9
136 =  0x88
246 = 0xf6
```

Q: In CSS, how many colors can be represented in the hexadecimal form?
```
In CSS, colors can be represented using 6 hexidecimal numbers, which means we have a range from 0x000000 to 0xffffff. That's 16,777,216 colors.
```

Q: How about in the RGB form?
```
Using RGB, we have 3 values (red, green, and blue), each with a range from 0 to 255. That's 256^3 = 16,777,216 colors. The RBG format and hexadecimal format are equivalent. You can express each value in the RBG triplet using 2 hexadecimal digits (0xff == 255).
```

Q: Convert the numbers 12 and 9 to binary, adding the binary values together, and converting the result back to decimal to verify your calculation. Do these by hand.
```
12 = 1100
9 = 1001
1100 + 1001 = 10101
10101 = 2^4 + 2^2 + 1 = 1 + 4 + 16 = 21
```

Q: What would the result be if it were constrained to 4 bits?
```
0101
```

Q: How many numbers can be represented in total with 4, 8, 16 or 32 bits respectively?
```
4 bits => 16 numbers
8 bits => 256 numbers
16 bits => 65536 numbers
32 => 4294967296 numbers
```

Notes:
To find two's complement for a negative number, flip all the 1's and 0's, then add 1.
e.g. -5 = 0101 => 1010 + 1 = 1011

To convert a negative two's complement number into decimal, minus 1 and then flip all the 1's and 0's, then prefix the negative sign.
e.g. 1010 => 1010 - 1 = 1001 => 0110 = -6

Q: Test yourself by converting the numbers 12 and -9 to binary using the two’s complement representation, adding the binary values together, and converting the result back to decimal.
```
12 = 0000 1100
-9 = 1001 => 0110 + 1 => 1111 0111

  0000 1100
+ 1111 0111
------------
  0000 0011 = 3
```

Q: Similarly compute -3 - 4 (“negative three, minus four”). What are the largest and smallest numbers representable in 32 bit 2’s complement?
```
-3 = 0011 => 1100 + 1 => 1101
4 = 0100

1101 - 0100 = 1001
1001 = 1001 - 1 = 1000 => 0111 = -7
```

Q: If you saw port 8000 represented as 0x1f40, would you conclude that TCP uses big-endian or little-endian integers? How would you represent port 3000?
TCP uses big-endian, because 0x1f40 is 8000, while 0x401f is 16415
Port 3000 would be 0xbb8

Q: What are the largest and smallest values representable with 64-bit floats?
Nice explannation of how floating point numbers are represented in memory (IEEE standard): https://steve.hollasch.net/cgindex/coding/ieeefloat.html
For double-precision floats in 64 bits, we use 1 bit for sign, 11 bits for encoding exponent, and the remaining 52 bits for handling significant digits.
For the exponent, the bias is 1023, which means the exponent range is -1023 to 1024.
This means that the biggest number we can represent with 64-bit float is `2^52 * 2^1024`
And the smallest number in 64-bit float is `-2^52 * 2^1024` (where the smallest positive number is 2^-52 * 2^-1023?)

Q: Is there any additional space cost to encoding a purely ASCII document as UTF-8?
There shouldn't be, as ASCII uses only 7 bits for encoding characters, with the first bit reserved for control. UTF-8 encodes all ASCII characters using 8 bits, with a leading 0 for the first bit. Both uses 1 byte to encode 1 character.

Q: What are the pros and cons detriments of UTF-8 compared to another encoding for Unicode such as UTF-32?
UTF-32 is fixed length encoding -- it always uses 32 bits to encode a single character.
UTF-8 (and UTF-16) is variable length encoding, which means it uses more or less bits depending on which character you're trying to encode. To encode the extra piece of information about byte length, UTF-8 (and UTF-16) will require less space to encode smaller-byte characters, but extra space to encode larger-byte characters. UTF-32 will have lots of wasted 0's for smaller-byte characters, but for large characters it is more space efficient, not having to encode the extra information about character byte length or continuation byte.
