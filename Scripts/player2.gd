extends RigidBody2D

var velocityMult : float = 7000.0
var velocity = Vector2()

func _physics_process(delta):
	velocity = Input.get_vector("left2", "right2", "up2", "down2")
	
	if Input.is_action_pressed("stop2"):
		freeze = true
		$CollisionShape2D.disabled = true
	else:
		freeze = false
		$CollisionShape2D.disabled = false
		apply_central_force(velocity * velocityMult)
