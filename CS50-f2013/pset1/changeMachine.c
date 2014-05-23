//this program calculates the minimum number of coins required to give change

#include <stdio.h>

int main (void)
{
	float userInp;
	int cents, totalCoins;

	printf ("Hello, how much change is owed?\n");
	scanf ("%f", &userInp);

	cents = (int) (userInp * 100);
//	cents = cents - ((int) userInp) * 100;

    printf ("You need %i quarters.\n", (cents/25));
	totalCoins = cents / 25;

    cents -= (cents / 25) * 25;
    printf ("You need %i dimes.\n", (cents/10));	
	totalCoins += cents / 10;

    cents -= (cents / 10) * 10;
    printf ("You need %i nickles.\n", (cents/5));
	totalCoins += cents / 5;

    cents -= (cents / 5) * 5;
    printf ("You need %i pennies.\n", (cents));
	totalCoins += cents;

	printf ("You need %i coins.\n", totalCoins);

	return 0;
}
