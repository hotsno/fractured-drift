extends Camera3D

signal clicked_on_selecatable_object

func _input(event):
	if event is InputEventMouseButton and event.pressed and Input.is_action_pressed("left_click"):
		var worldspace = get_world_3d().direct_space_state
		var start = project_ray_origin(event.position)
		var end = project_position(event.position, 1000)
		var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))

		if result:
			var result_node = result.collider

			if result_node.is_in_group("ResizeableObjects"):
				clicked_on_selecatable_object.emit(result_node)
