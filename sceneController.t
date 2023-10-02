#charset "us-ascii"
//
// sceneController.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

modify beforeAfterController
	_sceneDaemon = nil

	initSceneDaemon() {
		_sceneDaemon = new PromptDaemon(self, &updateScenes);
	}

	addScene(obj) { return(subscribe(obj)); }
	removeScene(obj) { return(detach(obj)); }

	updateScenes() {
	}
;

PreinitObject
	execute() {
		forEachInstance(sceneTrigger, function(o) {
		});
	}
;

