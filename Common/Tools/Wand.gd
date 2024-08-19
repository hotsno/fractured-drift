extends Node3D

@export var animation_player_path: NodePath
@onready var animation_player: AnimationPlayer = get_node(animation_player_path)

func _process(delta):
	if !animation_player.is_playing():
		animation_player.play("Walking")

func _play_point_wand_animation():
	animation_player.play("Interact")

func _on_player_clicked_on_selecatable_object(_selected_node: Node3D):
	_play_point_wand_animation()
