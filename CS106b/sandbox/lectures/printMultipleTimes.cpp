/* Created by Jeremy
*
*
*
*/


#include <iostream>
#include "simpio.h"
#include <string>
using namespace std;

void printMultipleTimes()
{
	cout << "How much do you love 106B ";
	int howAwesome = getInteger();
	for (int i = 0; i < howAwesome; i++)
		cout << "some" << endl;
}