/**
*
* Caesar 
*
* Jeremy Watson
* jeremymwatson@gmail.com
*
* converts a plain text string to ciphertext based on a ROT#
* encryption, where the # is given as a command line argument
*
*
*/

#include <stdio.h>
#include <string.h>
#include <cs50.h>
#include <stdlib.h>

int main (int argc, char* argv[])
{
    // checks for one and only one argument
    if (argc != 2)
    {
        printf("Please give exactly one argument to the program\n");
        return 1;
    }
    // sets rotation amount
    int rot = atoi(argv[1]);

    // get string from user
//    printf("Please enter the word or phrase you would like to encode\n");
    char* plainText = GetString();
  
    // encrypt string
    int i = 0;
    while (plainText[i] != '\0')
    {
        if ((plainText[i] >= 'A' && plainText[i] <= 'Z'))
        {
            plainText[i] = (((plainText[i] - 'A') + rot) % 26) + 'A';
   
        }
        if ((plainText[i] >= 'a' && plainText[i] <= 'z'))
        {
            plainText[i] = (((plainText[i] - 'a') + rot) % 26) + 'a';
        }
    i++;
    }

    printf("%s\n", plainText);
    return 0;
}


