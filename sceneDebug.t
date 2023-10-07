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
		_debug('\tisActive() = <<toString(isActive())>>');
		_debug('\tmatchAction() = <<toString(matchAction(action))>>');
		_debug('\tmatchObject() = <<toString(matchObject(obj))>>');
		_debug('\tmatchActor() = <<toString(matchActor(actor))>>');
		return(inherited(actor, obj, action));
	}
;

modify Scene
	tryRuleMatch() {
		_debug('tryRuleMatch:');
		_debug('\tisActive() = <<toString(isActive())>>');
		_debug('\tisAvailable() = <<toString(isAvailable())>>');
		_debug('\tcheckRulebooks() = <<toString(checkRulebooks())>>');
		return(inherited());
	}
;

#endif // SYSLOG
