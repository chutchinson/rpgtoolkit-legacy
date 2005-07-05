/*
 * All contents copyright 2005, Colin James Fitzpatrick.
 * All rights reserved. You may not remove this notice.
 * Read license.txt for licensing details.
 */

#include "stdafx.h"
#include "../trans3.h"
#include "Callbacks.h"
#include "../rpgcode/CProgram/CProgram.h"
#include "../common/CAllocationHeap.h"
#include "../common/paths.h"
#include "../common/CFile.h"
#include "../common/animation.h"
#include "../common/board.h"
#include "../common/enemy.h"
#include "../common/background.h"
#include "../movement/CPlayer/CPlayer.h"
#include "../images/FreeImage.h"
#include "../fight/fight.h"
#include "../../tkCommon/tkDirectX/platform.h"
#include "../../tkCommon/tkCanvas/GDICanvas.h"
#include <map>

extern CAllocationHeap<CGDICanvas> g_canvases;
extern CDirectDraw *g_pDirectDraw;
extern std::vector<CPlayer *> g_players;
static CAllocationHeap<ANIMATION> g_animations;
static HDC g_hScreenDc = NULL;

std::map<unsigned int, PLUGIN_ENEMY> g_enemies;

STDMETHODIMP CCallbacks::CBRpgCode(BSTR rpgcodeCommand)
{
	CProgram().runLine(getString(rpgcodeCommand));
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetString(BSTR varname, BSTR *pRet)
{
	BSTR bstr = getString(CProgram::getGlobal(getString(varname)).getLit());
	SysReAllocString(pRet, bstr);
	SysFreeString(bstr);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetNumerical(BSTR varname, double *pRet)
{
	*pRet = CProgram::getGlobal(getString(varname)).getNum();
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetString(BSTR varname, BSTR newValue)
{
	CProgram::setGlobal(getString(varname), getString(newValue));
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetNumerical(BSTR varname, double newValue)
{
	CProgram::setGlobal(getString(varname), newValue);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetScreenDC(int *pRet)
{
	extern HWND g_hHostWnd;
	*pRet = int(g_hScreenDc = GetDC(g_hHostWnd));
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetScratch1DC(int *pRet)
{
	*pRet = NULL; // Obsolete.
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetScratch2DC(int *pRet)
{
	*pRet = NULL; // Obsolete.
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetMwinDC(int *pRet)
{
	*pRet = NULL; // Obsolete.
	return S_OK;
}

STDMETHODIMP CCallbacks::CBPopupMwin(int *pRet)
{
	extern bool g_bShowMessageWindow;
	g_bShowMessageWindow = true;
	*pRet = TRUE;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBHideMwin(int *pRet)
{
	extern bool g_bShowMessageWindow;
	g_bShowMessageWindow = false;
	*pRet = TRUE;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBLoadEnemy(BSTR file, int eneSlot)
{
	extern std::string g_projectPath;
	const std::string strFile = getString(file);
	g_enemies[eneSlot].enemy.open(g_projectPath + ENE_PATH + strFile);
	g_enemies[eneSlot].fileName = strFile;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyNum(int infoCode, int eneSlot, int *pRet)
{
	if (!g_enemies.count(eneSlot))
	{
		*pRet = 0;
		return S_OK;
	}
	ENEMY &ene = g_enemies[eneSlot].enemy;
	switch (infoCode)
	{
		case ENE_HP:
			*pRet = ene.iHp;
			break;
		case ENE_MAXHP:
			*pRet = ene.iMaxHp;
			break;
		case ENE_SMP:
			*pRet = ene.iSmp;
			break;
		case ENE_MAXSMP:
			*pRet = ene.iMaxSmp;
			break;
		case ENE_FP:
			*pRet = ene.fp;
			break;
		case ENE_DP:
			*pRet = ene.dp;
			break;
		case ENE_RUNYN:
			*pRet = ene.run;
			break;
		case ENE_SNEAKCHANCES:
			*pRet = ene.takeCrit;
			break;
		case ENE_SNEAKUPCHANCES:
			*pRet = ene.giveCrit;
			break;
		case ENE_SIZEX:
		case ENE_SIZEY:
			// Obsolete.
			*pRet = 0;
			break;
		case ENE_AI:
			*pRet = ene.ai;
			break;
		case ENE_EXP:
			*pRet = ene.exp;
			break;
		case ENE_GP:
			*pRet = ene.gp;
			break;
		default:
			*pRet = 0;
			break;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyString(int infoCode, int eneSlot, BSTR *pRet)
{
	if (!g_enemies.count(eneSlot))
	{
		SysReAllocString(pRet, L"");
		return S_OK;
	}
	ENEMY &ene = g_enemies[eneSlot].enemy;
	BSTR bstr = NULL;
	switch (infoCode)
	{
		case ENE_FILENAME:
			bstr = getString(g_enemies[eneSlot].fileName);
			SysReAllocString(pRet, bstr);
			break;
		case ENE_NAME:
			bstr = getString(ene.strName);
			SysReAllocString(pRet, bstr);
			break;
		case ENE_RPGCODEPROGRAM:
			bstr = getString(ene.prg);
			SysReAllocString(pRet, bstr);
			break;
		case ENE_DEFEATPRG:
			bstr = getString(ene.winPrg);
			SysReAllocString(pRet, bstr);
			break;
		case ENE_RUNPRG:
			bstr = getString(ene.runPrg);
			SysReAllocString(pRet, bstr);
			break;
		default:
			SysReAllocString(pRet, L"");
			break;
	}
	if (bstr)
	{
		SysFreeString(bstr);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetEnemyNum(int infoCode, int newValue, int eneSlot)
{
	if (!g_enemies.count(eneSlot)) return S_OK;
	ENEMY &ene = g_enemies[eneSlot].enemy;
	switch (infoCode)
	{
		case ENE_HP:
			ene.iHp = newValue;
			break;
		case ENE_MAXHP:
			ene.iMaxHp = newValue;
			break;
		case ENE_SMP:
			ene.iSmp = newValue;
			break;
		case ENE_MAXSMP:
			ene.iMaxSmp = newValue;
			break;
		case ENE_FP:
			ene.fp = newValue;
			break;
		case ENE_DP:
			ene.dp = newValue;
			break;
		case ENE_RUNYN:
			ene.run = newValue;
			break;
		case ENE_SNEAKCHANCES:
			ene.takeCrit = newValue;
			break;
		case ENE_SNEAKUPCHANCES:
			ene.giveCrit = newValue;
			break;
		case ENE_SIZEX:
		case ENE_SIZEY:
			// Obsolete.
			break;
		case ENE_AI:
			ene.ai = newValue;
			break;
		case ENE_EXP:
			ene.exp = newValue;
			break;
		case ENE_GP:
			ene.gp = newValue;
			break;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetEnemyString(int infoCode, BSTR newValue, int eneSlot)
{
	if (!g_enemies.count(eneSlot)) return S_OK;
	ENEMY &ene = g_enemies[eneSlot].enemy;
	switch (infoCode)
	{
		case ENE_FILENAME:
			g_enemies[eneSlot].fileName = getString(newValue);
			break;
		case ENE_NAME:
			ene.strName = getString(newValue);
			break;
		case ENE_RPGCODEPROGRAM:
			ene.prg = getString(newValue);
			break;
		case ENE_DEFEATPRG:
			ene.winPrg = getString(newValue);
			break;
		case ENE_RUNPRG:
			ene.runPrg = getString(newValue);
			break;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerNum(int infoCode, int arrayPos, int playerSlot, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerString(int infoCode, int arrayPos, int playerSlot, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetPlayerNum(int infoCode, int arrayPos, int newVal, int playerSlot)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetPlayerString(int infoCode, int arrayPos, BSTR newVal, int playerSlot)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetGeneralString(int infoCode, int arrayPos, int playerSlot, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetGeneralNum(int infoCode, int arrayPos, int playerSlot, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetGeneralString(int infoCode, int arrayPos, int playerSlot, BSTR newVal)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetGeneralNum(int infoCode, int arrayPos, int playerSlot, int newVal)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetCommandName(BSTR rpgcodeCommand, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetBrackets(BSTR rpgcodeCommand, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCountBracketElements(BSTR rpgcodeCommand, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetBracketElement(BSTR rpgcodeCommand, int elemNum, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetStringElementValue(BSTR rpgcodeCommand, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetNumElementValue(BSTR rpgcodeCommand, double *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetElementType(BSTR data, int *pRet)
{
	const CVariant::DATA_TYPE dt = CProgram::getCurrentProgram()->constructVariant(getString(data)).getType();
	if (dt == CVariant::DT_NUM) *pRet = PLUG_DT_NUM;
	else if (dt == CVariant::DT_LIT) *pRet = PLUG_DT_LIT;
	else *pRet = PLUG_DT_VOID; // No object support for plugins.
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDebugMessage(BSTR message)
{
	CProgram::debugger(getString(message));
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPathString(int infoCode, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBLoadSpecialMove(BSTR file)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetSpecialMoveString(int infoCode, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetSpecialMoveNum(int infoCode, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBLoadItem(BSTR file, int itmSlot)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetItemString(int infoCode, int arrayPos, int itmSlot, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetItemNum(int infoCode, int arrayPos, int itmSlot, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetBoardNum(int infoCode, int arrayPos1, int arrayPos2, int arrayPos3, int *pRet)
{
	extern BOARD g_activeBoard;
	switch (infoCode)
	{
		case BRD_SIZEX:
			*pRet = g_activeBoard.bSizeX;
			break;
		case BRD_SIZEY:
			*pRet = g_activeBoard.bSizeY;
			break;
		case BRD_AMBIENTRED:
			*pRet = g_activeBoard.ambientRed[arrayPos1][arrayPos2][arrayPos3];
			break;
		case BRD_AMBIENTGREEN:
			*pRet = g_activeBoard.ambientGreen[arrayPos1][arrayPos2][arrayPos3];
			break;
		case BRD_AMBIENTBLUE:
			*pRet = g_activeBoard.ambientBlue[arrayPos1][arrayPos2][arrayPos3];
			break;
		case BRD_TILETYPE:
			*pRet = g_activeBoard.tiletype[arrayPos1][arrayPos2][arrayPos3];
			break;
		case BRD_BACKCOLOR:
			*pRet = g_activeBoard.brdColor;
			break;
		case BRD_BORDERCOLOR:
			*pRet = g_activeBoard.borderColor;
			break;
		case BRD_SKILL:
			*pRet = g_activeBoard.boardSkill;
			break;
		case BRD_FIGHTINGYN:
			*pRet = g_activeBoard.fightingYN;
			break;
		case BRD_PRG_X:
			// [...]
			break;
	}
	// THIS IS NOT FINISHED!
	//////////////////////////////////////////////
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetBoardString(int infoCode, int arrayPos1, int arrayPos2, int arrayPos3, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetBoardNum(int infoCode, int arrayPos1, int arrayPos2, int arrayPos3, int nValue)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetBoardString(int infoCode, int arrayPos1, int arrayPos2, int arrayPos3, BSTR newVal)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetHwnd(int *pRet)
{
	extern HWND g_hHostWnd;
	*pRet = (int)g_hHostWnd;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBRefreshScreen(int *pRet)
{
	*pRet = g_pDirectDraw->Refresh();
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCreateCanvas(int width, int height, int *pRet)
{
	CGDICanvas *p = g_canvases.allocate();
	p->CreateBlank(NULL, width, height, TRUE);
	*pRet = (int)p;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDestroyCanvas(int canvasID, int *pRet)
{
	*pRet = (int)g_canvases.free((CGDICanvas *)canvasID);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawCanvas(int canvasID, int x, int y, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = g_pDirectDraw->DrawCanvas(p, x, y, SRCCOPY);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawCanvasPartial(int canvasID, int xDest, int yDest, int xsrc, int ysrc, int width, int height, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = g_pDirectDraw->DrawCanvasPartial(p, xDest, yDest, xsrc, ysrc, width, height, SRCCOPY);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawCanvasTransparent(int canvasID, int x, int y, int crTransparentColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = g_pDirectDraw->DrawCanvasTransparent(p, x, y, crTransparentColor);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawCanvasTransparentPartial(int canvasID, int xDest, int yDest, int xsrc, int ysrc, int width, int height, int crTransparentColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = g_pDirectDraw->DrawCanvasTransparentPartial(p, xDest, yDest, xsrc, ysrc, width, height, crTransparentColor);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawCanvasTranslucent(int canvasID, int x, int y, double dIntensity, int crUnaffectedColor, int crTransparentColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = g_pDirectDraw->DrawCanvasTranslucent(p, x, y, dIntensity, crUnaffectedColor, crTransparentColor);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasLoadImage(int canvasID, BSTR filename, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		extern std::string g_projectPath;
		drawImage(g_projectPath + BMP_PATH + getString(filename), p, 0, 0, -1, -1);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasLoadSizedImage(int canvasID, BSTR filename, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		extern std::string g_projectPath;
		drawImage(g_projectPath + BMP_PATH + getString(filename), p, 0, 0, p->GetWidth(), p->GetHeight());
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasFill(int canvasID, int crColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (*pRet = (p != NULL))
	{
		p->ClearScreen(crColor);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasResize(int canvasID, int width, int height, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (*pRet = (p != NULL))
	{
		p->Resize(NULL, width, height);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvas2CanvasBlt(int cnvSrc, int cnvDest, int xDest, int yDest, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnvSrc);
	if (p)
	{
		CGDICanvas *pDest = g_canvases.cast(cnvDest);
		if (pDest)
		{	
			*pRet = p->Blt(pDest, xDest, yDest, SRCCOPY);
		}
		else
		{
			*pRet = FALSE;
		}
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvas2CanvasBltPartial(int cnvSrc, int cnvDest, int xDest, int yDest, int xsrc, int ysrc, int width, int height, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnvSrc);
	if (p)
	{
		CGDICanvas *pDest = g_canvases.cast(cnvDest);
		if (pDest)
		{	
			*pRet = p->BltPart(pDest, xDest, yDest, xsrc, ysrc, width, height, SRCCOPY);
		}
		else
		{
			*pRet = FALSE;
		}
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvas2CanvasBltTransparent(int cnvSrc, int cnvDest, int xDest, int yDest, int crTransparentColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnvSrc);
	if (p)
	{
		CGDICanvas *pDest = g_canvases.cast(cnvDest);
		if (pDest)
		{	
			*pRet = p->BltTransparent(pDest, xDest, yDest, crTransparentColor);
		}
		else
		{
			*pRet = FALSE;
		}
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvas2CanvasBltTransparentPartial(int cnvSrc, int cnvDest, int xDest, int yDest, int xsrc, int ysrc, int width, int height, int crTransparentColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnvSrc);
	if (p)
	{
		CGDICanvas *pDest = g_canvases.cast(cnvDest);
		if (pDest)
		{	
			*pRet = p->BltTransparentPart(pDest, xDest, yDest, xsrc, ysrc, width, height, crTransparentColor);
		}
		else
		{
			*pRet = FALSE;
		}
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvas2CanvasBltTranslucent(int cnvSrc, int cnvDest, int destX, int destY, double dIntensity, int crUnaffectedColor, int crTransparentColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnvSrc);
	if (p)
	{
		CGDICanvas *pDest = g_canvases.cast(cnvDest);
		if (pDest)
		{	
			*pRet = p->BltTranslucent(pDest, destX, destY, dIntensity, crUnaffectedColor, crTransparentColor);
		}
		else
		{
			*pRet = FALSE;
		}
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasGetScreen(int cnvDest, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnvDest);
	if (p)
	{
		*pRet = g_pDirectDraw->CopyScreenToCanvas(p);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBLoadString(int id, BSTR defaultString, BSTR *pRet)
{
	// Translations?
	SysReAllocString(pRet, defaultString); // Just return default.
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawText(int canvasID, BSTR text, BSTR font, int size, double x, double y, int crColor, int isBold, int isItalics, int isUnderline, int isCentred, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = p->DrawText(x, y, getString(text), getString(font), size, crColor, isBold, isItalics, isUnderline, isCentred);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasPopup(int canvasID, int x, int y, int stepSize, int popupType, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasWidth(int canvasID, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = p->GetWidth();
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasHeight(int canvasID, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = p->GetHeight();
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawLine(int canvasID, int x1, int y1, int x2, int y2, int crColor, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		*pRet = p->DrawLine(x1, y1, x2, y2, crColor);
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawRect(int canvasID, int x1, int y1, int x2, int y2, int crColor, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasFillRect(int canvasID, int x1, int y1, int x2, int y2, int crColor, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawHand(int canvasID, int pointx, int pointy, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawHand(int pointx, int pointy, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCheckKey(BSTR keyPressed, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBPlaySound(BSTR soundFile, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBMessageWindow(BSTR text, int textColor, int bgColor, BSTR bgPic, int mbtype, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFileDialog(BSTR initialPath, BSTR fileFilter, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDetermineSpecialMoves(BSTR playerHandle, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetSpecialMoveListEntry(int idx, BSTR *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBRunProgram(BSTR prgFile)
{
	CProgram(getString(prgFile)).run();
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetTarget(int targetIdx, int ttype)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetSource(int sourceIdx, int sType)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerHP(int playerIdx, double *pRet)
{
	if (g_players.size() > playerIdx)
	{
		*pRet = g_players[playerIdx]->health();
	}
	else
	{
		*pRet = 0.0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerMaxHP(int playerIdx, double *pRet)
{
	if (g_players.size() > playerIdx)
	{
		*pRet = g_players[playerIdx]->maxHealth();
	}
	else
	{
		*pRet = 0.0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerSMP(int playerIdx, double *pRet)
{
	if (g_players.size() > playerIdx)
	{
		*pRet = g_players[playerIdx]->smp();
	}
	else
	{
		*pRet = 0.0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerMaxSMP(int playerIdx, double *pRet)
{
	if (g_players.size() > playerIdx)
	{
		*pRet = g_players[playerIdx]->maxSmp();
	}
	else
	{
		*pRet = 0.0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerFP(int playerIdx, double *pRet)
{
	if (g_players.size() > playerIdx)
	{
		*pRet = g_players[playerIdx]->fight();
	}
	else
	{
		*pRet = 0.0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerDP(int playerIdx, double *pRet)
{
	if (g_players.size() > playerIdx)
	{
		*pRet = g_players[playerIdx]->defence();
	}
	else
	{
		*pRet = 0.0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPlayerName(int playerIdx, BSTR *pRet)
{
	if (g_players.size() > playerIdx)
	{
		BSTR bstr = getString(g_players[playerIdx]->name());
		SysReAllocString(pRet, bstr);
		SysFreeString(bstr);
	}
	else
	{
		SysReAllocString(pRet, L"");
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAddPlayerHP(int amount, int playerIdx)
{
	if (g_players.size() > playerIdx)
	{
		g_players[playerIdx]->health(g_players[playerIdx]->health() + amount);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAddPlayerSMP(int amount, int playerIdx)
{
	if (g_players.size() > playerIdx)
	{
		g_players[playerIdx]->smp(g_players[playerIdx]->smp() + amount);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetPlayerHP(int amount, int playerIdx)
{
	if (g_players.size() > playerIdx)
	{
		g_players[playerIdx]->health(amount);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetPlayerSMP(int amount, int playerIdx)
{
	if (g_players.size() > playerIdx)
	{
		g_players[playerIdx]->smp(amount);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetPlayerFP(int amount, int playerIdx)
{
	if (g_players.size() > playerIdx)
	{
		g_players[playerIdx]->fight(amount);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetPlayerDP(int amount, int playerIdx)
{
	if (g_players.size() > playerIdx)
	{
		g_players[playerIdx]->defence(amount);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyHP(int eneIdx, int *pRet)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	*pRet = g_enemies[eneIdx].enemy.iHp;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyMaxHP(int eneIdx, int *pRet)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	*pRet = g_enemies[eneIdx].enemy.iMaxHp;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemySMP(int eneIdx, int *pRet)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	*pRet = g_enemies[eneIdx].enemy.iSmp;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyMaxSMP(int eneIdx, int *pRet)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	*pRet = g_enemies[eneIdx].enemy.iMaxSmp;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyFP(int eneIdx, int *pRet)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	*pRet = g_enemies[eneIdx].enemy.fp;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetEnemyDP(int eneIdx, int *pRet)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	*pRet = g_enemies[eneIdx].enemy.dp;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAddEnemyHP(int amount, int eneIdx)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	g_enemies[eneIdx].enemy.iHp += amount;
	if (g_enemies[eneIdx].enemy.iHp > g_enemies[eneIdx].enemy.iMaxHp)
	{
		g_enemies[eneIdx].enemy.iHp = g_enemies[eneIdx].enemy.iMaxHp;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAddEnemySMP(int amount, int eneIdx)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	g_enemies[eneIdx].enemy.iSmp += amount;
	if (g_enemies[eneIdx].enemy.iSmp > g_enemies[eneIdx].enemy.iMaxSmp)
	{
		g_enemies[eneIdx].enemy.iSmp = g_enemies[eneIdx].enemy.iMaxSmp;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetEnemyHP(int amount, int eneIdx)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	if (amount < 0) amount = 0;
	else if (amount > g_enemies[eneIdx].enemy.iMaxHp) amount = g_enemies[eneIdx].enemy.iMaxHp;
	g_enemies[eneIdx].enemy.iHp = amount;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBSetEnemySMP(int amount, int eneIdx)
{
	if (!g_enemies.count(eneIdx)) return S_OK;
	if (amount < 0) amount = 0;
	else if (amount > g_enemies[eneIdx].enemy.iSmp) amount = g_enemies[eneIdx].enemy.iMaxSmp;
	g_enemies[eneIdx].enemy.iSmp = amount;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawBackground(int canvasID, BSTR bkgFile, int x, int y, int width, int height)
{
	CGDICanvas *p = g_canvases.cast(canvasID);
	if (p)
	{
		extern std::string g_projectPath;
		BACKGROUND bkg;
		bkg.open(g_projectPath + BKG_PATH + getString(bkgFile));
		drawImage(bkg.image, p, x, y, width, height);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCreateAnimation(BSTR file, int *pRet)
{
	LPANIMATION p = g_animations.allocate();
	p->open(getString(file));
	*pRet = (int)p;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDestroyAnimation(int idx)
{
	g_animations.free((LPANIMATION)idx);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawAnimation(int canvasID, int idx, int x, int y, int forceDraw, int forceTransp)
{
	LPANIMATION p = g_animations.cast(idx);
	if (p)
	{
		CGDICanvas *pCnv = g_canvases.cast(canvasID);
		if (pCnv)
		{
			if ((!(p->timerFrame++ % int(80 * p->animPause))) || (p->currentAnmFrame == -1))
			{
				p->currentAnmFrame++;
				if (p->currentAnmFrame >= p->animFrames) p->currentAnmFrame = 0;
			}
			if (forceTransp)
			{
				pCnv->ClearScreen(TRANSP_COLOR);
			}
			CGDICanvas cnvTemp;
			renderAnimationFrame(&cnvTemp, p->animFile, p->currentAnmFrame, 0, 0);
			cnvTemp.BltTransparent(pCnv, x, y, TRANSP_COLOR);
		}
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasDrawAnimationFrame(int canvasID, int idx, int frame, int x, int y, int forceTranspFill)
{
	LPANIMATION p = g_animations.cast(idx);
	if (p)
	{
		if (frame >= p->animFrames) frame = 0;
		p->currentAnmFrame = frame;
		CGDICanvas *pCnv = g_canvases.cast(canvasID);
		if (pCnv)
		{
			if (forceTranspFill)
			{
				pCnv->ClearScreen(TRANSP_COLOR);
			}
			CGDICanvas cnvTemp;
			renderAnimationFrame(&cnvTemp, p->animFile, frame, 0, 0);
			cnvTemp.BltTransparent(pCnv, x, y, TRANSP_COLOR);
		}
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAnimationCurrentFrame(int idx, int *pRet)
{
	LPANIMATION p = g_animations.cast(idx);
	*pRet = (p ? p->currentAnmFrame : 0);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAnimationMaxFrames(int idx, int *pRet)
{
	LPANIMATION p = g_animations.cast(idx);
	*pRet = (p ? (p->animFrames - 1) : 0);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAnimationSizeX(int idx, int *pRet)
{
	LPANIMATION p = g_animations.cast(idx);
	*pRet = (p ? p->animSizeX : 0);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAnimationSizeY(int idx, int *pRet)
{
	LPANIMATION p = g_animations.cast(idx);
	*pRet = (p ? p->animSizeY : 0);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBAnimationFrameImage(int idx, int frame, BSTR *pRet)
{
	LPANIMATION p = g_animations.cast(idx);
	if (p && (p->animFrames > frame))
	{
		BSTR bstr = getString(p->animFrame[frame]);
		SysReAllocString(pRet, bstr);
		SysFreeString(bstr);
	}
	else
	{
		SysReAllocString(pRet, L"");
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetPartySize(int partyIdx, int *pRet)
{
	extern std::vector<VECTOR_FIGHTER> g_parties;
	if (partyIdx < g_parties.size())
	{
		*pRet = g_parties[partyIdx].size() - 1;
	}
	else
	{
		*pRet = -1;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterHP(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->pFighter->health();
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterMaxHP(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->pFighter->maxHealth();
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterSMP(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->pFighter->smp();
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterMaxSMP(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->pFighter->maxSmp();
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterFP(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->pFighter->fight();
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterDP(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->pFighter->defence();
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterName(int partyIdx, int fighterIdx, BSTR *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		BSTR bstr = getString(p->pFighter->name());
		SysReAllocString(pRet, bstr);
		SysFreeString(bstr);
	}
	else
	{
		SysReAllocString(pRet, L"");
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterAnimation(int partyIdx, int fighterIdx, BSTR animationName, BSTR *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		BSTR bstr = getString(p->pFighter->getStanceAnimation(getString(animationName)));
		SysReAllocString(pRet, bstr);
		SysFreeString(bstr);
	}
	else
	{
		SysReAllocString(pRet, L"");
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBGetFighterChargePercent(int partyIdx, int fighterIdx, int *pRet)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		*pRet = p->charge / p->chargeMax * 100;
	}
	else
	{
		*pRet = 0;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFightTick(void)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDrawTextAbsolute(BSTR text, BSTR font, int size, int x, int y, int crColor, int isBold, int isItalics, int isUnderline, int isCentred, int *pRet)
{
	*pRet = g_pDirectDraw->DrawText(x, y, getString(text), getString(font), size, crColor, isBold, isItalics, isUnderline, isCentred);
	return S_OK;
}

STDMETHODIMP CCallbacks::CBReleaseFighterCharge(int partyIdx, int fighterIdx)
{
	LPFIGHTER p = getFighter(partyIdx, fighterIdx);
	if (p)
	{
		p->charge = 0;
		p->bFrozenCharge = false;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFightDoAttack(int sourcePartyIdx, int sourceFightIdx, int targetPartyIdx, int targetFightIdx, int amount, int toSMP, int *pRet)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFightUseItem(int sourcePartyIdx, int sourceFightIdx, int targetPartyIdx, int targetFightIdx, BSTR itemFile)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFightUseSpecialMove(int sourcePartyIdx, int sourceFightIdx, int targetPartyIdx, int targetFightIdx, BSTR moveFile)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBDoEvents(void)
{
	extern void processEvent(void);
	processEvent();
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFighterAddStatusEffect(int partyIdx, int fightIdx, BSTR statusFile)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFighterRemoveStatusEffect(int partyIdx, int fightIdx, BSTR statusFile)
{
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCheckMusic(void)
{
	// Obsolete. Do nothing.
	return S_OK;
}

STDMETHODIMP CCallbacks::CBReleaseScreenDC(void)
{
	extern HWND g_hHostWnd;
	ReleaseDC(g_hHostWnd, g_hScreenDc);
	g_hScreenDc = NULL;
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasOpenHdc(int cnv, int *pRet)
{
	CGDICanvas *p = g_canvases.cast(cnv);
	if (p)
	{
		*pRet = (int)p->OpenDC();
	}
	else
	{
		*pRet = FALSE;
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBCanvasCloseHdc(int cnv, int hdc)
{
	CGDICanvas *p = g_canvases.cast(cnv);
	if (p)
	{
		p->CloseDC((HDC)hdc);
	}
	return S_OK;
}

STDMETHODIMP CCallbacks::CBFileExists(BSTR strFile, VARIANT_BOOL *pRet)
{
	extern std::string g_projectPath;
	*pRet = (CFile::fileExists(g_projectPath + getString(strFile)) ? VARIANT_TRUE : VARIANT_FALSE);
	return S_OK;
}
