/**
*
* Vignere
*
* Jeremy Watson
* jeremymwatson@gmail.com
*
* Uses a vignere cripher to encrypt plaintext given by the user.
* A key string is given by the user via the command line.
*
*/

#include <stdio.h>
#include <string.h>
#include <cs50.h>
#include <ctype.h>

int main (int argc, char* argv[])
{
    // checks that only one argument is given
    if (argc != 2)
    {
        printf("Please give a single key string as argument\n");
        return 1;
    }

    char* key = argv[1];

    // checks each char in key string to be sure it is a alphabetic letter
    int i = 0;
    while (key[i] != '\0')
    {
        if (!isalpha(key[i]))
        {
            printf("Please use only letters in your key\n");
            return 1;
        }
    //converts to lower case for ease of use later
    key[i] = tolower(key[i]);
    i++;        
    }

    // this block gets the length of the key, declares two iterators (m&n)
    // and uses the 
   
    // get string from user
    char* plainText = GetString();

    // this block declares two iterators and gets the length of the key
    // via the while loop, the block iterates through each char in the 
    // string. It applies the Vignere cipher and  (as long as the char 
    // of the string is a alphabetic letter) moves to the next char in
    // the key to prepare to encode the next char in the plaintext

    int keyLength = strlen(key);
    int j = 0;
    int k = 0;

    while (plainText[j] != '\0')
    {
        if ((plainText[j] >= 'A' && plainText[j] <= 'Z'))
        {
            plainText[j] = (((plainText[j] - 'A') + key[k] - 'a') % 26) + 'A';
   
        }
        if ((plainText[j] >= 'a' && plainText[j] <= 'z'))
        {
            plainText[j] = (((plainText[j] - 'a') + key[k] - 'a') % 26) + 'a';
        }
    j++;
        if (isalpha(plainText[j]))
        {
            k++;
            k %= keyLength;
        }
    }

    printf("%s\n", plainText);
    return 0;
}
