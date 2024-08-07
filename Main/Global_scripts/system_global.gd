extends Node

var currID: int = 0
var DEBUG_MODE = false
var EnemyInstances = {}
var GamePaused = false
var Scrap: int = 0
var Test: int = 5
var Test2: int = 10
var Test3: int = 10

func GET_NEWID():
	var returnVal = currID
	currID += 1
	return returnVal

func ResetGameValues():
	Scrap = 0
