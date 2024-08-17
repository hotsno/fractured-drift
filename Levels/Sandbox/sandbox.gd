extends Node3D

signal level_complete

func _ready():
	pass


func _process(delta):
	pass


func _on_block_dispenser_stepped_on():
	emit_signal("level_complete")
