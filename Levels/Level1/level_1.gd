extends Node3D

var has_stepped_on_block_dispenser = false
var object_has_been_picked = false
var object_has_been_resized = false
var object_has_been_dropped = false

@onready var text = $UI/Text

func _on_block_dispenser_stepped_on():
	if has_stepped_on_block_dispenser:
		return
	text.text = "Click on the block to select it."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	has_stepped_on_block_dispenser = true


func _on_player_object_picked():
	if object_has_been_picked:
		return
	text.text = "Resize the block with scroll wheel."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	object_has_been_picked = true

func _on_player_object_resized():
	if object_has_been_resized:
		return
	text.text = "Click again to drop the block."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	object_has_been_resized = true


func _on_player_object_dropped():
	if object_has_been_dropped or not object_has_been_resized:
		return
	text.text = "If you need to restart, press R."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	object_has_been_dropped = true
