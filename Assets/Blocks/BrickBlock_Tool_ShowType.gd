@tool
extends Node2D

func _process(_delta):
	process_visual_type()

func process_visual_type():
	var brick_block = owner
	var is_looted = brick_block.brick_state != BrickBlock.State.Unbroken
	for child in get_children():
		if child is CanvasItem:
			child.visible = child.name == BrickBlock.Reward.keys()[brick_block.reward_type] && !is_looted
