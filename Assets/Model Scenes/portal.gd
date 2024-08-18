extends Node3D

@export var next_level: PackedScene

func _ready():
	$Area3D.connect("body_entered", on_body_entered)

func on_body_entered(body):
	if body and body.name == "Player":
		get_tree().change_scene_to_packed(next_level)
