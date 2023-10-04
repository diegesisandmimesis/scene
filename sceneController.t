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
//		Called from a PromptDaemon before the turn starts.
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
sceneController: BeforeAfterThing, PreinitObject
	_sceneDaemon = nil

	_sceneList = perInstance(new Vector())
	_sceneDaemonList = perInstance(new Vector())
	_sceneTriggers = perInstance(new Vector())

	_triggerMatches = nil

	execute() {
		initSceneDaemon();
		initScenes();
		initSceneTriggers();
	}

	initScenes() {
		forEachInstance(Scene, function(o) {
			o.initializeScene();
			if(o.ofKind(SceneDaemon))
				_sceneDaemonList.append(o);
			else
				_sceneList.append(o);
		});
	}

	initSceneTriggers() {
		forEachInstance(SceneTrigger, function(o) {
			o.initializeSceneTrigger();
			_sceneTriggers.append(o);
		});
	}

	// Create a prompt daemon.
	// We get pinged for global beforeAction() and afterAction()
	// notifications DURING the turn, but we need a separate method
	// for bookkeeping BEFORE the turn.
	initSceneDaemon() {
		_sceneDaemon = new Daemon(self, &updateScenes, 1);
	}

	// Called by the PromptDaemon.  This is where we check for
	// scenes starting and stopping this turn.
	updateScenes() {
		_sceneDaemonList.forEach(function(o) {
			if(o.isActive())
				_run();
			else
				_tryStart();
		});
	}

	addScene(obj) {
		if((obj == nil) || !obj.ofKind(Scene))
			return(nil);

		if((_sceneList.indexOf(obj) != nil)
			|| (_sceneDaemonList.indexOf(obj) != nil))
			return(nil);

		if(obj.ofKind(SceneDaemon))
			_sceneDaemonList.append(obj);
		else
			_sceneList.append(obj);

		return(true);
	}

	removeScene(obj) {
		if(obj == nil)
			return(nil);
		if(obj.ofKind(SceneDaemon)
			&& (_sceneDaemonList.indexOf(obj) != nil)) {
			_sceneDaemonList.removeElement(obj);
			return(true);
		}

		if(_sceneList.indexOf(obj) != nil) {
			_sceneList.removeElement(obj);
			return(true);
		}

		return(nil);
	}

	getScenesMatching(actor, obj, action) {
		local r;

		r = new Vector(_sceneTriggers.length);
		_sceneTriggers.forEach(function(o) {
			if(o.matchTrigger(actor, obj, action))
				r.append(o);
		});

		return(r);
	}

	globalBeforeAction() {
		_triggerMatches = getScenesMatching(gActor, gDobj, gAction);
		_triggerMatches.forEach(function(o) { o.setActive(true); });
		_sceneList.forEach(function(o) {
			if(!o.isActive())
				return;
			o.sceneBeforeAction();
		});
	}

	globalAfterAction() {
		_sceneList.forEach(function(o) {
			if(!o.isActive())
				return;
			o.sceneAfterAction();
		});
		_triggerMatches.forEach(function(o) { o.setActive(nil); });
		_triggerMatches = nil;
	}
;
