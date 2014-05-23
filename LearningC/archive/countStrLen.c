//this program finds the string length of a given string

#include <stdio.h>

int stringLength (const char string[])
{
	int count = 0;

	while ( string[count] != '\0')
		count++;

	return count;
}

int main (void)
{
	int stringLength (const char string[]);
	const char word1[] = { 'a','s','t','e','r','\0' };
	const char word2[] = { 'j','e','s','s','e','\0' };
	const char word3[] = { 's','t','e','l','l','\0' };

	printf ("Word lengths: %i %i %i\n", stringLength (word1), stringLength (word2), stringLength (word3));

	return 0;

}
