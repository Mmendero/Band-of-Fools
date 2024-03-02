extends RigidBody2D

var velocity = Vector2()
# RENAMED 
@export var MAX_SPEED = 700
var CONTROL_FORCE
var attackState = false

func _ready():
	# TODO: Need to consider delta time when we apply it
	#MAX_SPEED = CONTROL_FORCE / (mass*linear_damp)
	CONTROL_FORCE = MAX_SPEED * (mass * linear_damp)
	print("cleo control force: ", CONTROL_FORCE)

signal slinging

# Function to ignore physics engine for RigidBody2D
#func _integrate_forces(state):
	#if state.linear_velocity.length() > MAX_SPEED:
		#if attackState:
			#state.linear_velocity = state.linear_velocity.normalized() * min(ATTACK_SPEED, state.linear_velocity.length())
		#else:
			#state.linear_velocity = state.linear_velocity.normalized() * min(MAX_SPEED, state.linear_velocity.length())
	#
	## Halt movement when nothing is pressed. Remove for slippery characters
	#if Input.is_anything_pressed() == false:
		#state.linear_velocity.x = 0
		#state.linear_velocity.y = 0

func _physics_process(delta):
	velocity = Input.get_vector("left2", "right2", "up2", "down2")
	
	if velocity.length() > 0:
		# TODO: Fix this check. The idea is to not increase vector for each frome while player
		# is holding down "stop2" to prevent teleporting after stop1 is released
		if not Input.is_action_pressed("stop2"):
			apply_central_force(velocity * CONTROL_FORCE)
		
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
	
	# Gumm is slinging other player. Pause movement and animation while action input is held
	if Input.is_action_pressed("stop2"):
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

# Set attack state for Gumm when he is flung. Signal retrieved from band
func _on_band_gumm_slung():
	attackState = true

# End attack state for Gumm after attack is finished. Signal retrieved from band
func _on_band_gumm_sling_finished():
	attackState = false
