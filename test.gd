extends Node2D

enum testEnum
{
	meow1,
	meow2,
	meow3
}

# Called when the node enters the scene tree for the first time.
func _ready():
	print(testEnum.keys()[testEnum.meow1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
