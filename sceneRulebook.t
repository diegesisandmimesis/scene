#charset "us-ascii"
//
// sceneRulebook.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneRulebook: Rulebook
	syslogID = 'SceneRulebook'
;

// For daemon startup.
// At the moment we're identical to the base class, but that might
// change in the future.
class SceneStart: SceneRulebook
	syslogID = 'SceneStart'
;

class SceneStartMatchAny: SceneStart, RulebookMatchAny;
class SceneStartMatchAll: SceneStart;
class SceneStartMatchNone: SceneStart, RulebookMatchNone;

// For daemon shutdown.
class SceneEnd: SceneRulebook
	callback() { if(ruleSystem) ruleSystem.tryDaemonStop(); }
;

class SceneEndMatchAny: SceneEnd, RulebookMatchAny;
class SceneEndMatchAll: SceneEnd;
class SceneEndMatchNone: SceneEnd, RulebookMatchNone;
