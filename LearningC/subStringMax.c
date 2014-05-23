//this should find the maximum you can get adding a subarray from an array

#include <stdio.h>

int maxI (int a, int b)
{
	int max = (a >= b) ? a : b;
	return max;
}


int main (void)
{
	int array[] = { -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5};
	int n = 11;
	int maxSoFar = 0, i = 0;
	int maxHere = 0;
	printf ("%i\n", maxSoFar);

	for (i = 0; i < n; i++) {
		printf ("%i\n", maxSoFar);
		maxHere = maxI(maxHere + array[i], 0);
		maxSoFar = maxI(maxSoFar, maxHere);
	}
	printf ("The max is %i.\n", maxSoFar);
	return 0;
}
			
