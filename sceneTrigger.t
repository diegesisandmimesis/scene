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

class SceneTravelAction: object
	action = static [ TravelAction, TravelViaAction ]
;

class SceneSenseAction: object
	action = static [ ExamineAction, LookAction, SmellAction,
		ListenToAction, TasteAction, FeelAction, SenseImplicitAction ]
;

class SceneConvAction: object
	action = static [ ConvIAction, ConvTopicTAction ]
;

class SceneIdleAction: object
	action = static [ WaitAction, InventoryAction ]
;

class AllowAction: SceneTrigger
	_tryRulebook(obj) {
		if((obj != nil) && !obj.ofKind(SceneDefaultDeny)) {
			_debug('attempt to place AllowAction inside something
				other than a SceneDefaultDeny instance');
			return(nil);
		}
		return(inherited(obj));
	}
;

class AllowTravel: SceneTravelAction, AllowAction;
class AllowSenseActions: SceneSenseAction, AllowAction;
class AllowConvActions: SceneConvAction, AllowAction;
class AllowIdleActions: SceneIdleAction, AllowAction;

class DenyAction: SceneTrigger
	_tryRulebook(obj) {
		if((obj != nil) && !obj.ofKind(SceneDefaultAllow)) {
			_debug('attempt to place DenyAction inside something
				other than a SceneDefaultAllow instance');
			return(nil);
		}
		return(inherited(obj));
	}
;

class DenyTravel: SceneTravelAction, DenyAction;
class DenySenseActions: SceneSenseAction, DenyAction;
class DenyConvActions: SceneConvAction, DenyAction;
class DenyIdleActions: SceneIdleAction, DenyAction;

class Blocker: SceneTrigger
	sceneBlockMsg = nil
	matchRule(data?) {
		// If the basic matching logic failed, we don't have anything
		// to do.
		if(inherited(data) != true)
			return(nil);

		// Check to see if we have a sceneAction defined, and if
		// so do it.
		if(propType(&sceneAction) != TypeNil)
			sceneAction;

		if(propType(&sceneBlockMsg) != TypeNil)
			reportFailure(sceneBlockMsg);
		else
			// Kludge to make sure the action is marked as
			// a failure.
			reportFailure('');

		// End command processing.
		exit;
	}
;

class BlockAction: Blocker;
class ReplaceAction: Blocker;
