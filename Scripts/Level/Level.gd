extends Node2D
class_name Level

const enums = preload("res://Scripts/Basic/Enums.gd")

static var current : Level

static var preloaded_assets : Dictionary

func preload_prefabs():
	## pipe-related assets here
	preloaded_assets["pipe_transition"] = preload("res://Prefabs/Pipes/PipeTransition.tscn")
	
	## preloaded powerups here
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.SuperMushroom]] 	= preload("res://Prefabs/Items/SuperMushroom.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.FireFlower]] 		= preload("res://Prefabs/Items/FireFlower.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.SuperLeaf]]   	= preload("res://Prefabs/Items/SuperLeaf.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.OneUpMushroom]] 	= preload("res://Prefabs/Items/OneUpMushroom.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.Starman]] 		= preload("res://Prefabs/Items/Starman.tscn")
	
	FireSnake.asset = preload("res://Prefabs/Enemies/FireSnakeMain.tscn")
	FireSnakeTail.asset = preload("res://Prefabs/Enemies/FireSnakeTail.tscn")
	PiranhaPlant.asset = preload("res://Prefabs/Enemies/PiranhaPlant.tscn")
	PileDriverMicroGoomba.asset = preload("res://Prefabs/Enemies/PileDriverMicroGoomba.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	current = self
	preload_prefabs()

func get_instance_container():
	if has_node("World/Instantiated"):
		return $World/Instantiated
	return self
