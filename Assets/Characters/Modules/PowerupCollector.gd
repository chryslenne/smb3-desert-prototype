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
	if body.has_node("Properties/Pickup"):
		#-------------------------#
		# logic here for powerup  #
		#-------------------------#
		match enums.BrickPrizeType.get(body.owner.name):
			enums.BrickPrizeType.SuperMushroom:
				#super mushroom logic here
				pass
			enums.BrickPrizeType.FireFlower:
				#fire flower logic here
				pass
			enums.BrickPrizeType.SuperLeaf:
				#super leaf logic here
				pass
			enums.BrickPrizeType.OneUpMushroom:
				#super leaf logic here
				pass
		#-------------------------#
		# cleanup here            #
		#-------------------------#
		body.owner.loot_powerup()
