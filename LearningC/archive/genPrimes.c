//this program generates a list of prime number. It doesn't work right.

#include <stdio.h>
#include <stdbool.h>

int main (void)
{
	printf ("Display primes up to what number?\n");
	int numPrimes;
	bool isPrime;
	scanf ("%i", &numPrimes);
	if (numPrimes < 2) {
		printf ("\nLet's assume you meant '2'");
		numPrimes = 2;
	}	

	
	int p, i, primes[numPrimes], primeIndex = 2;

	primes[0] = 2;
	primes[1] = 3;


	for ( p = 5; p <= numPrimes; p = p + 2 ) {
		isPrime = true;

		for ( i = 1; isPrime && p / primes[i] >= primes[i]; i++ )
			if ( p % primes[i] == 0 )
				isPrime = false;

		if ( isPrime == true ) {
			primes[primeIndex] = p;
			++primeIndex;
		}

	}
	
	for ( i = 0; i < primeIndex; ++i )
		printf ("%i  ", primes[i]);

	printf ("\n");

	return 0;


}
