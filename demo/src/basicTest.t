#charset "us-ascii"
//
// basicTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the scene library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f basicTest.t3m
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
		syslog.enable('ruleEngineController');
		showIntro();
		runGame(true);
	}

	showIntro() {
		"This demon contains a simple scene that runs every turn.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";

//RuleEngine;
myScene: Scene
	active = true
	sceneAction() {
		"<.p>This is the output of sceneAction(). ";
	}
;

//myController: SceneController;
