#include <stdio.h>
#include <cs50.h>

void swap(int* a, int* b);


int main(void)
{
    int x = 1;
    int y = 2;
    printf("x: %d, y: %d\n", x, y);
    printf("swapping..\n");
    swap(&x, &y);
    printf("x: %d, y: %d\n", x, y);
    return 0;

}

void swap(int* a, int* b)
{

    int tmp = *a;
    *a = *b;
    *b = tmp;


}
