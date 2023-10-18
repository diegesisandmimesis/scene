#charset "us-ascii"
//
// sceneController.t
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

class SceneController: RuleEngine
	syslogID = 'sceneController'

	_sceneList = perInstance(new Vector())

	execute() {
		inherited();
		initializeScenes();
	}

	initializeScenes() {
		forEachInstance(Scene, function(o) {
			_sceneList.append(o);
		});
	}

	// Add a scene to our list.
	addScene(obj) {
		if((obj == nil) || !obj.ofKind(Scene))
			return(nil);

		if(_sceneList.indexOf(obj) != nil)
			return(nil);

		_sceneList.append(obj);
		
		return(true);
	}

	// Remove a scene from our list.
	removeScene(obj) {
		if(obj == nil)
			return(nil);

		if(_sceneList.indexOf(obj) != nil)
			return(nil);

		_sceneList.removeElement(obj);

		return(true);
	}
;
