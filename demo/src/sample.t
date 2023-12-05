#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the scene library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
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
		The only interesting thing to test is comparing
		<.p>
		\n\t<b>&gt;X SIGN</b>
		<.p>
		...with...
		<.p>
		\n\t<b>&gt;READ SIGN</b>
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
#ifdef SYSLOG
		"This demo was compiled with the <b>-D SYSLOG</b> flag,
		meaning there will be a bunch of debugging output.
		<.p>
		The lines starting with <q>sceneController:</q> show the timing
		of the various stages of the scene controller's operation, and
		the lines starting with <q>sceneTrigger:</q> show the state
		of the demo scene, specifically how well the current action
		matches the trigger conditions.
		<.p> ";
#endif // SYSLOG
	}
;

startRoom: Room 'Void'
	"This is a featureless void with a sign on what passes for a wall. "
;
+sign: Fixture 'sign' 'sign'
	"Reading this sign (but not examining/looking at it) triggers
	the scene, but not via logic in the description. "
	dobjFor(Read) {
		action() {
			"The sign says:
			<q>[This space intentionally left blank]</q>. ";
		}
	}
;
+me: Person;

//myController: SceneController;

demoScene: Scene
	sceneBeforeAction() {
		"\nThis is the scene's sceneBeforeAction(), which doesn't
		really do much. <.p> ";
	}
	sceneAction() {
		"<.p>This is the scene triggered via
		<b>&gt;READ SIGN</b>. <.p> ";
	}
	sceneAfterAction() {
		"<.p>\nThis is the scene's sceneAfterAction(), which does
		about as much as the sceneBeforeAction(), only later. "; 
	}
;
+Trigger
	srcObject = sign
	action = ReadAction
;
