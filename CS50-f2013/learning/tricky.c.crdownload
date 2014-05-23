/*******************************************
Wesley Chen
Section Week 3
Created CS50 Fall 2013
Pre and Post Increment Examples
********************************************/

#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int data[10] = {};
    int k = 5;
    data[k++] = 1;
    printf("Array ");
    for (int i = 0; i < 10; ++i)
    {
        printf("%d ", data[i]);
    }
    printf("k: %d\n", k);  
    
    int data2[10] = {};
    int k2 = 5;
    data2[++k2] = 1;
    printf("Array2 ");
    for (int i = 0; i < 10; ++i)
    {
        printf("%d ", data2[i]);
    }
    printf("k2: %d\n", k2);
    
    
    int x = 0, y = 2, z = 5;
    printf("initial\n");
    printf("x: %d, y: %d, z: %d\n", x, y, z);
    
    printf("y = ++x\n");
    y = ++x;
    printf("x: %d, y: %d, z: %d\n", x, y, z);
    
    printf("x = y++\n");
    x = y++;
    printf("x: %d, y: %d, z: %d\n", x, y, z);
    
    printf("z = ++x + y++\n");
    z = ++x + y++;
    printf("x: %d, y: %d, z: %d\n", x, y, z);
    
    return 0;
}

