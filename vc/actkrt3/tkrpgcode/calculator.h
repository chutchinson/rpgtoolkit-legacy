//////////////////////////////////////////////////////////////////////////
//All code copyright 2004, Colin James Fitzpatrick (KSNiloc)
//Underlying method created, and copyrighted, by Peter J. Fenner (Asimir)
//All rights reserved. YOU MAY NOT REMOVE THIS NOTICE.
//Read LICENSE.txt for licensing info
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Calculator for RPGCode expressions
//////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
// Inclusions
//////////////////////////////////////////////////////////////////////////
#include "inlineString.h"	//For string manipulation

//////////////////////////////////////////////////////////////////////////
// Defintions
//////////////////////////////////////////////////////////////////////////
#define TAB "	"			//A tab

//////////////////////////////////////////////////////////////////////////
// Definition of the calculator class
//////////////////////////////////////////////////////////////////////////
class calculator
{

	public:												//Public
		long double evaluate(char* equation);			//  Evaluate an equation

	private:												//Members
		inlineString eatSpaces(inlineString theString);	//	Eat spaces from a string

};

//////////////////////////////////////////////////////////////////////////
// Exports
//////////////////////////////////////////////////////////////////////////
long double APIENTRY RPGCEvaluate(char* equation);

//////////////////////////////////////////////////////////////////////////
// Evaluate the equation passed in
//////////////////////////////////////////////////////////////////////////
long double calculator::evaluate(char* equation)
{

	//Create a string from the pointer to a character array
	inlineString text;
	text = equation;

	//Eat spaces (and tabs) from the string
	text = eatSpaces(text);

	return 0;

}

//////////////////////////////////////////////////////////////////////////
// Eat spaces from a string
//////////////////////////////////////////////////////////////////////////
inlineString eatSpaces(inlineString theString)
{

	//Create a string to return
	inlineString toRet;

	//Create a string to hold a character
	inlineString chr;

	//Loop over each character in the string
	for(int chrIdx = 1; chrIdx <= theString.len(); chrIdx++)
	{

		//Grab this character
		chr = theString.mid(chrIdx, 1);

		//Check if it's a tab or space
		if (!(chr.contains(" ") | chr.contains(TAB)))
		{
			//If it's not, then add it to the return string
			toRet = toRet & chr;
		}

	}

	//Return the result
	return toRet;

}

//////////////////////////////////////////////////////////////////////////
// Evaluate math
//////////////////////////////////////////////////////////////////////////
long double APIENTRY RPGCEvaluate(char* equation)
{
	calculator calc;
	return calc.evaluate(equation);
}
