extends Control

var focus = false

func _input(event):
	#if mouse_entered:
		#print('hi')
	#if mouse_exited:
		#print('bruh')
	#print(mouse_entered and mouse_exited)
	pass

func _on_focus_entered():
	print('hi')
	focus = true


func _on_mouse_entered():
	print('yoyo')


func _on_mouse_exited():
	print('kalsjdlkasjd')
