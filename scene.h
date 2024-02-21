//
// scene.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_SCENE

#include "ruleEngine.h"
#ifndef RULE_ENGINE_H
#error "This module requires the ruleEngine module."
#error "https://github.com/diegesisandmimesis/ruleEngine"
#error "It should be in the same parent directory as this module.  So if"
#error "scene is in /home/user/tads/scene, then"
#error "ruleEngine should be in /home/user/tads/ruleEngine ."
#endif // RULE_ENGINE_H

#include "senseGrep.h"
#ifndef SENSE_GREP_H
#error "This module requires the senseGrep module."
#error "https://github.com/diegesisandmimesis/senseGrep"
#error "It should be in the same parent directory as this module.  So if"
#error "scene is in /home/user/tads/scene, then"
#error "senseGrep should be in /home/user/tads/senseGrep ."
#endif // SENSE_GREP_H

Blocker template @action "sceneAction"?;

#define SCENE_H
