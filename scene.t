#charset "us-ascii"
//
// scene.t
//
//	A TADS3 module for implementing scenes.
//
//
// BASIC USAGE
//
//	A scene's action methods are called on every turn the scene is
//	active.  For simple scenes, this is when their "active" property
//	is true.
//
//	The base action method is sceneAction(), which will be called by
//	a daemon owned by the sceneController singleton.  The call happens
//	after the action for the turn is resolved.
//
//		// Declare a uselessly-minimal scene.
//		myScene: Scene
//			active = true
//			sceneAction() {
//				"<.p>This is the scene, doing nothing. ";
//			}
//		;
//
//	This will display "This is the scene, doing nothing. " after the turn's
//	action reports, and it will do exactly the same thing every turn.
//
//	In addition to sceneAction(), the following methods are called
//	every turn:
//
//		sceneBeforeAction()
//			Called during the turn's beforeAction() window.
//
//		sceneAfterAction()
//			Called during the turn's afterAction() window.
//
//
//	Simple scenes like the above can only be turned on and off by hand:
//
//		// Disable the scene.
//		myScene.setActive(nil);
//
//		// Enable the scene.
//		myScene.setActive(true);
//
//	In addition, there are a couple Scene subclasses that handled
//	running scenes automatically:
//
//		// A scene that will automatically start when
//		// someObject.someProperty == 'foo' and stop when
//		// someObject.someProperty == 'bar'.
//		myScene: SceneDaemon
//			startCheck() {
//				return(someObject.someProperty == 'foo');
//			}
//			stopCheck() {
//				return(someObject.someProperty == 'bar');
//			}
//			start() {
//				"<.p>This is displayed when the scene starts. ";
//			}
//			stop(v?) {
//				"<.p>This is displayed when the scene ends. ";
//			}
//			sceneAction() {
//				"<.p>This is the scene action. ";
//			}
//		;
//
//	In addition to automatically stopping when the condition(s) defined
//	in stopCheck() are true, you can manually stop the scene:
//
//		// Manually stop the scene.  The argument is saved as
//		// myScene.stopState
//		myScene.stop(someArbitraryStringOrObject);
//
//
//	Another way to handle automatically starting a scene is the
//	SceneTrigger class:
//
//		// A scene that runs whenever the player reads the sign.
//		myScene: SceneTrigger
//			triggerObject = sign
//			triggerAction = ReadAction
//			sceneAction() {
//				"<.p>This is triggered by reading the sign. ";
//			}
//		;
//
//	Since all scenes get a sceneBeforeAction() and sceneAfterAction(), this
//	can be used to pre-empt/block actions.  Two 
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

class Scene: Syslog
	syslogID = 'Scene'

	active = nil		// are we active this turn
	available = true	// can we become active this turn

	unique = nil		// can we run more than once
	runCount = 0		// how many times have we run

	ruleList = nil		// list of our rules

	// Flag that indicates a) all our rules matched this turn (making
	// us active), but b) we weren't active otherwise.
	_ruleRevertFlag = nil

	_senseActions = static [ ExamineAction, LookAction, SmellAction,
		ListenToAction, TasteAction, FeelAction, SenseImplicitAction ]

	_travelActions = static [ TravelAction, TravelViaAction ]

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

	// Remove this scene from notifications.
	removeScene() { beforeAfterController.removeScene(self); }

	// Called during preinit.
	initializeScene() {}

	// Add a rule to this scene.
	addRule(obj) {
		// Make sure the arg is a rule.
		if((obj == nil) || !obj.ofKind(SceneRule))
			return(nil);

		// Create a vector to hold the list if there isn't already one.
		if(ruleList == nil)
			ruleList = new Vector();

		// Make sure we're not adding a duplicate.
		if(ruleList.indexOf(obj) != nil)
			return(nil);

		// Add the rule.
		ruleList.append(obj);

		// Report success.
		return(true);
	}

	// Remove a rule from the rule list.
	removeRule(obj) {
		if(ruleList.indexOf(obj) == nil)
			return(nil);
		ruleList.removeElement(obj);
		return(true);
	}

	// Returns boolean true iff we have rules and they all matched this
	// turn.
	checkRules() {
		local i;

		if(ruleList == nil)
			return(nil);

		for(i = 1; i <= ruleList.length; i++) {
			if(ruleList[i].firedThisTurn() != true)
				return(nil);
		}

		return(true);
	}

	// See if we should become active due to rule matching.
	tryRuleMatch() {
		// If we're already active, nothing to do.
		if(isActive() == true)
			return;

		// If we can't become active this turn, nothing to do.
		if(isAvailable() != true)
			return;

		// If we don't match all rules this turn, nothing to do.
		if(checkRules() != true)
			return;

		// Remember to revert at the end of the turn.
		_ruleRevertFlag = true;

		// Set ourselves active.
		setActive(true);
	}

	// Revert to an inactive state if we were only active because of
	// rule matching.
	tryRuleRevert() {
		if(_ruleRevertFlag != true)
			return;

		_ruleRevertFlag = nil;

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
