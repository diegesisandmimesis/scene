#charset "us-ascii"
//
// sceneDaemon.t
//
//	Class for scenes on a timer.
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneDaemon: Scene
	// If set, scene only runs once.
	unique = nil

	// Number of turns between each run of the daemon, once started.
	interval = 1

	// Turn the scene started on.
	startTurn = nil

	// Arg passed to the stop() method.
	stopState = nil

	// Should we skip this turn?
	skipTurn = nil

	// Daemon instance.
	//daemonObj = nil

	// Number of times we've run.
	runCount = 0

	// Number of turns since we started.
	runTurns() {
		if(startTurn == nil)
			return(0);
		return(libGlobal.totalTurns - startTurn);
	}

	// CAN the scene start?
	// Contrasted with _startCheck(), which determines if the scene
	// SHOULD start.
	isAvailable() {
		if(unique && (runCount > 0))
			return(nil);
		return(true);
	}

	// Wrapper to make it easier to overwrite startCheck() without
	// having to repeat basic bookkeeping checks.
	_startCheck() {
		if(isActive())
			return(nil);
		if(!isAvailable())
			return(nil);
		return(startCheck());
	}

	_start() {
		// Make sure we're not already running
		if(isActive() == true)
			return;

		setActive(true);

		// Remember when we started.
		startTurn = libGlobal.totalTurns - 1;

		//startDaemon();
		start();
	}

/*
	// Create a new daemon.
	startDaemon(n?) {
		if(daemonObj != nil)
			return(nil);

		daemonObj = new Daemon(self, &_run, (n ? n : 1));

		return(true);
	}

	// Stop a running daemon.
	killDaemon() {
		if(daemonObj == nil)
			return(nil);

		stopDaemon();

		daemonObj.removeEvent();
		daemonObj = nil;

		return(true);
	}
*/

	// See if we should start.
	// PROBABLY called by the sceneController
	_tryStart() {
		if(_startCheck()) {
			_start();
			return(true);
		}
		return(nil);
	}

	_tryStop() {
		local r;

		if(!isActive())
			return(nil);

		if((r = _stopCheck()) == nil)
			return(nil);

		_stop(r);

		return(r);
	}

	// Should the scene stop?
	_stopCheck() { return(stopCheck()); }

	// Stop the scene.  Arg is preserved as a "return value"
	// for the scene.
	_stop(v?) {
		// Mark the scene as inactive.
		setActive(nil);

		stop(v);

		// Remember that we ran.
		runCount = runCount + 1;

		// Remember the stop state.
		stopState = v;

		// Stop the daemon.
		//killDaemon();

		// If we're no longer eligible to run again,
		// unsubscribe from notifications.
		if(!isAvailable())
			removeScene();
	}

	// See if we should run this turn.
	_runCheck() {
		local b;

		// See if we're supposed to skip this turn.
		// We do some juggling because we unset skipTurn every turn.
		b = skipTurn;
		skipTurn = nil;
		if(b == true)
			return(nil);

		return(runCheck());
	}

	_run() {
		// Make sure we're running this turn.
		if(_runCheck() != nil)
			return;

		// Do whatever we're gonna do.
		run();

		// See if we should stop now.
		_tryStop();
	}

	// Stub methods of instances to overwrite.
	startCheck() { return(nil); }
	stopCheck() { return(nil); }
	start() {}
	stop(v?) {}
	//stopDaemon() {}
	runCheck() { return(true); }
	run() {
		if(self.ofKind(Script))
			doScript();
	}
;
