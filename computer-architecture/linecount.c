#include <stdio.h>

int linecount(FILE* file);

main(int argc, char** argv)
{
  if (argc != 2) {
    printf("Please provide 1 filename\n");
  } else {
    char* filename;
    filename = argv[1];
    FILE *f = fopen(filename, "rb");

    if (f == NULL)
    {
      printf("ERROR: Could not open file.");
      return -1;
    } else {
      printf("Lines count: %d\n", linecount(f));
    }
  }
}

int linecount(FILE* file)
{
  int count;
  count = 0;

  while(!feof(file)) {
    if (fgetc(file) == '\n')
      count++;
  }

  return count;
}
