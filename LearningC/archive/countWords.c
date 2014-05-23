//This program counts the number of words in an inputted string
//It doesn't work, the scanf only counts the first word (delineated by a space)
//It would be easy to test by creating a static string but I know this works so I'm done with it.
#include <stdio.h>
#include <stdbool.h>

bool alphabetic (const char c)
{
	if ( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') )
		return true;
	else	
		return false;
}

int countWords (const char string[])
{
	int i, wordCount = 0;
	bool lookingForWord = true, alphabetic (const char c);

	for ( i = 0; string[i] != '\0'; ++i)
		if ( alphabetic(string[i]) )
		{
			if ( lookingForWord )
			{
				++wordCount;
				lookingForWord = false;
			}
		}
		else
			lookingForWord = true;

	return wordCount;
}

int main (void)
{
	int countWords (const char string[]);
	const char text1[81];
	scanf ("%80s", text1);

	printf ("%i", countWords (text1));

	return 0;

}

