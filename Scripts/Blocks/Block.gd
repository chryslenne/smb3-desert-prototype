extends StaticBody2D
class_name Block

signal block_hit(actor)

func hit(actor):
	block_hit.emit(actor)
