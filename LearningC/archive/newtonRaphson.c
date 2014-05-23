//This program approximates the square roots of numbers 

#include <stdio.h>

float absoluteValue (float x) {
    if ( x < 0 )
        x = -x;
    return (x);
}


//function approximates the square root

float squareRoot (float x)
{
    const float epsilon = .00001;
    float guess = 1.0;

    while (absoluteValue ( guess * guess - x) >= epsilon )
        guess = ( x / guess + guess ) / 2.0;

    return guess;

}

int main (void)
{
    float targetNumber;
    printf ("Enter the number you would like to get an approximate square root of: ");
    scanf ("%f", &targetNumber);
    printf ("\n Squareroot of %f is about %f",targetNumber, squareRoot (targetNumber));
    scanf ("%f", &targetNumber);
    return 0;
}



