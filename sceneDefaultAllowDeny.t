#charset "us-ascii"
//
// sceneDefaultAllowDeny.t
//
//	Classes for "default allow" and "default deny" scenes.
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

// Base class for SceneDefaultAllow and SceneDefaultDeny.
class SceneDefaultAllowDeny: Scene
	// List of actions explicitly allowed.  Used by SceneDefaultDeny.
	allowList = nil

	// List of actions explicitly denied.  Used by SceneDefaultAllow.
	denyList = nil
;

// Allow all actions by default except those on the deny list.
class SceneDefaultAllow: SceneDefaultAllowDeny
	isActionAllowed(action?) { return(!_checkListFor(action, denyList)); }
	sceneBeforeAction() {
		if(!isActionAllowed(gAction)) {
			reportFailure(&sceneCantDefaultAllow);
			exit;
		}
	}
;

// Deny all actions by default except those on the allow list.
class SceneDefaultDeny: SceneDefaultAllowDeny
	isActionAllowed(action?) { return(_checkListFor(action, allowList)); }
	sceneBeforeAction() {
		if(!isActionAllowed(gAction)) {
			reportFailure(&sceneCantDefaultDeny);
			exit;
		}
	}
;
