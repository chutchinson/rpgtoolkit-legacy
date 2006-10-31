/*
 * All contents copyright 2005 Jonathan D. Hughes
 * All rights reserved. You may not remove this notice
 * Read license.txt for licensing details.
 */

/*
 * CAnimation - Animations and threaded animations.
 */

#ifndef _CANIMATION_H_
#define _CANIMATION_H_

/*
 * Includes
 */
#include "animation.h"
#include "paths.h"
#include <mmsystem.h>
#include <vector>
#include <set>
#include <map>

class CCanvas;

/*
 * Standalone animations.
 */
class CAnimation
{
public:
	CAnimation(const STRING file);
	~CAnimation() { freeCanvases(); }

	void addUser(void) { ++m_users; }
	void animate(const int x, const int y);
	LPANIMATION data(void) { return &m_data; }
	void freeCanvases(void)
	{
		std::vector<CCanvas *>::iterator i = m_canvases.begin();
		for (; i != m_canvases.end(); ++i) { delete *i; *i = NULL; }
	}
	CCanvas *getFrame(unsigned int frame);
	void playFrameSound(unsigned int frame) const
	{
		frame %= (m_data.animFrames + 1);
		extern STRING g_projectPath;
		sndPlaySound(
			(g_projectPath + MEDIA_PATH + m_data.animSound[frame]).c_str(), 
			SND_ASYNC | SND_NODEFAULT);
	}
	int removeUser(void) { return --m_users; }
	void render(void);
	bool renderFrame(CCanvas *cnv, unsigned int frame);
	void resize(const int width, const int height) 
	{ 
		if (width) m_data.animSizeX = abs(width);
		if (height) m_data.animSizeY = abs(height);
	}
	STRING filename(void) const { return m_data.animFile; }

private:
	CAnimation(CAnimation &rhs);
	CAnimation &operator= (CAnimation &rhs);

	ANIMATION m_data;
	int m_users;

	std::vector<CCanvas *> m_canvases;
};

/*
 * Shared animation container.
 */
typedef std::map<STRING, CAnimation *> SHARED_ANIMATIONS;

class CSharedAnimation
{
public:
	CAnimation *m_pAnm;
	int m_frame;				// Callback counters, init -1 = hack.
	int m_tick;

		
	// Share an animation if it exists or create a new instance.
	static CSharedAnimation *insert(const STRING file);

	// Free a single user of an animation.
	static void free(CSharedAnimation *p)
	{
		std::set<CSharedAnimation *>::iterator i = m_anms.find(p);
		if (i != m_anms.end()) delete p;
	}

	// Free all shared animations.
	static void freeAll(void);

	// Cast a pointer.
	static CSharedAnimation *cast(const int num)
	{
		CSharedAnimation *p = (CSharedAnimation *)num;
		std::set<CSharedAnimation *>::iterator i = m_anms.find(p);
		return (i != m_anms.end() ? p : NULL);
	}

	// Clear all shared animation canvases.
	static void freeAllCanvases(void)
	{
		SHARED_ANIMATIONS::iterator i = m_shared.begin();
		for (; i != m_shared.end(); ++i) i->second->freeCanvases(); 
	}

protected:
	CSharedAnimation(const STRING file);
	~CSharedAnimation();
	CSharedAnimation(CSharedAnimation &rhs);
	CSharedAnimation &operator= (CSharedAnimation &rhs);

	// Single, shared instances of CAnimations.
	static SHARED_ANIMATIONS m_shared;
	// Set of individual users of all CAnimations with frame counters (for Callbacks).
	static std::set<CSharedAnimation *> m_anms;
};

/*
 * Multitasking animation.
 */
class CThreadAnimation: private CSharedAnimation
{
public:
	CThreadAnimation(const STRING file, const int x, const int y, const bool bPersist); 
	~CThreadAnimation() { }

	static CThreadAnimation *create(const STRING file, const int x, const int y, const int width, const int height, const bool bPersist);
	static bool running(const STRING file, const int x, const int y);
	static void renderAll(CCanvas *cnv);
	static void destroy(CThreadAnimation *p);
	static void destroyAll(void)
	{
		std::set<CThreadAnimation *>::iterator i = m_threads.begin();
		for(; i != m_threads.end(); ++i) delete(*i);
	}

private:
	CThreadAnimation(CThreadAnimation &rhs);
	CThreadAnimation &operator= (CThreadAnimation &rhs);
	bool renderFrame(CCanvas *cnv);

	const int m_x, m_y;
	const bool m_persist;
	DWORD m_timer;

	static std::set<CThreadAnimation *> m_threads;
};

#endif