///////////////////////////////////////////////////////////////////////////
//All contents copyright 2004, Colin James Fitzpatrick (KSNiloc)
//All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
//Read LICENSE.txt for licensing info
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// RPGCode Parser
///////////////////////////////////////////////////////////////////////////

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
#define TAB "	"							//the tab key

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
inline void returnVbString(inlineString&);
inline VB_STRING charToVbString(char*);
inline char* vbStringToChar(VB_STRING);
inline int vbStringGetLen(VB_STRING);

//exports
void APIENTRY RPGCInitParser(int);
void APIENTRY RPGCGetMethodName(VB_STRING);
void APIENTRY RPGCParseAfter(VB_STRING, VB_STRING);
void APIENTRY RPGCParseBefore(VB_STRING, VB_STRING);