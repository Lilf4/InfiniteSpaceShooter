extends Node

var currID: int = 0
var DEBUG_MODE = false
var EnemyInstances = {}
var GamePaused = false
var Scrap: int = 0

func GET_NEWID():
	var returnVal = currID
	currID += 1
	return returnVal

func ResetGameValues():
	Scrap = 0
