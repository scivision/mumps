#include <stdio.h>

extern int addone(int);


int main(void) {

  if(addone(2) != 3) {
    fprintf(stderr, "2 + 1 != %d", addone(2));
    return 1;
  }

  return 0;
}
