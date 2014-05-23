/* This program tests the input to see if it is a leap year */

#include <stdio.h>

int main (void)
{


	int userYear;
	
	printf ("Please enter the year you would like to test: ");
	scanf ("%i", &userYear);

	if ( userYear % 400 == 0 || (userYear % 4 == 0 && userYear % 100 != 0))
		printf ("It is a leap year");
		else
			printf ("It is not a leap year.\n"); 

	return 0;

}

