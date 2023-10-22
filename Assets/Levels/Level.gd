extends Node

const enums = preload("res://Assets/Basics/Enums.gd")

var current : LevelNode2D
var player : Node2D

var coin_pickups : Array = []
var brick_blocks : Array = []
var prize_blocks : Array = []


var powerup_spawn_delay = 1
var powerups_lst : Array = []
var preloaded_powerups : Dictionary

func preload_powerups():
	preloaded_powerups[enums.BrickPrizeType.SuperMushroom] 		= preload("res://Assets/Powerups/SuperMushroom.tscn")
	preloaded_powerups[enums.BrickPrizeType.FireFlower] 		= preload("res://Assets/Powerups/FireFlower.tscn")
	preloaded_powerups[enums.BrickPrizeType.SuperLeaf]   		= preload("res://Assets/Powerups/SuperLeaf.tscn")
	preloaded_powerups[enums.BrickPrizeType.OneUpMushroom] 		= preload("res://Assets/Powerups/OneUpMushroom.tscn")
	preloaded_powerups[enums.BrickPrizeType.Starman] 			= preload("res://Assets/Powerups/Starman.tscn")
