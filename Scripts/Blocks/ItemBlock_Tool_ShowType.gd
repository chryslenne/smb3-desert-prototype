@tool
extends Node2D

func _process(_delta):
	process_visual_type()

func process_visual_type():
	var item_block = owner
	var is_looted = item_block.loot_state == ItemBlock.State.Looted
	for child in get_children():
		if child is CanvasItem:
			child.visible = child.name == ItemBlock.Reward.keys()[item_block.stored_reward] && !is_looted

