/* tests if a number is even or odd */

#include <stdio.h>

int main (void)
{

	int givenNum;

	printf ( " Please enter the number you would like to test: ");
	scanf ("%i", &givenNum);

	if (givenNum % 2 == 0) 
		printf ("It is even\n");
	else
		printf ("It is odd\n");

	return 0;
}
