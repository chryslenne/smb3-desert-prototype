extends Area2D
const enums = preload("res://Assets/Basics/Enums.gd")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# controlled monitoring flag
	# to avoid too much unwanted process
	# of scanning
	if Level.powerups_lst.size() == 0 && monitoring:
		monitoring = false
	elif Level.powerups_lst.size() > 0 && !monitoring:
		monitoring = true

func _on_body_entered(body):
	# only checks for a node path: 'properties/powerup'
	if body.has_node("properties/powerup"):
		#-------------------------#
		# logic here for powerup  #
		#-------------------------#
		match body.identity:
			enums.PowerupTypes.SuperMushroom:
				#super mushroom logic here
				pass
			enums.PowerupTypes.FireFlower:
				#fire flower logic here
				pass
			enums.PowerupTypes.SuperLeaf:
				#super leaf logic here
				pass
		#-------------------------#
		# cleanup here            #
		#-------------------------#
		body.loot_powerup()
