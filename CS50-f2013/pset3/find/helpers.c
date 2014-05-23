/**
 * helpers.c
 *
 * Computer Science 50
 * Problem Set 3
 * added to by Jeremy Watson
 * jeremymwatson@gmail.com
 *
 * Helper functions for Problem Set 3.
 */
       
#include <cs50.h>
#include "helpers.h"
#include <stdio.h>

/**
 * Returns true if value is in array of n values, else false.
 */
bool search(int value, int array[], int n)
{
    int low = 0;
    int high = n - 1;

    // binary search through dictionary
    while (low <= high)
    {
        // picks middle of array, checks if value is higher, lower, or equal
        // if not equal, cuts list in half and drops part of list not containing value
        int middle = (low + high) / 2;
        if (array[middle] == value)
        {
            return true;
        }
        else if (value < array[middle])
        {
            high = middle - 1;
        }
        else
        {
            low = middle + 1;
        }
    }
    return false;
}

/**
 * Sorts array of n values using counting sort
 */


void sort(int values[], int n)
{
    // initialize array to hold counts of intetegres with max size of 65536
    int countArray[65537] = {0};

    // count number of times each value appears and place it in index number equal to that value
    for (int i = 0; i < n; i++)
    {
        countArray[values[i]]++;
    }

    // sets each element equal to itself plus the element before
    // this also sets them equal to their eventual position in the final output array
    for (int i = 1; i < 65537; i++)
    {   
        countArray[i] = countArray[i] + countArray[i - 1];
    }
    
    // output array needed as cannot destroy values[] 
    int arrayOutput[n];
    
    // the location of values[i] in countArray equals where i should go in the final array
    for (int i = n - 1; i >= 0; i--)
    {
        arrayOutput[countArray[values[i]] - 1] = values[i];
        countArray[values[i]]--;
    }
    
    // copies sorted arrayOuput to values[]
    for (int i = 0; i < n; i++)
    {
        values[i] = arrayOutput[i];
    }
}


