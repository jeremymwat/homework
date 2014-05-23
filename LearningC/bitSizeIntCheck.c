//this should give the number of bits in an int on the machine
//this program runs in

#include <stdio.h>

int numBits (void)
{
    int count = 0;
    unsigned int test = 0u;
    test |= ~0;
    
    while (test != 0)
       {
       test <<= 1;
       count++;
       }
       return count;
}

int main (void)
{
    int numbits (void);
    printf("This computer has %i bit integers.\n", numBits());
    return 0;
}

