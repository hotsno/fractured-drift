extends Node3D

signal level_complete

func _on_block_dispenser_stepped_on():
	level_complete.emit()
