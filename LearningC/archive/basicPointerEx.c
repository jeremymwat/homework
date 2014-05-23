//Just a basic demonstration of what pointers do

#include <stdio.h>

int main (void)
{
	int count = 10, x;
	int *int_pointer;

	int_pointer = &count;
	x = *int_pointer;

	printf ("Count = %i, x = %i\n", count, x);

	return 0;

}
