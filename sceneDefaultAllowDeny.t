#charset "us-ascii"
//
// sceneDefaultAllowDeny.t
//
//	Classes for "default allow" and "default deny" scenes.
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneDefaultAllow: Scene
	rulebookClass = RulebookMatchAny
	sceneBlockMsg = nil
	sceneBeforeAction() {
		if(sceneBlockMsg != nil)
			reportFailure(sceneBlockMsg);
		else
			reportFailure(&sceneCantDefaultAllow);
		exit;
	}
;

class SceneDefaultDeny: Scene
	rulebookClass = RulebookMatchNone
	sceneBlockMsg = nil
	sceneBeforeAction() {
		if(sceneBlockMsg != nil)
			reportFailure(sceneBlockMsg);
		else
			reportFailure(&sceneCantDefaultDeny);
		exit;
	}
;
