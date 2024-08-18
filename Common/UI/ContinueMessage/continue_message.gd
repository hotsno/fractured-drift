extends Label

@export var next_level: PackedScene

func _ready():
	self.visible = false

func _process(_delta):
	if not self.visible:
		return
	if Input.is_action_just_pressed("enter"):
		get_tree().change_scene_to_packed(next_level)

func _on_sandbox_level_complete():
	self.visible = true
