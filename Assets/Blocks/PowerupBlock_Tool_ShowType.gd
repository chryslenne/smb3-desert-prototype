@tool
extends Node2D

const enums = preload("res://Assets/Basics/Enums.gd")

func _process(_delta):
	process_visual_type()

func process_visual_type():
	var brick_block = owner
	var is_looted = brick_block.loot_state == enums.BrickPrizeState.Looted
	for child in get_children():
		if child is CanvasItem:
			child.visible = child.name == enums.BrickPrizeType.keys()[brick_block.stored_pup] && !is_looted
