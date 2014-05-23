/* Created by Jeremy
*
*adds all numbers between 1 and 100
*
*/


#include <iostream>
#include "simpio.h"
#include <string>
using namespace std;

void addSumNum()
{
	int total = 0;
	for (int i = 1; i < 101; i++) {
		total += i;
	}
	cout << total;
	string pause = getLine();
}