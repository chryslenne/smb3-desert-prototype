extends Node2D
class_name Powerup

const enums = preload("res://Assets/Basics/Enums.gd")
@export var type : enums.BrickPrizeType
@onready var body = $Body

func _enter_tree():
	Level.powerups_lst.append(self)
func _exit_tree():
	Level.powerups_lst.erase(self)

func loot_powerup():
	# powerup logic here...
	$Body.state_despawn()

func on_body_despawned():
	queue_free()
