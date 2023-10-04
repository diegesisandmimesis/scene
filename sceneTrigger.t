#charset "us-ascii"
//
// sceneTrigger.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneTrigger: Scene
	syslogID = 'SceneTrigger'

	// SceneTuple to use as trigger.
	// If this is nil but if any of the triggerActor, triggerObject, and
	// triggerAction properties are non-nil at preinit they'll be
	// used to create a SceneTuple instance
	trigger = nil

	// Alternate trigger definition.  If any of these is non-nil
	// when at preinit, they'll be used to create a SceneTuple to
	// use as the trigger.
	triggerActor = nil
	triggerObject = nil
	triggerAction = nil

	matchActor(v) { return(trigger && trigger.matchSrcActor(v)); }
	matchObject(v) { return(trigger && trigger.matchDstObject(v)); }
	matchAction(v) { return(trigger && trigger.matchAction(v)); }
	matchTrigger(actor, obj, action) {
		return(isAvailable() && isTriggerActive() && matchAction(action)
			&& matchActor(actor) && matchObject(obj));
	}

	isTriggerActive() { return(true); }

	initializeSceneTrigger() {
		if(trigger != nil)
			return;

		if(!triggerActor && !triggerObject && !triggerAction)
			return;

		trigger = new SceneTuple(triggerActor, triggerObject,
			triggerAction);
	}
;

class SceneSingleLocation: Scene
	sceneLocation = nil

	isActive() { return(gActor == sceneLocation); }
;
