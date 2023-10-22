extends StaticBody2D 
class_name NoteBlock

#---------------------#
# properties          #
#---------------------#
## the original position that the note block will return to
## once the player is not stepping and no weight is 
## forced into the block
var original_position
## how far each step is
## 20 pixels default
@export var max_distance = 2
## flag for moving the noteblock
@onready var move_noteblock = false

## main value weight
## this is automatically generated
## whenever a player body that is grounded steps
## on the note block
@onready var current_weight = 0
## this is the cached body
## where the applied force value will be obtained
@onready var current_body = null

#---------------------#
# godot functions     #
#---------------------#
func _ready():
	original_position = global_position

func _process(delta):
	if current_body is SMBPlayer && current_body.is_grounded():
		move_noteblock = true

	if move_noteblock:
		if current_body == null:
			current_weight = clamp(current_weight - delta * 5, 0, 1)
			global_position = lerp(original_position, original_position + Vector2.DOWN * max_distance, current_weight)
		else:
			current_weight = clamp(current_weight + delta * 5, 0, 1)
			global_position = lerp(original_position, original_position + Vector2.DOWN * max_distance, ease_out_cubic(current_weight))
		if current_weight == 0:
			move_noteblock = false

func ease_out_cubic(x):
	return 1.0 - pow(1 - x, 3);

func player_on_noteblock(body):
	current_body = body
	if body is SMBPlayer:
		body.jump_boost = true
	print("a body has entered the block")
func player_left_noteblock(body):
	current_body = null
	if body is SMBPlayer:
		body.jump_boost = false
	print("a body has left the block")
