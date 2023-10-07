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

	// Should we stop this turn?
	shutdownFlag = nil

	// Number of turns since we started.
	getDuration() {
		if(startTurn == nil)
			return(0);
		return(libGlobal.totalTurns - startTurn);
	}

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

	// The difference between a daemon and a default scene is that
	// the daemon scene doesn't reset automatically.
	tryRuleMatch() {
		inherited();
		_revertFlag = nil;
	}

	// Called by the controller, see if we're running this turn.
	trySceneAction() {
		// If we're not active, bail.
		if(isActive != true)
			return;

		// If startTurn is nil, then we're running for the
		// first time, so we call start() (which in turn calls
		// sceneStartAction()) instead of sceneAction().
		if(startTurn == nil) {
			start();
			return;
		}

		// Since we're running over many turns, we have several
		// methods of pausing the scene and/or skipping turns, so
		// we check them.
		if(_daemonActionCheck() != true)
			return;

		// We got the shutdown flag this turn, so instead of
		// taking a normal turn, we stop.
		if(shutdownFlag == true) {
			stop();
			return;
		}

		// Run the "normal" scene action.
		sceneAction();
	}

	// Run the daemon-specific checks to see if we're supposed to run
	// this turn.
	_daemonActionCheck() {
		// We might have an interval, telling us to only run every
		// nth turn.  Here's where we check.
		if(_checkInterval() != true)
			return(nil);
		
		// See if we're supposed to skip this turn.
		if(skipTurn == libGlobal.totalTurns)
			return(nil);

		return(true);
	}

	// Called by the SceneEnd rulebook.
	tryDaemonStop() {
		// If we're not running, we can't shut down.
		if(isActive() != true)
			return;

		// Set the flag.
		shutdownFlag = true;
	}

	// This is called from trySceneAction() if it's the first time
	// we've run, in which case the setActive(true) is redundant.
	// But we do it this way so we can manually start the daemon by
	// calling this method directly.
	start() {
		_debug('starting daemon');

		// Mark ourselves active, possible redundantly.
		setActive(true);

		// Reset the shutdown flag.
		shutdownFlag = nil;

		// Remember when we started.
		startTurn = libGlobal.totalTurns;

		// Call the scene start action.
		sceneStartAction();
	}

	// Stop the scene.  Arg is the stop state, which will be saved.
	stop(v?) {
		_debug('stopping daemon');

		// Mark ourselves inactive.
		setActive(nil);

		// Remember the stop state.
		stopState = v;

		// Reset the shutdown flag.
		shutdownFlag = nil;

		// Call the scene stop action.
		sceneStopAction();
	}

	// Stub methods.
	sceneStartAction() {}
	sceneStopAction() {}
;
