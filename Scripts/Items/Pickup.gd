extends Node2D
class_name Pickup

static var entities : Array = []
@export var type : ItemBlock.Reward
@onready var body = $Body


func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			entities.append(self)
		NOTIFICATION_EXIT_TREE:
			entities.erase(self)

func loot_item():
	# powerup logic here...
	$Body.state_despawn()

func on_body_despawned():
	queue_free()

static func load_assets():
	Level.instance.loaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.SuperMushroom]] 		= load("res://Prefabs/Items/SuperMushroom.tscn")
	Level.instance.loaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.FireFlower]] 			= load("res://Prefabs/Items/FireFlower.tscn")
	Level.instance.loaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.SuperLeaf]]   		= load("res://Prefabs/Items/SuperLeaf.tscn")
	Level.instance.loaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.OneUpMushroom]] 		= load("res://Prefabs/Items/OneUpMushroom.tscn")
	Level.instance.loaded_assets[ItemBlock.Reward.keys()[ItemBlock.Reward.Starman]] 			= load("res://Prefabs/Items/Starman.tscn")

static func spawn(origin_position, actor, type):
	var instance = Level.instance.loaded_assets[ItemBlock.Reward.keys()[type]].instantiate()
	var instanceBody = instance.get_node("Body")
	
	match type:
		ItemBlock.Reward.SuperMushroom:
			instanceBody.spawn_origin = origin_position
			Level.instance.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
		ItemBlock.Reward.FireFlower:
			instanceBody.spawn_origin = origin_position
			Level.instance.get_instance_container().add_child(instance)
		ItemBlock.Reward.SuperLeaf:
			instance.global_position = origin_position
			Level.instance.get_instance_container().add_child(instance)
		ItemBlock.Reward.OneUpMushroom:
			instanceBody.spawn_origin = origin_position
			Level.instance.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
		ItemBlock.Reward.Starman:
			instanceBody.spawn_origin = origin_position
			Level.instance.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
	return instance
