extends Label

var next_level: PackedScene

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		get_tree().change_scene_to_packed(next_level)
