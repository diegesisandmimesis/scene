#charset "us-ascii"
//
// scene.t
//
//	A TADS3 module for implementing scenes.
//
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

// Module ID for the library
sceneModuleID: ModuleID {
        name = 'Scene Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class Scene: RuleUser
	syslogID = 'Scene'

	active = nil		// are we active this turn
	available = true	// can we become active this turn

	unique = nil		// can we run more than once
	runCount = 0		// how many times have we run

	_revertFlag = nil

	// Getter and setter for active.  Done this way because subclasses
	// might want to implement fancier checks (checking more than
	// one property, for instance).
	isActive() { return(active == true); }
	setActive(v) { active = ((v == true) ? true : nil); }

	// Can we become active?
	isAvailable() { return(available && !isActive() && uniqueCheck()); }
	setAvailable(v?) { available = ((v == true) ? true : nil); }

	// Returns true if we're not unique or if we are but we haven't run yet.
	uniqueCheck() { return((unique == nil) || (runCount < 1)); }

	// Increment the run counter.
	addRunCount() { runCount += 1; }

	// Called during preinit.
	initializeScene() {}

	// See if we should become active due to rule matching.
	tryRuleMatch() {
		// If we're already active, nothing to do.
		if(isActive() == true)
			return;

		// If we can't become active this turn, nothing to do.
		if(isAvailable() != true)
			return;

		// If we don't match all rules this turn, nothing to do.
		if(checkRulebooks() != true)
			return;

		// Remember to revert at the end of the turn.
		_revertFlag = true;

		// Set ourselves active.
		setActive(true);
	}

	// Revert to an inactive state if we were only active because of
	// rule matching.
	tryRuleRevert() {
		if(_revertFlag != true)
			return;

		_revertFlag = nil;

		setActive(nil);
	}

	// Wrappers to the action methods that check to see if we're active
	// before running.
	// These are what are called by the scene controller.
	trySceneAction() {
		if(isActive() == true) {
			sceneAction();
			addRunCount();
		}
	}
	trySceneBeforeAction() { if(isActive() == true) sceneBeforeAction(); }
	trySceneAfterAction() { if(isActive() == true) sceneAfterAction(); }

	// Stub methods for the "stuff" the scene needs to do.
	// sceneBeforeAction() gets called during the turn's beforeAction()
	// sceneAfterAction() gets called during the turn's afterAction()
	// sceneAction() gets called when daemons update (after the action
	// for the turn is resolved)
	sceneBeforeAction() {}
	sceneAfterAction() {}
	sceneAction() {}
;
