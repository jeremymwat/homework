/**
 * recover.c
 *
 * Computer Science 50
 * Problem Set 5
 * 
 * jeremy watson
 * jeremymwatson@gmail.com
 *
 * Recovers JPEGs from a forensic image.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(void)
{
    // ensure read in file can be opened
    FILE* rawfile = fopen("card.raw", "r");
    if (rawfile == NULL)
    {
        printf("Could not open file to recover.\n");
        perror("fopen");
        return 1;
    }

    // buffer size of jpg blocks
    uint8_t data[512] = {};

    // file num counter for naming files
    int outFileNum = 0;
   
   // ensure file pointer is at beginning of file
   fseek(rawfile, 0, SEEK_SET);

   // find start of jpgs 
    while (!(data[0] == 0xff && data[1] == 0xd8 && data[2] == 0xff && (data[3] == 0xe1 || data[3] == 0xe0))) 
        fread(&data, sizeof(512), 1, rawfile);   
    
    while (1)
    {
        // create string and read filename in to it
        char buf[8];
        sprintf(buf, "%03d.jpg", outFileNum);

        // open new file to write found jpgs
        FILE* output = fopen(buf, "w");
        if (output == NULL)
        {
            printf("Could not open file to write.\n");
            return 1;
        }
   
        // write in jpgs until start of next file is found    
        do
        {
           // read from raw file and write to new image file
            fwrite(&data, sizeof(512), 1, output);           
            fread(&data, sizeof(512), 1, rawfile);
            
            // check for EOF
            if (feof(rawfile))
            {
                // close files and end program if EOF found
                fclose(output);
                fclose(rawfile);
                return 0;
            } 
        }
        while (!(data[0] == 0xff && data[1] == 0xd8 && data[2] == 0xff && (data[3] == 0xe1 || data[3] == 0xe0)));

      
        // close write file and advance file counter
        fclose(output);
        outFileNum++;

    }

    return 0;
}
