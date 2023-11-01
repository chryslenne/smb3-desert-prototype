extends CharacterBody2D
class_name Enemy

static var entities : Array = []
static func get_entities():
	return entities

signal enemy_spawned
signal enemy_despawned
signal enemy_hit
signal enemy_dead

func spawn():
	print(name, " has spawned")
	enemy_spawned.emit()

func despawn():
	print(name, " has despawned")
	enemy_despawned.emit()

func hit():
	print(name, " has been hit")
	enemy_hit.emit()

func kill():
	print(name, " has been killed")
	enemy_dead.emit()

func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			entities.append(self)
		NOTIFICATION_EXIT_TREE:
			entities.erase(self)
