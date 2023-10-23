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
signal OnPickup

#---------------------#
# properties          #
#---------------------#
static var entities : Array
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
func _ready():
	if is_pswitch_only(): coin_state = CoinState.Disabled
	set_visual_state()
func _notification(what):
	match what:
		NOTIFICATION_POSTINITIALIZE:
			entities.append(self)
		NOTIFICATION_PREDELETE:
			entities.erase(self)

# Initializes the visual state
# of the brick block
#
# This is between:
#	Active / Broken / Pickedup
func set_visual_state():
	match coin_state:
		CoinState.Active:
			visible = true
			$Collision2D.disabled = false
		CoinState.Disabled:
			visible = false
			$Collision2D.disabled = true
		CoinState.PickedUp: 
			visible = true
			$Visual2D.visible = false
			$Collision2D.disabled = false
			$Timer/Cleanup.start()
			OnPickup.emit()

# Throws an explosion particle fx
# and sets the coin state to be picked up
# and initializes visual state
func pickup_coin():	
	if $VisualFX/Coin: 
		($VisualFX/Coin as GPUParticles2D).emitting = true
	
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
func on_player_within_range(body):
	if body is SMBPlayer:
		pickup_coin()
