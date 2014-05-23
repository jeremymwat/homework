#define _XOPEN_SOURCE
#include <unistd.h>
#include <cs50.h>
#include <stdio.h>
#include <stdlib.h>
#include <crypt.h>
#include <string.h>

int main(int argc, char* argv[])
{

    if (argc != 3)
    {   

        printf("Please give exactly two arguments (string to hash and salt) to the program\n");
        return 1;
    }

    char* test = argv[1];
    char* salt = argv[2];
    char* printMe = crypt(test, salt);
    printf("%s\n", printMe);
    return 0;


} 
