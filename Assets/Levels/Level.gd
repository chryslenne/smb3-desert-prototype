extends Node2D
class_name Level

const enums = preload("res://Assets/Basics/Enums.gd")

static var current : Level

static var preloaded_assets : Dictionary

static func preload_prefabs():
	## pipe-related assets here
	preloaded_assets["pipe_transition"] = preload("res://Assets/Pipes/PipeTransition.tscn")
	
	## preloaded powerups here
	preloaded_assets[ItemBlock.PrizeType.keys()[ItemBlock.PrizeType.SuperMushroom]] = preload("res://Assets/Powerups/SuperMushroom.tscn")
	preloaded_assets[ItemBlock.PrizeType.keys()[ItemBlock.PrizeType.FireFlower]] 	= preload("res://Assets/Powerups/FireFlower.tscn")
	preloaded_assets[ItemBlock.PrizeType.keys()[ItemBlock.PrizeType.SuperLeaf]]   	= preload("res://Assets/Powerups/SuperLeaf.tscn")
	preloaded_assets[ItemBlock.PrizeType.keys()[ItemBlock.PrizeType.OneUpMushroom]] = preload("res://Assets/Powerups/OneUpMushroom.tscn")
	preloaded_assets[ItemBlock.PrizeType.keys()[ItemBlock.PrizeType.Starman]] 		= preload("res://Assets/Powerups/Starman.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	current = self
	preload_prefabs()

func get_instance_container():
	if has_node("World/Instantiated"):
		return $World/Instantiated
	return self
