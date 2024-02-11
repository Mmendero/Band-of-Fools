extends Line2D

@export var defaultForceScale : float = 25.0
@export var attackForceScale : float = 15000.0
@export var BASE_LENGTH: float = 120.0
var attackState1 = false
var attackState2 = false
@export var drawbackLength: float = 300.0
@export var maxLength = 400.0

var player1
var player2

func _ready():
	player1 = $Player1
	player2 = $Player2

func _physics_process(delta):
	
	if attackState1:
		player1.modulate = Color.RED
	else:
		player1.modulate = Color.WHITE
	
	if attackState2:
		player2.modulate = Color.RED
	else:
		player2.modulate = Color("ff00ff")
	
	var input1 = player1.velocity
	var input2 = player2.velocity
	
	#Draws rope
	clear_points()
	add_point(player1.position)
	add_point(player2.position)
	
	#Gets the vetorized rope length and calculates the magnitude of the stretch past the rope's base length
	var ropeLength: Vector2 = abs(player1.global_position - player2.global_position)
	var stretch: float = ropeLength.length() - BASE_LENGTH
	
	#Prevents rope width from exceding a maximum size
	width = min(1500 / ropeLength.length(), 50)

	#Prevents an opposing force if stretch is less than 0
	stretch = max(stretch, 0)
	
	#Calculates how much to snap back based on other player's position
	var snapback1 = player1.global_position.direction_to(player2.global_position)
	var snapback2 = player2.global_position.direction_to(player1.global_position)
	
	#Adds force if not frozen
	if player1.freeze == false:
		player1.apply_force(snapback1 * stretch * defaultForceScale)
	if player2.freeze == false:
		player2.apply_force(snapback2 * stretch * defaultForceScale)
	
	#Calculates the magnitude of the drawback 
	var drawbackScale = (ropeLength.length() - drawbackLength) / (maxLength - drawbackLength)
	
	#WIP: Crappy way of implementing attack, need to change
	if player1.freeze == true and ropeLength.length() > drawbackLength and input2 == Vector2.ZERO and not attackState2:
		#NEED TO FIX
		player2.apply_central_impulse(attackForceScale * snapback2.normalized() * clamp(drawbackScale, 0.6, 1))
		attackState2 = true
	if player2.freeze == true and ropeLength.length() > drawbackLength and input1 == Vector2.ZERO and not attackState1:
		#NEED TO FIX
		player1.apply_central_impulse(attackForceScale * snapback1.normalized() *  clamp(drawbackScale, 0.6, 1))
		attackState1 = true

	#Resets attack states
	if attackState2 and ropeLength.length() < drawbackLength and player2.linear_velocity.length() < 2000:
		attackState2 = false
	if attackState1 and ropeLength.length() < drawbackLength and player1.linear_velocity.length() < 2000:
		attackState1 = false
	
	
	

