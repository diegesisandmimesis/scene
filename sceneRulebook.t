#charset "us-ascii"
//
// sceneRulebook.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneRulebook: Rulebook
	syslogID = 'SceneRulebook'

	// By default, a rulebook tries to set its owning scene to
	// be active for the turn.
	callback() { if(owner) owner.tryRuleMatch(); }
;

// For daemon startup.
// At the moment we're identical to the base class, but that might
// change in the future.
class SceneStart: SceneRulebook
	syslogID = 'SceneStart'
;

// For daemon shutdown.
class SceneEnd: SceneRulebook
	callback() { if(owner) owner.tryDaemonStop(); }
;
