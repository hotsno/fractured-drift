extends Node3D

signal stepped_on

@export var block_scene = preload("res://Common/Block/block.tscn")
@export var spawn_location = Vector3i(1, 10, 1)
var block_instance: Node

func spawn_block():
	var block_instance = block_scene.instantiate()
	block_instance.position = spawn_location
	add_child(block_instance)
	self.block_instance = block_instance

func _on_pressure_plate_stepped_on():
	emit_signal("stepped_on")
	if not block_instance:
		spawn_block()
	else:
		block_instance.position = spawn_location
