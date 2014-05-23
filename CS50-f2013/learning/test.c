#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <cs50.h>
#include <string.h>
#include <ctype.h>


int main(void)
{
    char c;
    do
    {
        c = GetChar();
        if (isalpha(c))
            c = toupper(c);
    } 
    while (!isalpha(c));
    printf("%c\n", c);
    return 0;





}
