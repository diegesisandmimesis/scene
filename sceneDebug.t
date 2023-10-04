#charset "us-ascii"
//
// sceneDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

#ifdef SYSLOG

modify SceneTrigger
	matchTrigger(actor, obj, action) {
		_debug('matchTrigger:');
		_debug('\tisAvailable() = <<toString(isAvailable())>>');
		_debug('\tisTriggerActive() = <<toString(isTriggerActive())>>');
		_debug('\tmatchAction() = <<toString(matchAction(action))>>');
		_debug('\tmatchObject() = <<toString(matchObject(obj))>>');
		_debug('\tmatchActor() = <<toString(matchActor(actor))>>');
		return(inherited(actor, obj, action));
	}
;

#endif // SYSLOG
