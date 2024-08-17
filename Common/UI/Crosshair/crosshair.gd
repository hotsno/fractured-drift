extends Control  # or Control, Sprite, etc.

func _draw():
	# Black outline
	var center = Vector2(0, 0)
	var radius = 7
	var color = Color(0, 0, 0)
	draw_circle(center, radius, color)
	
	# White crosshair
	center = Vector2(0, 0)
	radius = 5
	color = Color(1, 1, 1)
	draw_circle(center, radius, color)
