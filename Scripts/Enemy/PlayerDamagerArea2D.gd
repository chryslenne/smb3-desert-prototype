extends Node

func _on_damage_area_2d_body_entered(body):
	## If it is not processing at all
	## it means it is dead!
	if !owner.is_processing() || !owner.is_physics_processing():
		return
	## Only scan for player and find the correct body class
	if body is SMBPlayer:
		body.hit()
