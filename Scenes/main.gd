extends Node
@onready var player_info = $GUI/PlayerInfoBox/PlayerInfo
@onready var player_value = $GUI/PlayerInfoBox/PlayerValue

func _process(delta):
	player_value.text = "Rope Length: " + str($Band.ropeLength.length())

func _on_cleo_slinging():
	player_info.text = "Cleo is anchoring."
