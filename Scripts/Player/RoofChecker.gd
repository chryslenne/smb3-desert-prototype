extends Node2D

#---------------------#
# properties          #
#---------------------#
var is_roofed : bool
var main_body : PhysicsBody2D
var exceptions : Array

#---------------------#
# godot functions     #
#---------------------#
# Called when the node enters the scene tree for the first time.
#
# This just adds exception to the raycaster
# normally, exceptions are of the owner's physicsBody
# this avoids premature scans
func _ready():
	for exception in exceptions:
		($ShapeCast2D as ShapeCast2D).add_exception(exception)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#
# Roof checker breaks / loots any block that the raycast has scanned
func _process(_delta):
	is_roofed = ($ShapeCast2D as ShapeCast2D).get_collision_count() > 0
	
	for i in ($ShapeCast2D as ShapeCast2D).get_collision_count():
		if ($ShapeCast2D as ShapeCast2D).get_collider(i).has_node("properties/breakable"):
			($ShapeCast2D as ShapeCast2D).get_collider(i).break_block(main_body)
		if ($ShapeCast2D as ShapeCast2D).get_collider(i).has_node("properties/lootable"):
			($ShapeCast2D as ShapeCast2D).get_collider(i).loot_block(main_body)
