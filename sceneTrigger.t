#charset "us-ascii"
//
// sceneTrigger.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneTrigger: Trigger
	syslogID = 'SceneTrigger'
	sceneAction = nil
;

class Blocker: SceneTrigger
	matchRule(data?) {
		// If the basic matching logic failed, we don't have anything
		// to do.
		if(inherited(data) != true)
			return(nil);

		// Check to see if we have a sceneAction defined, and if
		// so do it.
		if(propType(&sceneAction) != TypeNil)
			sceneAction;

		// Kludge to make sure the action is marked as a failure.
		reportFailure('');

		// End command processing.
		exit;
	}
;
