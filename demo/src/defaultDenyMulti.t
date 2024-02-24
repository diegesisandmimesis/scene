#charset "us-ascii"
//
// defaultDenyTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the scene library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f defaultDenyTest.t3m
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
		"This demo contains a default deny scene.  The only
		actions it permits are travel actions, sense actions,
		<b>&gt;TAKE</b> and <b>&gt;QUIT</b>.
		<.p> ";
	}
;

startRoom: SceneRoom 'Void'
	"This is a featureless void."
	north = otherRoom
;
+me: Person;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";

otherRoom: Room 'Other Room'
	"This is the other room."
	south = startRoom
;
+rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

SceneDefaultDeny @startRoom 'This is the default deny message.'
	ignoreSystemActions = nil
;
+ReplaceAction @ExamineAction 'This is the deny message for <q>examine</q>.';
+AllowTravel;
+AllowSenseActions;
+AllowAction @TakeAction;
+AllowAction @QuitAction;
//+ReplaceAction @LookAction 'This is the deny message for <q>look</q>.';

DefineSystemAction(Foozle)
	execSystemAction() {
		"Foozle.\n ";
		execCommandAs(me, 'x pebble');
	}
;
VerbRule(Foozle) 'foozle': FoozleAction verbPhrase = 'foozle/foozling';
