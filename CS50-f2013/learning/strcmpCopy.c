#include <stdio.h>
#include <string.h>


int strcmpAlphaRemixTurboEdition(const char *s1, const char *s2);

int main(void)
{
    const char* string1 = "z";
    const char* string2 = "z";

    int test = strcmpAlphaRemixTurboEdition(string1, string2);
    printf("%d\n", test);
    return 0;


}

int strcmpAlphaRemixTurboEdition(const char *s1, const char *s2)
{
    if (s1 == NULL || s2 == NULL)
    {
        if (s1 == s2)
            return 0;
        if (s1 == NULL)
            return -1;
        else
            return 1;
    }
    
    int i = 0;
    while (s1[i] != '\0' && (s2[i]) != '\0')
    {
        if ((s1[i]) != (s2[i]))
            return (s1[i]) - (s2[i]);
        i++;
    }

    return 0;
}
