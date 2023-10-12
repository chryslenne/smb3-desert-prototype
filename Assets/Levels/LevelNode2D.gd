extends Node2D
class_name LevelNode2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Level.current = self
	Level.preload_powerups()

func get_instance_container(): return $World/Instantiated
