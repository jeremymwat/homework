/*******************************************
Wesley Chen
Section Week 3
Created CS50 Fall 2013
Merge Sort!!!
    To Do: Definitely practice commenting this
********************************************/

#include <cs50.h>
#include <stdio.h>

#define MAX 100

void mergeSort(int data[], int min, int max);

void merge(int data[], int min, int mid, int max);

void showOutput(int data[], int actualSize);

int main(void)
{
    int data[MAX];
    int actualSize = MAX;
    printf("Please enter values you wish to store, up to 100, with -999 to quit\n");
    for (int i = 0; i < MAX; ++i)
    {
        data[i] = GetInt();
        
        if (data[i] == -999)
        {
            actualSize = i;
            break;
        }
    }

    mergeSort(data, 0, actualSize - 1);

    showOutput(data, actualSize);    
    
    return 0;
}

void mergeSort(int data[], int min, int max)
{
    if (min < max)
    {
        int mid = (max + min) / 2;
        mergeSort(data, min, mid);
        mergeSort(data, mid + 1, max);
        merge(data, min, mid, max);
    }

}

void merge(int data[], int min, int mid, int max)
{
    int temp[MAX];
    int leftCount = min, rightCount = mid + 1, sortCount = 0;
    while (leftCount <= mid && rightCount <= max)
    {
        if (data[leftCount] <= data[rightCount])
        {
            temp[sortCount++] = data[leftCount++];
        }
        else 
        {
            temp[sortCount++] = data[rightCount++];
        }
    }
    
    while (leftCount <= mid)
    {
        temp[sortCount++] = data[leftCount++];
    }
    
    while (rightCount <= max)
    {
        temp[sortCount++] = data[rightCount++];
    }
    
    sortCount--;
    
    while (sortCount >= 0)
    {
        data[min + sortCount] = temp[sortCount];
        sortCount--;
    }
    
    showOutput(data, 10);
}

void showOutput(int data[], int actualSize)
{
    for (int i = 0; i < actualSize; ++i)
    {
        printf("%d ", data[i]);
    }
    printf("\n");
    
    return;
}
