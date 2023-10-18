#charset "us-ascii"
//
// scene.t
//
//	A TADS3 module for implementing scenes.  Built on top of
//	the ruleEngine module.
//
//
// BASIC USAGE
//
//	First, the game must declare exactly one SceneController instance:
//
//		// Declare the scene controller instance
//		myController: SceneController;
//
//	The object name doesn't matter, and in general you don't need to
//	modify the controller itself to implement scenes.
//
//	Declare a basic scene using:
//
//		// A useless scene that runs continuously.
//		myScene: Scene
//			// Set the scene to be active by default.
//			active = true
//
//			// This method will be called every turn the
//			// scene is active.
//			sceneAction() {
//				"<.p>This is the scene, doing nothing. ";
//			}
//		;
//
//	This scene will run every turn, until something manually calls
//	myScene.setActive(nil) to turn it off.
//
//	Instead of manually enabling and disabling the scene, you can
//	have a scene trigged by specific conditions:
//
//		// A useless scene that runs whenever >TAKE is used.
//		myScene: Scene
//			sceneAction() {
//				"<.p>This is the scene, noticing that you
//				used TAKE. ";
//			}
//		;
//		+Trigger
//			action = TakeAction
//		;
//
//	In this case the scene is reacting to the action.  If you want
//	to PREVENT the action, you can use:
//
//		// This scene will prevent the >TAKE action.
//		myScene: Scene
//			sceneBeforeAction() {
//				"<.p>You can't take anything. ";
//				exit;
//			}
//		;
//		+Trigger
//			action = TakeAction
//		;
//
//
// The demo games in the ./demo directory contain more examples of how
// to use scenes.
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

	rulebookClass = SceneRulebook	// base class for our rulebooks

	_revertFlag = nil	// make ourselves inactive at end of turn

	// Getter and setter for active.  Active means "run this turn".
	isActive() { return(active == true); }
	setActive(v) { active = ((v == true) ? true : nil); }

	// Getter and setter for available.  Available means "can become
	// active this turn".
	isAvailable() { return(available && !isActive() && uniqueCheck()); }
	setAvailable(v?) { available = ((v == true) ? true : nil); }

	// Returns true if we're not unique or if we are but we haven't run yet.
	uniqueCheck() { return((unique == nil) || (runCount < 1)); }

	// Increment the run counter.
	addRunCount() { runCount += 1; }

	// Called during preinit.
	initializeRuleUser() {
		inherited();
		initializeScene();
	}

	initializeScene() {}

	// Normally called by SceneRulebook.callback() when all the rules
	// in a rulebook match.
	tryRuleMatch() {
		// If we're already active, nothing to do.
		if(isActive() == true)
			return;

		// If we can't become active this turn, nothing to do.
		if(isAvailable() != true)
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
		if(isActive() != true)
			return;

		sceneAction();
		addRunCount();
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

	rulebookMatchAction(id) {
		tryRuleMatch();
	}
;
