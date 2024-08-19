extends Node3D

signal door_unlocked

@export var door_to_be_unlocked_path: NodePath
@onready var door_to_be_unlocked: CollisionObject3D = get_node(door_to_be_unlocked_path)

@export var red_button_path: NodePath
@onready var red_button: MeshInstance3D = get_node(red_button_path)
@onready var button_up_pos = red_button.position

@export var button_pushdown_amount = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print(body.name)
	if body.name == "Player" or body.is_in_group("ResizeableObjects"):
		red_button.position = button_up_pos - Vector3(0, button_pushdown_amount, 0)


func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("ResizeableObjects"):
		red_button.position = button_up_pos
