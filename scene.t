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

	active = nil

	_senseActions = static [ ExamineAction, LookAction, SmellAction,
		ListenToAction, TasteAction, FeelAction, SenseImplicitAction ]

	_travelActions = static [ TravelAction, TravelViaAction ]

	// Getter and setter for active.  Done this way because subclasses
	// might want to implement fancier checks (checking more than
	// one property, for instance).
	isActive() { return(active == true); }
	setActive(v) { active = ((v == true) ? true : nil); }

	// Can we become active?  By default we just check if we're currently
	// active or not, but subclasses do more elaborate checks.
	isAvailable() { return(!isActive()); }

	// Flag we set before doing a try{} finally{} test on the current
	// action, to prevent recursion.
	_testCurrentActionLock = nil

	// Make sure the argument is an Action.
	// If it's nil, we try gAction.
	_canonicalizeAction(action?) {
		// If no action is specified, use the current turn action.
		if(action == nil)
			action = gAction;

		// Make sure we have a valid action
		if((action == nil) || !action.ofKind(Action))
			return(nil);

		return(action);
	}

	// Make sure the argument is a List.
	_canonicalizeList(l) {
		if(l == nil) return(nil);
		if(l.ofKind(Vector)) return(l.toList());
		if(!l.ofKind(List)) return([ l ]);
		return(l);
	}

	// Check a list for the action.
	_checkListFor(action, lst) {
		if((action == nil) || ((lst = _canonicalizeList(lst)) == nil))
			return(nil);
		return(lst.valWhich({ x: action.ofKind(x) || action == x })
			!= nil);
	}

	isSenseAction(action?) {
		return(_checkListFor(_canonicalizeAction(action),
			_senseActions));
	}

	isTravelAction(action?) {
		return(_checkListFor(_canonicalizeAction(action),
			_travelActions));
	}

	// Should return boolean true if we permit the current action
	// to happen (instead of handling/blocking it ourselves).
	// Does nothing by default, can be overwritten by instances/subclasses
	isActionAllowed(action?) {
		return(true);
	}

	// Returns boolean true if the current action will succeed if we
	// do nothing.
	// This is to allow scenes to defer to the "normal" failure messages.
	// For example, if we're writing a scene where Bob is blocking the
	// player's movements, we probably don't want to display a
	// "Bob moves to block your path." message if the player is trying
	// to move in a direction without an exit.
	willCurrentActionSucceed() {
		local t;

		// Make sure we're not recursing.
		if(_testCurrentActionLock == true)
			return(nil);
		_testCurrentActionLock = true;

		// Save the "real" transcript.
		t = gTranscript;

		try {
			// Save the current game state.
			savepoint();

			// Create a new transcript and execute the
			// current command.
			gTranscript = new CommandTranscript();
			executeCommand(gActor, gActor,
				gAction.getOrigTokenList(), true);

			// Return true if the command succeeded, nil
			// otherwise.
			return(!gTranscript.isFailure);
		}
		finally {
			// Revert to the old game state.
			undo();

			// Clear our lock.
			_testCurrentActionLock = nil;

			// Restore the old transcript.
			gTranscript = t;
		}
	}

	// Utility methods for figuring out what other actors the
	// passed actor can sense, excluding any in the optional second
	// arg.  If a sense isn't specified via the third argument, sight
	// is used.
	getSpectator(actor, excludeList?, sense?) {
		local l;

		l = getSpectatorList(actor, excludeList, sense);
		if(l.length() < 1)
			return(nil);
		return(l[1]);
	}

	getSpectatorList(actor, excludeList?, sense?) {
		if(!actor || !actor.roomLocation || !actor.ofKind(Actor))
			return([]);

		return(actor.getVisibleActors(excludeList, sense));
	}

	// Remove this scene from notifications.
	removeScene() { beforeAfterController.removeScene(self); }

	// Called during preinit.
	initializeScene() {}

	trySceneAction() { sceneAction(); }

	// Stub methods for the "stuff" the scene needs to do.
	// sceneBeforeAction() gets called during the turn's beforeAction()
	// sceneAfterAction() gets called during the turn's afterAction()
	// sceneAction() gets called when daemons update (after the action
	// for the turn is resolved)
	sceneBeforeAction() {}
	sceneAfterAction() {}
	sceneAction() {}
;
