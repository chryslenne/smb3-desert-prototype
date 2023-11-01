extends Node2D
class_name Level

const enums = preload("res://Assets/Basics/Enums.gd")

static var current : Level

static var preloaded_assets : Dictionary

func preload_prefabs():
	## pipe-related assets here
	preloaded_assets["pipe_transition"] = preload("res://Assets/Pipes/PipeTransition.tscn")
	
	## preloaded powerups here
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.SuperMushroom]] 	= preload("res://Assets/Item/SuperMushroom.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.FireFlower]] 		= preload("res://Assets/Item/FireFlower.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.SuperLeaf]]   	= preload("res://Assets/Item/SuperLeaf.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.OneUpMushroom]] 	= preload("res://Assets/Item/OneUpMushroom.tscn")
	preloaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.Starman]] 		= preload("res://Assets/Item/Starman.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	current = self
	preload_prefabs()

func get_instance_container():
	if has_node("World/Instantiated"):
		return $World/Instantiated
	return self
