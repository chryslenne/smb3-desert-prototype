extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# controlled monitoring flag
	# to avoid too much unwanted process
	# of scanning
	if Pickup.entities.size() == 0 && monitoring:
		monitoring = false
	elif Pickup.entities.size() > 0 && !monitoring:
		monitoring = true

func _on_body_entered(body):
	# only checks for a node path: 'properties/powerup'
	if body.has_node("Properties/Pickup"):
		#-------------------------#
		# logic here for powerup  #
		#-------------------------#
		match ItemBlock.Reward.get(body.owner.name):
			ItemBlock.Reward.SuperMushroom:
				#super mushroom logic here
				pass
			ItemBlock.Reward.FireFlower:
				#fire flower logic here
				pass
			ItemBlock.Reward.SuperLeaf:
				#super leaf logic here
				pass
			ItemBlock.Reward.OneUpMushroom:
				#super leaf logic here
				pass
		#-------------------------#
		# cleanup here            #
		#-------------------------#
		body.owner.loot_item()
