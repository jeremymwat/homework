/**
* credit.c (hacker ed)
*
* Jeremy M. Watson
* jeremy_watson@harvard.edu
*
* Takes in a credit card number and determines if it is valid
* if it is, it prints the type of card.
*/

#include <stdio.h>
#include <cs50.h>

int main(void)
{
 

    long long ccNumber;
<<<<<<< HEAD
    int n = 0; //this represents the digits that were not multiplied by 2
    int m = 0; //this represents the other digits
=======
    int m, n;
    n = 0; // variable stores the operations on the digits of the CC number
    m = 0; // this counts the number of digits
>>>>>>> 5cc7faa689f0510267b7d693e69176ab7e3da38b

    printf("Please enter a number to check:");
    ccNumber = GetLongLong();
    long long ftd = ccNumber; // ftd stands for First Two Digits

    // gut check to be sure numbers fall within range of all allowable cards

    if (ccNumber >= 5600000000000000 || ccNumber < 4000000000000)
    {
        printf("INVALID\n");
        return 0 ;
    }

    // gets the first two digits for testing later
    while (ftd >= 100)
    {
        ftd /= 10;
    }

    // while loop that adds the digits, alternating so that the first read digit
    // is added to n with no modification, but the second is multipled by two
    // and the resulting digits are added.

    while (ccNumber != 0)
    {
        n += (ccNumber % 10);

        ccNumber /= 10;

        m++;

        //this if block checks if the digit * 2 is 10 or larger
        //if it is, it subtracts 9, which is the same as if
        //you added each digit of the number together

        if ((ccNumber % 10) * 2 > 9)
        {
            n += ((ccNumber % 10) * 2 - 9);
        }
        else
        {
            n += (ccNumber % 10) * 2;
        }

        if (ccNumber != 0)
        {
            m++;
        }

        ccNumber /= 10;

    }


    if (n % 10 != 0) // checks if digit total (n) modulo 10 is congruent to 0
    {
        printf("INVALID\n");
        return 0;
    }

    // checks conditions for m (number of digits) and ftd (starting two digits)

    
    if ((ftd == 34 || ftd == 37) && m == 15)
    {
        printf("AMEX\n");
        return 0;
    }

    if ((ftd < 56 && ftd > 50) && m == 16)
    {
        printf("MASTERCARD\n");
        return 0;
    }

    if (ftd / 10 == 4 && (m == 13 || m == 16))
    {
        printf("VISA\n");
        return 0;
    }

    printf("INVALID\n");

    return 0;
}
