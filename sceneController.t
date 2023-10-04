#charset "us-ascii"
//
// sceneController.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

// Scene controller.
//
// Every turn we call:
//
//	updateScenes()
//		Called from a Daemon every turn after the action.
//
//		Runs active SceneDaemon scenes and checks inactive
//		SceneDaemon scenes to see if they should start.
//
//
//	globalBeforeAction()
//		Called from beforeAfterController during the turn, before
//		any action is completed.
//
//	globalAfterAction()
//		Called from beforeAfterController during the turn, after
//		any action is completed.
//
sceneController: BeforeAfterThing, Syslog, PreinitObject
	syslogID = 'sceneController'

	// Daemon that runs every turn, calling updateScenes();
	_sceneDaemon = nil

	// Vector containing all Scene instances.
	_sceneList = perInstance(new Vector())

	// Vector containing all SceneTrigger instances.
	// We keep a separate list (even though all SceneTriggers are
	// Scenes) because we run through the list every time we
	// check the current action.
	_sceneTriggers = perInstance(new Vector())

	// All scene triggers that the current action matches.  Reset
	// every turn.
	_triggerMatches = nil

	// Used to remember the prior state of triggered scenes.
	_triggerStates = nil

	execute() {
		initSceneDaemon();
		initScenes();
		initSceneTriggers();
	}

	// Take care of initializing all the Scene instnaces.
	initScenes() {
		forEachInstance(Scene, function(o) {
			o.initializeScene();
			_sceneList.append(o);
		});
	}

	// Take care of initializing all the SceneTrigger instnaces.
	initSceneTriggers() {
		forEachInstance(SceneTrigger, function(o) {
			o.initializeSceneTrigger();
			_sceneTriggers.append(o);
		});
	}

	// Create a daemon.
	// Runs independent of the beforeAction()/afterAction() stuff.
	initSceneDaemon() {
		_sceneDaemon = new Daemon(self, &updateScenes, 1);
	}

	// Called by the Daemon.  This is where we check for
	// scenes starting and stopping this turn.
	// This happens AFTER the action for the turn is resolved.
	updateScenes() {
		_debug('===updateScenes() START===');

		_sceneList.forEach(function(o) {
			if(o.isActive()) {
				o.sceneAction();
			} else {
				if(o.ofKind(SceneDaemon))
					tryStarting();
			}
		});

		// This is the last time we'll be called this
		// turn, so clean up any cached trigger matches
		// from this turn.
		_clearTriggerMatches();

		_debug('===updateScenes() END===');
	}

	// Add a scene to our list.
	addScene(obj) {
		if((obj == nil) || !obj.ofKind(Scene))
			return(nil);

		if(_sceneList.indexOf(obj) != nil)
			return(nil);

		_sceneList.append(obj);

		return(true);
	}

	// Remove a scene from our list.
	removeScene(obj) {
		if(obj == nil)
			return(nil);

		if(_sceneList.indexOf(obj) == nil)
			return(nil);

		_sceneList.removeElement(obj);

		return(true);
	}

	// Return all SceneTriggers that match the given tuple.
	getScenesMatching(actor, obj, action) {
		local r;

		r = new Vector(_sceneTriggers.length);
		_sceneTriggers.forEach(function(o) {
			if(o.matchTrigger(actor, obj, action))
				r.append(o);
		});

		return(r);
	}

	// Method called by beforeAfterController before every action.
	globalBeforeAction() {
		_debug('===globalBeforeAction() START===');

		// This is the earliest point we're called this
		// turn, so we create a list of triggers that
		// match the current turn.
		_setTriggerMatches();

		_sceneList.forEach(function(o) {
			if(!o.isActive())
				return;
			o.sceneBeforeAction();
		});

		_debug('===globalBeforeAction() END===');
	}

	// Method called by beforeAfterController after every action.
	globalAfterAction() {
		_debug('===globalAfterAction() START===');

		_sceneList.forEach(function(o) {
			if(!o.isActive())
				return;
			o.sceneAfterAction();
		});

		_debug('===globalAfterAction() END===');
	}

	// We figure out what scenes are triggered by the current turn
	// and remember the list for the rest of the turn.
	// We also mark each of the triggered scenes as active for this
	// turn.
	_setTriggerMatches() {
		_debug('setting trigger matches');

		// Cache the list of scenes whose triggers match.
		_triggerMatches = getScenesMatching(gActor, gDobj, gAction);

		// Probably overkill, but we remember the current state
		// of each trigger-able scene before triggering them.
		_triggerStates = new LookupTable();

		_triggerMatches.forEach(function(o) {
			// Remember the current state.
			_triggerStates[o] = o.isActive();

			// Mark the scene as active.
			o.setActive(true);
		});
	}

	// We set each scene triggered this turn back to the state they
	// started in.
	_clearTriggerMatches() {
		_debug('clearing trigger matches');
		_triggerMatches.forEach(function(o) {
			o.setActive(_triggerStates[o]);
		});

		// Deref data cached for the turn.
		_triggerMatches = nil;
		_triggerStates = nil;
	}
;
