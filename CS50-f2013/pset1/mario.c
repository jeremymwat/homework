/**
* mario.c (hacker ed)
*
* Jeremy M. Watson
* jeremy_watson@harvard.edu
*
* prints two pyramids at a height given by the user
*/

#include <stdio.h>
#include <cs50.h>


int main(void)
{

    int height, i, j;
    printf("Height: ");
    // do-while loop takes in input, checks it, asks for reentry if necessary
    do 
    {
        height = GetInt();
        if (height > 23 || height < 0)
        {
            printf("Please enter an integer between 0 and 23\n");
        }
    }
    while (height > 23 || height < 0);

    // nested for loops, first loop iterates through each level of height
    // interior set of for loops generates the spaces and hashes
    // probably could have used a function to clean up recycled code,
    // but this is so small creating the
    // function likely would have taken up just as much space.
    for (i = 0; i < height; ++i)
    {
        for (j = i; j < height - 1; j++)
        {
            printf(" ");
        }
        for (j = 0; j < i + 1; j++)
        {
            printf("#");
        }
        printf("  ");
        for (j = 0; j < i + 1; j++)
        {
            printf("#");
        }
<<<<<<< HEAD
=======

>>>>>>> 5cc7faa689f0510267b7d693e69176ab7e3da38b
       printf("\n");
      
    }
    return 0;
}


