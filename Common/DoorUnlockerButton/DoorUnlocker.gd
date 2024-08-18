extends Node3D

signal door_unlocked

@onready var button_up_pos = $Node3D/RedButton.position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("ResizeableObjects"):
		$Node3D/RedButton.transform.position = button_up_pos - Vector3(0, 1, 0)


func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("ResizeableObjects"):
		$Node3D/RedButton.transform.position = button_up_pos
