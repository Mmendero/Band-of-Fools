extends RigidBody2D

var velocityMult : float = 7000.0
var velocity = Vector2()

func _physics_process(delta):
	velocity = Input.get_vector("left1", "right1", "up1", "down1")
	
	if Input.is_action_pressed("stop1"):
		freeze = true
		$CollisionShape2D.disabled = true
	else:
		freeze = false
		$CollisionShape2D.disabled = false
		apply_central_force(velocity * velocityMult)
