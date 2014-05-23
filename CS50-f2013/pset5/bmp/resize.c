/**
 *resize.c  
 *
 * jeremy watson
 * jeremymwatson@gmail.com
 *
 * Resizes a file by factor given at command line
 */
       
#include <stdio.h>
#include <stdlib.h>

#include "bmp.h"

int main(int argc, char* argv[])
{
    // ensure proper usage
    if (argc != 4)
    {
        printf("Usage: ./resize scale infile outfile\n");
        return 1;
    }

    // set size to scale
    int scaleSize = atoi(argv[1]);
    
    // ensure resize is between 1 and 100
    if (scaleSize < 1 || scaleSize > 100)
    {
        printf("Please provide a scale between 1 and 100, inclusive");
    }


    // remember filenames
    char* infile = argv[2];
    char* outfile = argv[3];

    // open input file 
    FILE* inptr = fopen(infile, "r");
    if (inptr == NULL)
    {
        printf("Could not open %s.\n", infile);
        return 2;
    }

    // open output file
    FILE* outptr = fopen(outfile, "w");
    if (outptr == NULL)
    {
        fclose(inptr);
        fprintf(stderr, "Could not create %s.\n", outfile);
        return 3;
    }

    // read infile's headers and create copy for resized outfile
    BITMAPFILEHEADER bf, newbf;
    fread(&bf, sizeof(BITMAPFILEHEADER), 1, inptr);
    newbf = bf;

    BITMAPINFOHEADER bi, newbi;
    fread(&bi, sizeof(BITMAPINFOHEADER), 1, inptr);
    newbi = bi;

    // determine padding for scanlines of input and resized image file
    int inPadding = (4 - (bi.biWidth * sizeof(RGBTRIPLE)) % 4) % 4;
    int padding = (4 - (bi.biWidth * scaleSize * sizeof(RGBTRIPLE)) % 4) % 4;

    // ensure infile is (likely) a 24-bit uncompressed BMP 4.0
    if (bf.bfType != 0x4d42 || bf.bfOffBits != 54 || bi.biSize != 40 || 
        bi.biBitCount != 24 || bi.biCompression != 0)
    {
        fclose(outptr);
        fclose(inptr);
        fprintf(stderr, "Unsupported file format.\n");
        return 4;
    }
   
    // write updated header information for outfile
    newbi.biHeight = (bi.biHeight * scaleSize);
    newbi.biWidth = (bi.biWidth * scaleSize);
    newbi.biSizeImage = (abs(newbi.biHeight) * (newbi.biWidth * sizeof(RGBTRIPLE) + padding));
    newbf.bfSize = sizeof(bi) + sizeof(bf) + newbi.biSizeImage;

    // write outfile's BITMAPFILEHEADER
    fwrite(&newbf, sizeof(BITMAPFILEHEADER), 1, outptr);

    // write outfile's BITMAPINFOHEADER
    fwrite(&newbi, sizeof(BITMAPINFOHEADER), 1, outptr);

    // iterator for scaling vertically
    int scaleVert = 1;

    // iterate over infile's scanlines
    for (int i = 0, biHeight = abs(bi.biHeight); i < biHeight; scaleVert++)
    {
        // iterate over pixels in scanline
        for (int j = 0; j < bi.biWidth; j++)
        {
            // temporary storage
            RGBTRIPLE triple;

            // read RGB triple from infile
            fread(&triple, sizeof(RGBTRIPLE), 1, inptr);
            
            // write RGB triple to outfile scaleSize times
            for (int k = 0; k < scaleSize; k++)
                fwrite(&triple, sizeof(RGBTRIPLE), 1, outptr);
            
       }

        // skip over padding, if any
        fseek(inptr, inPadding, SEEK_CUR);

        // then add it back (to demonstrate how)
        for (int k = 0; k < padding; k++)
        {
            fputc(0x00, outptr);
        }

        // only increase i if done scaling scanlines vertically
        if (scaleVert == scaleSize)
        {
            i++;
            scaleVert = 0;
        }
        else
        {
            fseek(inptr, -(bi.biWidth * sizeof(RGBTRIPLE) + inPadding ), SEEK_CUR);
        }
    }

    // close infile
    fclose(inptr);

    // close outfile
    fclose(outptr);

    // that's all folks
    return 0;
}
