#charset "us-ascii"
//
// sceneDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

#ifdef SYSLOG

modify SceneDaemon
	_startCheck() {
		_debug('_startCheck:');
		_debug('\tisActive() = <<toString(isActive())>>');
		_debug('\tisAvailable() = <<toString(isAvailable())>>');
		_debug('\tstartCheck() = <<toString(startCheck())>>');
		return(inherited());
	}

/*
	trySceneAction() {
		_debug('trySceneAction:');
		_debug('\tisActive() = <<toString(isActive())>>');
		_debug('\t_runCheck() = <<toString(_runCheck())>>');
		inherited();
	}
*/
;

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
