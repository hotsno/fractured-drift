extends Node3D

var BlockScene = preload("res://Common/Block/block.tscn")
var block_instance: Node
const SPAWN_LOCATION = Vector3i(1, 10, 1)

func _ready():
	pass

func spawn_block():
	var block_instance = BlockScene.instantiate()
	block_instance.position = SPAWN_LOCATION
	add_child(block_instance)
	self.block_instance = block_instance

func _on_pressure_plate_stepped_on():
	if not block_instance:
		spawn_block()
	else:
		block_instance.position = SPAWN_LOCATION
