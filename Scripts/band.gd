extends Line2D

@export var defaultForceScale : float = 50.0
@export var attackForceScale : float = 15000.0
@export var BASE_LENGTH: float = 120.0
@export var drawbackLength: float = 300.0
@export var maxLength = 400.0
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

func _physics_process(delta):
	# Color stuff
	Cleo.modulate = Color.RED if attackStateCleo else Color.WHITE
	Gumm.modulate = Color.RED if attackStateGumm else Color.WHITE
	
	# Draws Band
	clear_points()
	add_point(Cleo.position)
	add_point(Gumm.position)
	
	# Gets the vectorized rope length and calculates the magnitude of the stretch past the rope's base length
	var ropeLength: Vector2 = abs(Cleo.global_position - Gumm.global_position)
	var stretch: float = ropeLength.length() - BASE_LENGTH
	
	# Prevents rope width from exceding a maximum size
	width = min(1000 / ropeLength.length(), 100)

	# Prevents an opposing force if stretch is less than 0
	stretch = max(stretch, 0)
	
	# Add band tether forces
	var cleoTether = Cleo.global_position.direction_to(Gumm.global_position)
	var gummTether = Gumm.global_position.direction_to(Cleo.global_position)
	if Cleo.freeze == false:
		Cleo.apply_central_force(cleoTether * stretch * defaultForceScale)
	if Gumm.freeze == false:
		Gumm.apply_central_force(gummTether * stretch * defaultForceScale)

	# Finish Attack and Reset Attack States
	if attackStateCleo and ropeLength.length() > drawbackLength and Cleo.linear_velocity.length() < 2000:
		cleoSlingFinished.emit()
	if attackStateGumm and ropeLength.length() > drawbackLength and Gumm.linear_velocity.length() < 2000:
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
	var ropeLength: Vector2 = abs(Cleo.global_position - Gumm.global_position)
	
	# Calculates the magnitude of the drawback 
	var drawbackScale = (ropeLength.length() - drawbackLength) / (maxLength - drawbackLength)
	
	# Calculates how much to snap back based on character's distance from each other
	var snapback = Gumm.global_position.direction_to(Cleo.global_position)
	
	# Character is stretched back far enough to sling
	if ropeLength.length() > drawbackLength:
		Gumm.modulate = Color.YELLOW
	
		# Trigger Slingshot
		if gummInput == Vector2.ZERO and not attackStateGumm:
			gummSlung.emit()
			Gumm.apply_central_impulse(attackForceScale * snapback.normalized() * clamp(drawbackScale, 0.6, 1))
			attackStateGumm = true
			
			Cleo.freeze = true

# Gumm is slinging Cleo
func _on_gumm_slinging():
	if attackStateCleo:
		return
	
	var cleoInput = Cleo.velocity
	var ropeLength: Vector2 = abs(Cleo.global_position - Gumm.global_position)
	
	# Calculates the magnitude of the drawback 
	var drawbackScale = (ropeLength.length() - drawbackLength) / (maxLength - drawbackLength)
	
	# Calculates how much to snap back based on character's distance from each other
	var snapback = Cleo.global_position.direction_to(Gumm.global_position)
	
	# Character is stretched back far enough to sling
	if ropeLength.length() > drawbackLength:
		Cleo.modulate = Color.YELLOW
		
		# Trigger Slingshot
		if cleoInput == Vector2.ZERO:
			cleoSlung.emit()
			Cleo.apply_central_impulse(attackForceScale * snapback.normalized() * clamp(drawbackScale, 0.6, 1))
			attackStateCleo = true
			
			Gumm.freeze = true
