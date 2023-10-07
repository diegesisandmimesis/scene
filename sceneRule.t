#charset "us-ascii"
//
// sceneRule.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneRule: Rule
	syslogID = 'SceneRule'

	_senseActions = static [ ExamineAction, LookAction, SmellAction,
		ListenToAction, TasteAction, FeelAction, SenseImplicitAction ]

	_travelActions = static [ TravelAction, TravelViaAction ]

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
;
