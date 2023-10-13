extends Area2D 
class_name CoinBlock

enum CoinState
{
	Active,
	Disabled,
	PickedUp
}

#---------------------#
# signals             #
#---------------------#
signal onPickup

#---------------------#
# properties          #
#---------------------#
var coin_state : CoinState = CoinState.Active
var amt_coin_reward : int = 100

#---------------------#
# accessors           #
#---------------------#
func is_active(): coin_state == CoinState.Active
func is_disabled(): coin_state == CoinState.Disabled
func is_pickedup(): coin_state == CoinState.PickedUp
func is_pswitch_only(): return $properties/pswitch_only

#---------------------#
# godot functions     #
#---------------------#
func _enter_tree():
	Level.coin_pickups.append(self)
func _exit_tree():
	Level.coin_pickups.erase(self)
func _ready():
	if is_pswitch_only(): coin_state = CoinState.Disabled
	set_visual_state()

# Initializes the visual state
# of the brick block
#
# This is between:
#	Active / Broken / Pickedup
func set_visual_state():
	match coin_state:
		CoinState.Active:
			visible = true
			$collision.disabled = false
		CoinState.Disabled:
			visible = false
			$collision.disabled = true
		CoinState.PickedUp: 
			visible = true
			$visuals.visible = false
			$collision.disabled = false
			onPickup.emit()
			$cleanup.start()

# Throws an explosion particle fx
# and sets the coin state to be picked up
# and initializes visual state
func pickup_coin():	
	if $visualfx/coin: 
		($visualfx/coin as GPUParticles2D).emitting = true
	
	coin_state = CoinState.PickedUp
	set_visual_state()
	
	# amt reward coin

# This is hooked with a timer that starts whenever
# state is broken and begins cleanup by calling queue_free()
func _on_cleanup_timeout():
	queue_free()

# This is hooked with a phyiscs body 2d signal
# and emits when a designated body has been scanned
#
# only scans for player
func _on_body_entered(body):
	if body.has_node("properties/is_a_player"):
		pickup_coin()
