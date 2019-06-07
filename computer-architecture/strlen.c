#include <stdio.h>

int stringlength(char* str);

main(int argc, char** argv)
{
  if (argc != 2) {
    printf("Please provide 1 input\n");
  } else {
    char* input;
    input = argv[1];
    printf("Input: %s\n", input);
    printf("Length: %d\n", stringlength(input));
  }
}

int stringlength(char* str)
{
  int idx;
  idx = 0;
  while (str[idx] != '\0')
    idx++;

  return idx;
}
