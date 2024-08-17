extends Control

@export var next_level: PackedScene

func _ready():
	$ContinueMessage.next_level = self.next_level
