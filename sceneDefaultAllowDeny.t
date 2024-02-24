#charset "us-ascii"
//
// sceneDefaultAllowDeny.t
//
//	Classes for "default allow" and "default deny" scenes.
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneDefaultAllowDeny: Scene
	sceneBlockMsg = nil
;

class SceneDefaultAllow: SceneDefaultAllowDeny
	rulebookClass = RulebookMatchAny
	sceneBeforeAction() {
		if(sceneBlockMsg != nil)
			reportFailure(sceneBlockMsg);
		else
			reportFailure(&sceneCantDefaultAllow);

		exit;
	}
;

class SceneDefaultDeny: SceneDefaultAllowDeny
	rulebookClass = RulebookMatchNone
	sceneBeforeAction() {
		if(sceneBlockMsg != nil)
			reportFailure(sceneBlockMsg);
		else
			reportFailure(&sceneCantDefaultDeny);

		exit;
	}
;
