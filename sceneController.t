#charset "us-ascii"
//
// sceneController.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneController: RuleEngineController
	syslogID = 'sceneController'

	// Vector containing all Scene instances.
	_sceneList = perInstance(new Vector())

	execute() {
		inherited();
		initScenes();
	}

	// Take care of initializing all the Scene instnaces.
	initScenes() {
		forEachInstance(Scene, function(o) {
			o.initializeScene();
			_sceneList.append(o);
		});
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

	globalBeforeAction() {
		inherited();
		_sceneList.forEach(function(o) { o.trySceneBeforeAction(); });
	}

	// Method called by beforeAfterController after every action.
	globalAfterAction() {
		_sceneList.forEach(function(o) { o.trySceneAfterAction(); });
		inherited();
	}

	// Called by the Daemon.  This is where we check for
	// scenes starting and stopping this turn.
	// This happens AFTER the action for the turn is resolved.
	updateRuleEngine() {
		_sceneList.forEach(function(o) { o.trySceneAction(); });
		inherited();
	}

	_turnSetup() {
		inherited();
		//_setSceneMatches();
	}

	_turnCleanup() {
		inherited();
		_clearSceneMatches();
	}

/*
	_setSceneMatches() {
		_sceneList.forEach(function(o) { o.tryRuleMatch(); });
	}
*/

	_clearSceneMatches() {
		_sceneList.forEach(function(o) { o.tryRuleRevert(); });
	}
;
