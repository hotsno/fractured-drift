extends Area3D

signal stepped_on

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body:
		if body.name == "Player":
			stepped_on.emit()
