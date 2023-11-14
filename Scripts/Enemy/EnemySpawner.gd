extends Node2D
class_name EnemySpawner

enum SpawnType
{
	None,
	Goomba,
	FireSnake,
	PiranhaPlant,
	PileDriverMicroGoomba,
}

@export_enum("Left", "Right") var spawn_direction : String = "Left"
@export var enemy_type : SpawnType = SpawnType.None
@export_multiline var spawn_config : String
var enemy : Enemy = null

func get_prefab():
	match enemy_type:
		SpawnType.Goomba:
			return Goomba.asset
		SpawnType.FireSnake:
			return FireSnake.asset
		SpawnType.PiranhaPlant:
			return PiranhaPlant.asset
		SpawnType.PileDriverMicroGoomba:
			return PileDriverMicroGoomba.asset
	return null
func has_prefab():
	return get_prefab() != null

## This function handles spawning of enemy if it exists
func _on_visible_on_screen_notifier_2d_screen_entered():
	if enemy != null:
		return
	## Spawn enemy and set current position
	enemy = get_prefab().instantiate() if has_prefab() else null
	if enemy:
		enemy._use_spawn_config(spawn_config.strip_edges())
		self.add_child(enemy)
		enemy.global_position = self.global_position
