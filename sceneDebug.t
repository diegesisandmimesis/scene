#charset "us-ascii"
//
// sceneDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

#ifdef SYSLOG

modify SceneTrigger
	matchTuple(v) {
		_debug('matchTuple:');
		if((v == nil) || !v.ofKind(Tuple)) {
			_debug('\tbad tuple');
		} else {
			if(action != nil)
				_debug('\tmatchAction() = <<toString(matchAction(v.action))>>');
			if(dstObject != nil)
				_debug('\tmatchDstObject() = <<toString(matchDstObject(v.dstObject))>>');
			if(srcActor != nil)
				_debug('\tmatchSrcActor() = <<toString(matchSrcActor(v.srcActor))>>');
			if(dstActor != nil)
				_debug('\tmatchDstActor() = <<toString(matchDstActor(v.dstActor))>>');
			if(srcObject != nil)
				_debug('\tmatchSrcObject() = <<toString(matchSrcObject(v.srcObject))>>');
			if(room != nil)
				_debug('\tmatchLocation() = <<toString(matchLocation(v.room))>>');
		}
		return(inherited(v));
	}
;

modify Scene
	tryRuleMatch() {
		_debug('tryRuleMatch:');
		_debug('\tisActive() = <<toString(isActive())>>');
		_debug('\tisAvailable() = <<toString(isAvailable())>>');
		_debug('\tmatchAllRulebooks() = <<toString(matchAllRulebooks())>>');
		return(inherited());
	}
;

#endif // SYSLOG
