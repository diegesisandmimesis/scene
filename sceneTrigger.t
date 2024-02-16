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
		if(inherited(data) != true)
			return(nil);
		if(propType(&sceneAction) != TypeNil)
			sceneAction;
		reportFailure('');
		exit;
	}
;
