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

	// Vector containing all SceneRule instances.
	_sceneRules = perInstance(new Vector())

	// All scene rules that the current action matches.  Reset
	// every turn.
	_ruleMatches = nil

	execute() {
		initSceneRules();
		initScenes();
		initSceneDaemon();
	}

	// Take care of initializing all the SceneRules instances.
	initSceneRules() {
		forEachInstance(SceneRule, function(o) {
			o.initializeSceneRule();
			_sceneRules.append(o);
		});
	}

	// Take care of initializing all the Scene instnaces.
	initScenes() {
		forEachInstance(Scene, function(o) {
			o.initializeScene();
			_sceneList.append(o);
		});
	}

	// Create a daemon.
	// Runs independent of the beforeAction()/afterAction() stuff.
	initSceneDaemon() {
		_sceneDaemon = new Daemon(self, &updateScenes, 1);
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

	// Method called by beforeAfterController before every action.
	// This is the earliest point in the turn we'll be called, so
	// we handle general turn setup here.
	globalBeforeAction() {
		_debug('===globalBeforeAction() START===');

		// This is the earliest part of the turn for us, so set up
		// stuff that we'll use throughout the turn.  This gets
		// cleaned up later via _turnCleanup();
		_turnSetup();

		_sceneList.forEach(function(o) { o.trySceneBeforeAction(); });

		_debug('===globalBeforeAction() END===');
	}

	// Method called by beforeAfterController after every action.
	globalAfterAction() {
		_debug('===globalAfterAction() START===');

		_sceneList.forEach(function(o) { o.trySceneAfterAction(); });

		_debug('===globalAfterAction() END===');
	}

	// Called by the Daemon.  This is where we check for
	// scenes starting and stopping this turn.
	// This happens AFTER the action for the turn is resolved.
	updateScenes() {
		_debug('===updateScenes() START===');

		_sceneList.forEach(function(o) {
			o.trySceneAction();
		});

		// This is the last time we'll be called this
		// turn, so clean up temporary stuff turn state.
		_turnCleanup();

		_debug('===updateScenes() END===');
	}

	_turnSetup() {
		// This is the earliest point we're called this
		// turn, so we create a list of rules that
		// match the current turn.
		_setRuleMatches();

		_matchSceneRules();
	}

	_turnCleanup() {
		_clearRuleMatches();

		_clearSceneRules();
	}

	// We figure out what scenes are triggered by the current turn
	// and remember the list for the rest of the turn.
	_setRuleMatches() {
		_debug('setting rule matches');

		// Cache the list of scenes whose rules match this turn.
		_ruleMatches = new Vector(_sceneRules.length);

		// Evaluate the rule states for this turn.
		_sceneRules.forEach(function(o) {
			// Evaluate the rule state for this turn,
			// remembering it if it matches this turn.
			if(o.fire(gActor, gDobj, gAction) == true)
				_ruleMatches.append(o);
		});
	}

	// We go through our list of rule matches and reset their
	// state.
	_clearRuleMatches() {
		_debug('clearing rule matches');
		_ruleMatches.forEach(function(o) { o.clear(); });

		// Deref data cached for the turn.
		_ruleMatches = nil;
	}

	// Go through the scene list, activating any scenes whose
	// rules all match this turn.
	_matchSceneRules() {
		_sceneList.forEach(function(o) {
			o.tryRuleMatch();
		});
	}

	// Revert the state of any scenes that were only active because their
	// rules matched this turn.
	_clearSceneRules() {
		_sceneList.forEach(function(o) {
			o.tryRuleRevert();
		});
	}
;
