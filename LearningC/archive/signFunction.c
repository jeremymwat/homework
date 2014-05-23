//This is a sign function.

#include <stdio.h>

int main (void)
{

	int userInput;

	printf ("Please enter the number you would like to test: ");
	scanf ("%i", &userInput);

	if (userInput > 0)
		printf ("1");
	else if (userInput == 0)
		printf ("0");
	else
		printf ("-1");

	printf ("\n");
	return 0;
}
