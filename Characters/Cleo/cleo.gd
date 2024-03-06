extends RigidBody2D

var velocity = Vector2()
@export var MAX_SPEED = 700
var CONTROL_FORCE
var attackState = false

func _ready():
	# TODO: Need to consider delta time when we apply it
	#MAX_SPEED = CONTROL_FORCE / (mass*linear_damp)
	CONTROL_FORCE = MAX_SPEED * (mass * linear_damp)
	print("cleo control force: ", CONTROL_FORCE)
