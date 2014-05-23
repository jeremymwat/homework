/** This is a test to read a file
*
*
*
*
*/

int main(void)
{
    FILE* fp = fopen(argv[1], "r");

    // check for successful open

    if (fp == null)
    {
        printf("Could not open %s\n", argv[1]);
        return 1;
    }

    // storage space for each line of text
    char output[256];

    // get text from user and print to screen
    for (int i = 1; fgets(output, sizeof(output), fp) != NULL; i++)
        printf("Line %02d: %s", i, output);

    // close file
    fclose(fp);

    return 0;




}
