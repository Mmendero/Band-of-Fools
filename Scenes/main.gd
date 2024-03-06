extends Node
@onready var cleo_info = $GUI/PlayerInfoBox/CleoInfo
@onready var gumm_info = $GUI/PlayerInfoBox/GummInfo

@onready var player_value = $GUI/PlayerInfoBox/PlayerValue

@onready var cleo_state_machine = $Band/Cleo/CleoStateMachine
@onready var gumm_state_machine = $Band/Gumm/GummStateMachine

func _process(delta):
	cleo_info.text = "Cleo state: " + cleo_state_machine.state # + "   velocity: " + str($Band/Cleo.linear_velocity.length())
	gumm_info.text = "Gumm state: " + gumm_state_machine.state
	
	player_value.text = "Rope Length: " + str($Band.ropeLength.length()) + "\nMax Length: " + str($Band.maxLength) 
