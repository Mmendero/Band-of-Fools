extends "res://Scripts/StateMachine.gd"
@onready var band = $"../.."
@onready var other_player = $"../../Cleo"
@onready var other_state_machine = $"../../Cleo/CleoStateMachine"

func _ready():
	add_state("default")
	add_state("anchor")
	add_state("charge")
	add_state("attack")
	add_state("recoil")
	call_deferred("set_state", states.default)

func _state_logic(delta):
	parent.velocity = Input.get_vector("left2", "right2", "up2", "down2")
	
	if ![states.attack, states.recoil].has(state):
		if Input.is_action_pressed("stop2"):
			parent.freeze = true
		else:
			parent.apply_central_force(parent.velocity * parent.CONTROL_FORCE)
			parent.freeze = false

func _get_transition(delta):
	match state:
		states.default:
			if parent.freeze:
				return states.anchor
			if other_state_machine.state == "anchor" and band.ropeLength.length() >= band.MIN_CHARGE_LENGTH:
				return states.charge
				
		states.anchor:
			if not parent.freeze:
				if other_state_machine.state == "anchor":
					return states.charge
				else:
					return states.default
				
		states.charge:
			if parent.freeze:
				return states.anchor
			if other_state_machine.state != "anchor" or band.ropeLength.length() < band.MIN_CHARGE_LENGTH:
				return states.default
			if parent.velocity == Vector2.ZERO:
				return states.attack
		
		states.attack:
			if band.ropeLength.length() > band.MAX_STRETCH_LENGTH + 10:
				return states.recoil
		
		states.recoil:
			if band.ropeLength.length() < band.MIN_CHARGE_LENGTH:
				return states.default
		
			

func _enter_state(new_state, old_state):
	match new_state:
		states.default:
			parent.modulate = Color.WHITE
		states.anchor:
			parent.modulate = Color.DARK_BLUE
		states.charge:
			parent.modulate = Color.GREEN
		states.attack:
			band.apply_attack(true)
			parent.modulate = Color.RED
		states.recoil:
			parent.modulate = Color.YELLOW

func _exit_state(old_state, new_state):
	pass
