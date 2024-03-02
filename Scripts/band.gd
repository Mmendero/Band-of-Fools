extends Line2D

@export var DEFAULT_BAND_FORCE : float
@export var ATTACK_FORCE : float = 12000.0
@export var UNSTRETCHED_LENGTH: float = 100.0

var ropeLength: Vector2

# Hypothetically, if Cleo and Gumm had different speeds, then both players would need different
# min and max charge lengths, since the player with less speed will have a different, smaller range
# in which they need to attack
@export var MAX_STRETCH_LENGTH = 250
@export var MIN_CHARGE_LENGTH: float = (UNSTRETCHED_LENGTH + MAX_STRETCH_LENGTH) / 2
 
var attackStateCleo = false
var attackStateGumm = false
var hitboxActiveCleo = false
var hitboxActiveGumm = false

var Cleo
var Gumm

signal cleoSlung
signal cleoSlingFinished
signal gummSlung
signal gummSlingFinished

func _ready():
	Cleo = $Cleo
	Gumm = $Gumm
	
	# Calculates the necessary force of the band based on the max stretch length
	# MAX_STRETCH_LENGTH = (max(Cleo.CONTROL_FORCE, Gumm.CONTROL_FORCE) / DEFAULT_BAND_FORCE) + UNSTRETCHED_LENGTH
	DEFAULT_BAND_FORCE = max(Cleo.CONTROL_FORCE, Gumm.CONTROL_FORCE) / (MAX_STRETCH_LENGTH - UNSTRETCHED_LENGTH) 
	print("Max stretch length: ", MAX_STRETCH_LENGTH)
	print("Default band force: ", DEFAULT_BAND_FORCE)

func _physics_process(delta):
	# Color stuff
	Cleo.modulate = Color.RED if attackStateCleo else Color.WHITE
	Gumm.modulate = Color.RED if attackStateGumm else Color.WHITE
	
	# Gets the vectorized rope length and calculates the magnitude of the stretch past the rope's base length
	ropeLength = abs(Cleo.global_position - Gumm.global_position)
	
	# Draws band
	clear_points()
	for child in get_children():
		add_point(child.position)
		
	# Prevents band width from exceeding a maximum size
	width = min(800 / ropeLength.length(), 15)
	
	# Gets length of how far band stretches past the base length
	var stretchLength: float = max(ropeLength.length() - UNSTRETCHED_LENGTH, 0)
	#print(ropeLength.length())
	
	# Add band tether forces
	var cleoTether = Cleo.global_position.direction_to(Gumm.global_position)
	var gummTether = Gumm.global_position.direction_to(Cleo.global_position)
	if Cleo.freeze == false:
		#tether = direction, stretchLength = scaling, DEFAULT_BAND_FORCE = magnitude
		Cleo.apply_central_force(cleoTether * stretchLength * DEFAULT_BAND_FORCE)
	if Gumm.freeze == false:
		Gumm.apply_central_force(gummTether * stretchLength * DEFAULT_BAND_FORCE)

	# Finish Attack and Reset Attack States
	if attackStateCleo and ropeLength.length() > MIN_CHARGE_LENGTH and Cleo.linear_velocity.length() < 2000:
		cleoSlingFinished.emit()
	if attackStateGumm and ropeLength.length() > MIN_CHARGE_LENGTH and Gumm.linear_velocity.length() < 2000:
		gummSlingFinished.emit()
		
	if attackStateCleo and not Input.is_action_pressed("stop2"):
		attackStateCleo = false
	if attackStateGumm and not Input.is_action_pressed("stop1"):
		attackStateGumm = false

# ---------- SLINGSHOT SIGNAL HANDLERS ----------
# Cleo is slinging Gumm
func _on_cleo_slinging():
	if attackStateGumm:
		return

	var gummInput = Gumm.velocity
	ropeLength = abs(Cleo.global_position - Gumm.global_position)
	
	# Calculates the magnitude of the drawback 
	var chargeScale = clamp((ropeLength.length() - MIN_CHARGE_LENGTH) / (MAX_STRETCH_LENGTH - MIN_CHARGE_LENGTH), 0.6, 1)
	
	# Calculates how much to snap back based on character's distance from each other
	var snapback = Gumm.global_position.direction_to(Cleo.global_position)
	
	# Character is stretchLengthed back far enough to sling
	if ropeLength.length() > MIN_CHARGE_LENGTH:
		Gumm.modulate = Color.YELLOW
	
		# Trigger Slingshot
		if gummInput == Vector2.ZERO and not attackStateGumm:
			gummSlung.emit()
			Gumm.apply_central_impulse(ATTACK_FORCE * snapback.normalized() * chargeScale)
			attackStateGumm = true
			
			Cleo.freeze = true

# Gumm is slinging Cleo
func _on_gumm_slinging():
	if attackStateCleo:
		return
	
	var cleoInput = Cleo.velocity
	ropeLength = abs(Cleo.global_position - Gumm.global_position)
	
	# Calculates the magnitude of the drawback 
	var chargeScale = clamp((ropeLength.length() - MIN_CHARGE_LENGTH) / (MAX_STRETCH_LENGTH - MIN_CHARGE_LENGTH), 0.6, 1)
	
	# Calculates how much to snap back based on character's distance from each other
	var snapback = Cleo.global_position.direction_to(Gumm.global_position)
	
	# Character is stretchLengthed back far enough to sling
	if ropeLength.length() > MIN_CHARGE_LENGTH:
		Cleo.modulate = Color.YELLOW
		
		# Trigger Slingshot
		if cleoInput == Vector2.ZERO:
			cleoSlung.emit()
			Cleo.apply_central_impulse(ATTACK_FORCE * snapback.normalized() * chargeScale)
			attackStateCleo = true
			
			Gumm.freeze = true
