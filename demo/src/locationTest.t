#charset "us-ascii"
//
// locationTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the scene library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f locationTest.t3m
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
		//syslog.enable('ruleEngineController');
		showIntro();
		runGame(true);
	}

	showIntro() {
		"This demo has a scene that prevents the <b>&gt;TAKE</b>
		action in the first room (the Void).
		<.p> ";
	}
;

startRoom: Room 'Void'
	"This is a featureless void, where things are un-takable.  There's
	a more take-friendly room to the north. "
	north = northRoom
;
+me: Person;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";

northRoom: Room 'North Room'
	"This is the north room, where you can take things.  The less
	take-friendly void is to the south. "
	south = startRoom
;
+rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

SceneDefaultAllow
	sceneBeforeAction() {
		reportFailure('A mysterious force prevents you from taking
			<<gDobj.theName>>. ');
		exit;
	}
;
+SceneTrigger
	room = startRoom
	action = TakeAction
;
