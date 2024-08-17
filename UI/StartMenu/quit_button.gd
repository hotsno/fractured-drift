extends Button

func _ready():
	self.pressed.connect(on_pressed)

func on_pressed():
	get_tree().quit()
