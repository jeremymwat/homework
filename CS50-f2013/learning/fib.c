#include <cs50.h>
#include <stdio.h>

int fib(int n);

int main(void)
{
    printf("Please give me an int: ");
    int fibInt = GetInt();

    fibInt = fib(fibInt);
    
    printf("Number: %d\n", fibInt);

}

int fib(int n)
{
    if (n <= 2)
        return 1;
    
    return (fib(n - 1) + fib(n - 2));

}
