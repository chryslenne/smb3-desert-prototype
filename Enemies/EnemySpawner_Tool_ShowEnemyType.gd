@tool
extends Node2D

func _process(_delta):
	if owner is EnemySpawner:
		var enemy_type = EnemySpawner.SpawnType.keys()[owner.enemy_type]
		for child in $Displays.get_children():
			if child is CanvasItem:
				child.visible = child.name == enemy_type;
		
		var dir = owner.spawn_direction.to_lower()
		for child in $SpawnDirection.get_children():
			if child is CanvasItem:
				child.visible = child.name.to_lower() == dir
