extends CharacterBody2D
class_name Enemy

static var entities : Array = []:
	get = get_entities
static func get_entities():
	return entities

var spawn_direction : String

signal enemy_spawned(entity : Enemy)
signal enemy_despawned(entity : Enemy)
signal enemy_hit()
signal enemy_dead()

func spawn():
	enemy_spawned.emit(self)

func despawn():
	print("despawning ", name)
	enemy_despawned.emit(self)

func hit():
	print("hit ", name)
	enemy_hit.emit()

func kill():
	print("kill ", name)
	enemy_dead.emit()

func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			entities.append(self)
		NOTIFICATION_EXIT_TREE:
			entities.erase(self)
