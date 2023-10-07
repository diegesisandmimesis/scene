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
	// Number of turns between each run of the daemon, once started.
	interval = 1

	// Since we're polled every turn by the sceneController daemon
	// (instead of running our own daemon) we need a counter to
	// keep track
	_intervalCounter = 0

	// Turn the scene started on.
	startTurn = nil

	// Arg passed to the stop() method.
	stopState = nil

	// Should we skip this turn?
	skipTurn = nil

	// Number of turns since we started.
	getDuration() {
		if(startTurn == nil)
			return(0);
		return(libGlobal.totalTurns - startTurn);
	}

/*
	// Wrapper to make it easier to overwrite startCheck() without
	// having to repeat basic bookkeeping checks.
	_startCheck() {
		if(isActive())
			return(nil);
		if(!isAvailable())
			return(nil);
		return(startCheck());
	}

	// See if we should start.
	// PROBABLY called by the sceneController
	tryStarting() {
		_debug('tryStarting()');
		if(_startCheck()) {
			_start();
			return(true);
		}
		return(nil);
	}

	tryStopping() {
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

		// Remember the stop state.
		stopState = v;

		// If we're no longer eligible to run again,
		// unsubscribe from notifications.
		if(!isAvailable())
			removeScene();
	}
*/

	// Interval check.
	// With the interval property set to n, we run every n turns.
	// Returns boolean true if this is the nth turn.
	_checkInterval() {
		// An interval of one means run every turn, always true.
		if(interval == 1)
			return(true);

		// We never run for a negative or zero interval.
		if(interval < 1)
			return(nil);

		// Increment the interval counter.
		_intervalCounter += 1;

		// If the counter is less than n, don't run this turn.
		if(_intervalCounter < interval)
			return(nil);

		// If we're here, then the counter >= n, so we'll
		// run this turn.  So:  first, reset the counter:
		_intervalCounter = 0;

		// Then return true.
		return(true);
	}

/*
	// See if we should run this turn.
	_runCheck() {
		local b;

		// Check to see if we're scheduled to run this turn.
		if(_checkInterval() != true)
			return(nil);
		
		// See if we're supposed to skip this turn.
		// We do some juggling because we unset skipTurn every turn.
		b = skipTurn;
		skipTurn = nil;
		if(b == true)
			return(nil);

		return(runCheck());
	}

	trySceneAction() {
		// Make sure we're running this turn.
		if(_runCheck() != true)
			return;

		// Do whatever we're gonna do.
		sceneAction();

		// See if we should stop now.
		tryStopping();
	}

	// Stub methods of instances to overwrite.
	startCheck() { return(true); }
	stopCheck() { return(nil); }
	start() {}
	stop(v?) {}
	runCheck() { return(true); }
*/
	// The difference between a daemon and a default scene is that
	// the daemon scene doesn't reset automatically.
	tryRuleMatch() {
		inherited();
		_revertFlag = nil;
	}

	trySceneAction() {
		if(isActive != true)
			return;

		if(startTurn == nil)
			start();
		else
			sceneAction();
	}

	start() {
		_debug('starting daemon');

		setActive(true);

		// Remember when we started.
		startTurn = libGlobal.totalTurns;

		sceneStartAction();
	}

	stop(v?) {
		_debug('stopping daemon');

		stopState = v;
		sceneStopAction();
	}

	sceneStartAction() {}
	sceneStopAction() {}
;
