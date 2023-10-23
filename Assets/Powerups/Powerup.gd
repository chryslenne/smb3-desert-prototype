extends Node2D
class_name Powerup

static var entities : Array = []
@export var type : ItemBlock.PrizeType
@onready var body = $Body


func _notification(what):
	match what:
		NOTIFICATION_POSTINITIALIZE:
			entities.append(self)
		NOTIFICATION_PREDELETE:
			entities.erase(self)

func loot_powerup():
	# powerup logic here...
	$Body.state_despawn()

func on_body_despawned():
	queue_free()
