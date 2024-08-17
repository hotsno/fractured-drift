extends Button

@export var first_scene: PackedScene

func _ready():
	self.pressed.connect(on_pressed)

func on_pressed():
	get_tree().change_scene_to_packed(first_scene)
