//This program concatenates c strings

#include <stdio.h>

int main (void)
{
    void concat (char result[], const char Str1[], const char Str2[]);
    int strLen (const char string[]);
   
    const char s1[] = { "Test " };
    const char s2[] = {"works." };
    int finalStrLen = strLen(s1) + strLen(s2) + 1 ;
    
  
    char s3[finalStrLen];
    concat (s3, s1, s2);

    printf ("%s\n", s3);
    return 0;
}

//function to concat two strings

void concat (char result[], const char Str1[], const char Str2[])
{
    int i, j;

    for ( i = 0; Str1[i] != '\0'; ++i )
        result[i] = Str1[i];
    for ( j = 0; Str2[j] != '\0'; ++j )
    result[i + j] = Str2[j];

    result [i + j] = '\0';

}

int strLen (const char string[])
{
    int count = 0;

    while ( string[count] != '\0' )
        ++count;
    return count;
}

