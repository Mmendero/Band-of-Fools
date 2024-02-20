extends RigidBody2D

var velocity = Vector2()
var MAX_SPEED = 200
var ATTACK_SPEED = 20000
var INITAL_SPEED = 10000
var attackState = false

signal slinging

# Function to ignore physics engine for RigidBody2D
func _integrate_forces(state):
	if state.linear_velocity.length() > MAX_SPEED:
		if attackState:
			state.linear_velocity = state.linear_velocity.normalized() * min(ATTACK_SPEED, state.linear_velocity.length())
		else:
			state.linear_velocity = state.linear_velocity.normalized() * min(MAX_SPEED, state.linear_velocity.length())
	
	# Halt movement when nothing is pressed. Remove for slippery characters
	if Input.is_anything_pressed() == false:
		state.linear_velocity.x = 0
		state.linear_velocity.y = 0

func _physics_process(delta):
	velocity = Input.get_vector("left1", "right1", "up1", "down1")
	
	if velocity.length() > 0:
		# TODO: Fix this check. The idea is to not increase vector for each frome while player
		# is holding down "stop1" to prevent teleporting after stop1 is released.
		if not Input.is_action_pressed("stop1"):
			apply_central_force(velocity * INITAL_SPEED)
		
		# Play Animations
		$CollisionShape2D.disabled = false
		$AnimatedSprite2D.play()
		freeze = false
	else:
		$AnimatedSprite2D.stop()
		
	# Choose sprite animation
	if velocity.x != 0 || velocity.y != 0:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.animation = "idle"
	
	# Cleo is slinging other player. Pause movement and animation while action input is held
	if Input.is_action_pressed("stop1"):
		freeze = true
		$AnimatedSprite2D.animation = "idle"
		$CollisionShape2D.disabled = true
		
		# Start slingshot attack if it hasn't already. Check to prevent spammy attack calls
		if not attackState:
			slinging.emit()
	else:
		freeze = false
		$CollisionShape2D.disabled = false

# ---------- SLINGSHOT SIGNAL HANDLERS ----------

# Set attack state for Cleo when he is flung. Signal retrieved from band
func _on_band_cleo_slung():
	attackState = true

# End attack state for Cleo after attack is finished. Signal retrieved from band
func _on_band_cleo_sling_finished():
	attackState = false
