///////////////////////////////////////////////////////////////////////////
//All contents copyright 2004 Colin James Fitzpatrick (KSNiloc)
//and Sander Knape (Woozy)
//All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
//Read LICENSE.txt for licensing info
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// RPGCode Parser
///////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Protect the header
//////////////////////////////////////////////////////////////////////////
#ifndef RPGCODE_PARSER_H
#define RPGCODE_PARSER_H

//////////////////////////////////////////////////////////////////////////
// Inclusions
//////////////////////////////////////////////////////////////////////////
#define WIN32_LEAN_AND_MEAN					//no MFC
#include <windows.h>						//include windows API
#include "..\inlineString\inlineString.h"	//for strings
#include <wtypes.h>							//for VB strings
#include <oleauto.h>						//for OLE automation

//////////////////////////////////////////////////////////////////////////
// Definitions
//////////////////////////////////////////////////////////////////////////
#define TAB			"\t"					//the tab key
#define QUOTE		"\""					//a quote
#define BACKSLASH	"\\"					//a backslash

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

//all the parsing functions take in VB_STRING, to pass in a VB_STRING
//from VB, use the StrPtr(theString) function
typedef unsigned short* VB_STRING;

//this type is used for calling back into setLastParseString() in
//RPGCodeParser of trans3
typedef void (__stdcall* CBOneParamStr) (VB_STRING);

//////////////////////////////////////////////////////////////////////////
// Prototypes
//////////////////////////////////////////////////////////////////////////

//for vb strings
inline char* initVbString(VB_STRING);
inline void returnVbString(inlineString);
inline VB_STRING charToVbString(char*);
inline char* vbStringToChar(VB_STRING);
inline int vbStringGetLen(VB_STRING);

//private parsing functions
inline int locateBrackets(inlineString);

//exports
void APIENTRY RPGCInitParser(int);
void APIENTRY RPGCGetMethodName(VB_STRING);
void APIENTRY RPGCParseAfter(VB_STRING, VB_STRING);
void APIENTRY RPGCParseBefore(VB_STRING, VB_STRING);
void APIENTRY RPGCGetVarList(VB_STRING, int);
void APIENTRY RPGCParseWithin(VB_STRING, VB_STRING, VB_STRING);
void APIENTRY RPGCGetElement(VB_STRING, int);
void APIENTRY RPGCReplaceOutsideQuotes(VB_STRING, VB_STRING, VB_STRING);
void APIENTRY RPGCGetBrackets(VB_STRING);
void APIENTRY RPGCGetCommandName(VB_STRING);
int APIENTRY RPGCValueNumber(VB_STRING);
int APIENTRY RPGCInStrOutsideQuotes(int, VB_STRING, VB_STRING);

//////////////////////////////////////////////////////////////////////////
// End of the file
//////////////////////////////////////////////////////////////////////////
#endif