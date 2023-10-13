#charset "us-ascii"
//
// daemonTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the scene library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f daemonTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "scene.h"

versionInfo: GameID
        name = 'scene Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the scene library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the scene library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;

gameMain: GameMainDef
	initialPlayerChar = me

	newGame() {
		showIntro();
		runGame(true);
	}

	showIntro() {
		"This demo contains a simple daemon-based scene.  The
		scene starts when you <b>&gt;TAKE PEBBLE</b> and stops
		when you <b>&gt;DROP PEBBLE</b>.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+pebble: Thing 'small round pebble' 'pebble'
	"A small, round pebble.  Picking it up starts the scene. "
;

myController: SceneController;

daemonScene: SceneDaemon
	unique = true

	sceneStartAction() {
		"<.p>This is the scene daemon starting. ";
	}
	sceneStopAction(v?) {
		"<.p>This is the scene daemon stopping. ";
	}
	sceneAction() {
		"<.p>This is the scene daemon, first started
			<<toString(getDuration())>> turns ago.\n ";
	}
;
+SceneStartMatchAny;
++Trigger
	srcObject = pebble
	action = TakeAction
;
+SceneEnd;
++Trigger
	srcObject = pebble
	action = DropAction
;
