#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

unsigned long bintodec(char *binstr);

main(int argc, char** argv)
{
  if (argc != 2) {
    printf("Please provide a valid binary number as input.\n");
  } else {
    char *input = argv[1];
    printf("Binary number entered: %s\n", input);
    printf("Decimal: %lu\n", bintodec(input));
  }
}

unsigned long bintodec(char *binstr)
{
  long dec = 0;
  for (int idx = 0; binstr[idx] != '\0'; idx++) {
    char current_char = binstr[idx];
    int current_digit;

    if (current_char == '0') {
      current_digit = 0;
    } else if (current_char == '1') {
      current_digit = 1;
    } else {
      printf("Invalid binary string.\n");
      exit(EXIT_FAILURE);
    }

    dec = dec * 2 + current_digit;
  }
  return dec;
}
