/* this program reads in some ints (grades) and gives the average.*/

#include <stdio.h>

int main (void)
{
	int	numberOfGrades, i, grade;
	int	gradeTotal = 0;
	int	failureCount = 0;
	float 	average;

	printf ("How many grades will you be entering? ");
	scanf ("%i", &numberOfGrades);

	for ( i = 1; i <= numberOfGrades; i++ ) {
		printf ( "Enter grade #%i: ", i);
		scanf ( "%i", &grade);

		gradeTotal = gradeTotal + grade;

		if ( grade < 65 ) failureCount++;

	}

	average = (float)gradeTotal / numberOfGrades;

	printf ( "\nAverage is %f", average);
	printf ( "\nNumber of failures is %i\n", failureCount);

	return 0;
}
