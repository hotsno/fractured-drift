extends Node3D


@export var animation_player_path: NodePath
@onready var animation_player: AnimationPlayer = get_node(animation_player_path)

var selection_mode: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _play_point_wand_animation():
	animation_player.play("Interact")

func _shoot_magic_laser():
	pass


func _on_camera_3d_clicked_on_selecatable_object(selected_node: Node3D):
	_play_point_wand_animation()
	_shoot_magic_laser()
	selection_mode = true
