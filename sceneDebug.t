#charset "us-ascii"
//
// sceneDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

#ifdef SYSLOG

modify SceneTrigger
	matchRule(actor?, obj?, action?) {
		_debug('matchRule:');
		_debug('\tisRuleActive() = <<toString(isRuleActive())>>');
		_debug('\tmatchAction() = <<toString(matchAction(action))>>');
		_debug('\tmatchObject() = <<toString(matchObject(obj))>>');
		_debug('\tmatchActor() = <<toString(matchActor(actor))>>');
		return(inherited(actor, obj, action));
	}
;

#endif // SYSLOG
