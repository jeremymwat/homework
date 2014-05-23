/* Created by Jeremy
*
*
*
*/


#include <iostream>
#include "simpio.h"
#include <string>
using namespace std;

void convertMetersToImp()
{
	cout << "Enter meters to be converted: ";
	double rawInp = getReal();
	double inches = (rawInp / .0254);
	cout << "Feet: " << int(inches/12) << " Inches: " << (inches - (int(inches/12) * 12));
	string pause = getLine();
}