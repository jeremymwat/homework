/* Created by Jeremy
*
*
*
*/


#include <iostream>
#include "simpio.h"
#include <string>
using namespace std;

void tempConvert()
{
	cout << "Enter temp in Celsius ";
	double celsius = getReal();
	double farenh = ( 9 / 5.0) * celsius + 32;
	cout << "Temp: " << farenh;
	string pause = getLine();

}