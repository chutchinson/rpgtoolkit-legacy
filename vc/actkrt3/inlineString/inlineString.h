///////////////////////////////////////////////////////////////////////////
//All contents copyright 2004, Colin James Fitzpatrick (KSNiloc)
//All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
//Read LICENSE.txt for licensing info
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// String class (fast!)
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// Prevent multiple inclusions of this class
///////////////////////////////////////////////////////////////////////////
#ifndef STRING_CLASS
#define STRING_CLASS

///////////////////////////////////////////////////////////////////////////
// Definition of the inlineString class
///////////////////////////////////////////////////////////////////////////
class inlineString
{

	private:

		//The main contents of the inlineString is stored in
		//in array of characters
		char contents[4048];

	public:

		//Returns values
		char* value();

		//Manipulate the inlineString
		int len();
		inlineString mid(int start, int length);
		int size();
		void setBinary(unsigned char text, int pos);
		char getBinary(int pos);		
		bool contains(char* text);
		void newMem(char* theNewMem);

		//Construction
		inlineString();
		inlineString(char* defaultVal);

		//Operator overloading
		inlineString operator + (inlineString &toAdd);
		inlineString operator + (char* toAdd);
		inlineString operator + (char toAdd);
		operator = (char* text);
		operator = (char text);

};

///////////////////////////////////////////////////////////////////////////
// End of the header file
///////////////////////////////////////////////////////////////////////////
#endif