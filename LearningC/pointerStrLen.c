//This uses pointers to find the length of a string

#include <stdio.h>

int strLen (const char *string)
{
    const char *cptr = string;
    while (*cptr )
        ++cptr;
    return cptr - string;
}

int main (void)
{
    int strLen (const char *string);

    printf ("%i ", strLen ("strLen test"));
    printf ("%i ", strLen (""));
    printf ("%i ", strLen ("complete"));

    return 0;

    }
