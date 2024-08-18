extends Node3D

signal stepped_on

@export var block_scene = preload("res://Common/Block/block.tscn")
@export var spawn_location = Vector3i(1, 10, 1)
var block_instance: Node

func _on_pressure_plate_stepped_on():
	stepped_on.emit()
	if block_instance:
		block_instance.queue_free()
	var new_block_instance = block_scene.instantiate()
	new_block_instance.position = spawn_location
	add_child(new_block_instance)
	self.block_instance = new_block_instance
