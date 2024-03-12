extends Line2D

@export var DEFAULT_BAND_FORCE : float
@export var ATTACK_FORCE : float = 12000.0
@export var UNSTRETCHED_LENGTH: float = 100.0

var ropeLength: Vector2

# Hypothetically, if Cleo and Gumm had different speeds, then both players would need different
# min and max charge lengths, since the player with less speed will have a different, smaller range
# in which they need to attack
@export var MAX_STRETCH_LENGTH = 240
@export var MIN_CHARGE_LENGTH: float = (UNSTRETCHED_LENGTH + MAX_STRETCH_LENGTH) / 2

var firstFrameSkip = true
var prevLength = 0
var pastBandLength = false
var maxForce = 0
var maxLength = 0 
var Cleo
var Gumm

func _ready():
	Cleo = $Cleo
	Gumm = $Gumm
	
	# Calculates the necessary force of the band based on the max stretch length
	# MAX_STRETCH_LENGTH = (max(Cleo.CONTROL_FORCE, Gumm.CONTROL_FORCE) / DEFAULT_BAND_FORCE) + UNSTRETCHED_LENGTH
	DEFAULT_BAND_FORCE = max(Cleo.CONTROL_FORCE, Gumm.CONTROL_FORCE) / (MAX_STRETCH_LENGTH - UNSTRETCHED_LENGTH) 
	print("Max stretch length: ", MAX_STRETCH_LENGTH)
	print("Default band force: ", DEFAULT_BAND_FORCE)

func _process(delta):
	# Draws band
	clear_points()
	for child in get_children():
		add_point(child.position)

func _physics_process(delta):
	prevLength = ropeLength.length()
	# Gets the vectorized rope length and calculates the magnitude of the stretch past the rope's base length
	ropeLength = abs(Cleo.global_position - Gumm.global_position)
	
	# Prevents band width from exceeding a maximum size
	width = min(800 / ropeLength.length(), 15)
	
	# Gets length of how far band stretches past the base length
	var stretchLength: float = max(ropeLength.length() - UNSTRETCHED_LENGTH, 0)
	#print(ropeLength.length())
	
	# Add band tether forces
	var cleoTether = Cleo.global_position.direction_to(Gumm.global_position)
	var gummTether = Gumm.global_position.direction_to(Cleo.global_position)
	var currBandForce = Vector2(cleoTether * stretchLength * DEFAULT_BAND_FORCE).length()
	if Cleo.freeze == false:
		#tether = direction, stretchLength = scaling, DEFAULT_BAND_FORCE = magnitude
		Cleo.apply_central_force(cleoTether * stretchLength * DEFAULT_BAND_FORCE)
	if Gumm.freeze == false:
		Gumm.apply_central_force(gummTether * stretchLength * DEFAULT_BAND_FORCE)
	
	maxLength = max(maxLength, ropeLength.length())
	maxForce = max(maxForce, currBandForce)
	
	## Finish Attack and Reset Attack States
	#if attackStateCleo and ropeLength.length() > MIN_CHARGE_LENGTH and Cleo.linear_velocity.length() < 2000:
		#cleoSlingFinished.emit()
	#if attackStateGumm and ropeLength.length() > MIN_CHARGE_LENGTH and Gumm.linear_velocity.length() < 2000:
		#gummSlingFinished.emit()
		#
	#if attackStateCleo and not Input.is_action_pressed("stop2"):
		#attackStateCleo = false
	#if attackStateGumm and not Input.is_action_pressed("stop1"):
		#attackStateGumm = false

func apply_attack(gummAttacking):
	# Calculates the magnitude of the drawback 
	var chargeScale = clamp((ropeLength.length() - MIN_CHARGE_LENGTH) / (MAX_STRETCH_LENGTH - MIN_CHARGE_LENGTH), 0.6, 1)
	#print(chargeScale)
	
	# Calculates how much to snap back based on character's distance from each other
	var snapback = Cleo.global_position.direction_to(Gumm.global_position)
	
	var who = Cleo
	if gummAttacking:
		who = Gumm
		snapback = -snapback
	
	#print(Vector2(ATTACK_FORCE * snapback.normalized() * chargeScale).length())
	who.apply_central_impulse(ATTACK_FORCE * snapback.normalized() * chargeScale)
