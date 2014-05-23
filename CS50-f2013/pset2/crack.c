/**
* crack.c
*
* Jeremy Watson
* jeremymwatson@gmail.com
*
* cracks the DES encrypted passwords from C's crypt() function
*
*/
#define _XOPEN_SOURCE
#include <unistd.h>
#include <cs50.h>
#include <stdio.h>
#include <stdlib.h>
#include <crypt.h>
#include <string.h>


int dictAttack(char* encryptedText, char salt[]);
int bruteForce(char* encryptedText, char salt[]);

int main(int argc, char* argv[])
{
    // confirm number of args
    if (argc != 2)
    {   
        printf("Please give exactly one argument (DES hash to crack) to the program");
        return 1;
    }
    
    char* encryptedText = argv[1];
    char salt[3] = {encryptedText[0], encryptedText[1], '\0'};
    int successTest;

    // get return from crack functions 
    successTest = dictAttack (encryptedText, salt);
    
    if (successTest == 0)
    {
        return 0;
    }   
    
    printf("Password not found in given dictionary. Trying brute force...\n");
     
    successTest = bruteForce (encryptedText, salt);

    if (successTest == 0)
    {
        return 0;
    }   
  
    printf("Password not found, are you sure that hash is valid?");
    return 1;
}

// Function definitions

int bruteForce(char* encryptedText, char salt[])
{

    // i represents the current digit being incremented through
    // j is used to check if lower elements need to be iterated (ie once i hits '~')  
    char guess[9] = {' ', '\0'};
    int i = 0; 
    int j = 0; 

    // edge case for just a single space as password
    char* hashedPwd = crypt(guess, salt);
    if (!strcmp(hashedPwd, encryptedText))
    {
        printf("%s\n", guess);
        return 0;
    }

    /**
    * this loops through every printed ASCII char, ' ' through '~'
    * once the last digit hits '~' it turns over, and if necessary
    * adds another char space to iterate through.
    */
    do
    {
        guess[i]++;

        if (guess[i] > '~')
        {
            j = i;
     
            // works from highest element down, checking if they need to be rolled over          
            while (j > 1 && guess[j - 1] >= '~' )
            {
                guess[j - 1] = ' ';
                j--;
            }
                
            // if they aren't rolled over they are incremented by one
            if (j > 0)
            {
                guess[j - 1]++;
            }

            // if the first element is higher than ~, add
            // an element and reset all elements to [' ']
            if (guess[0] > '~')
            {
                i++;
                guess[i] = ' ';
                for (int k = 0; k < i; k++)
                {
                    guess[k] = ' ';
                }
                guess[i + 1] = '\0';
            }

            guess[i] = ' ';

        }

        // encrypt current iteration and check it against the given (argv) hash
        char* hashedPwd = crypt(guess, salt);
        printf("%s\n", guess);
        if (!strcmp(hashedPwd, encryptedText))
        {
            printf("%s\n", guess);
            return 0;
        }
 

    } while (i <= 1);

    return 1;
}




int dictAttack(char* encryptedText, char salt[])
{

    // Prompt user for dict file and open file if found 
    printf("Please give the name of the dictionary file.\n");
    printf("If the file is not in the same directory as the crack program,\n");
    printf("you can specify the directory as well.\n");
    char* dictFile = GetString();
    FILE* dict = fopen(dictFile, "r");
    
    // make sure file opened correctly
    if (dict == NULL)
    {
        printf("file not found, trying brute force\n");
        return 1;
 
    }

    // array to read file string to and length of read string
    char output[256];
    int outputLen;

    // iterates through every string in the file and checks them
    // by encrypting the hash and comparing that to the hash given in argv[1]
    for (int i = 1; fgets(output, sizeof(output), dict) != NULL; i++)
    {
        char* readString = output;

        // remove new line characters so it doesn't mess up the hash
        outputLen = strlen(output);
        readString[outputLen - 1] = '\0';
       
        // encrypt current iteration and check it against the given (argv) hash
        char* hashedPwd = crypt(readString, salt);
        if (!strcmp(hashedPwd, encryptedText))
        {
            printf("Password is: %s\n", readString);
            return 0;
        }
    }

    return 1;

}
