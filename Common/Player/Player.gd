extends CharacterBody3D

signal object_picked
signal object_resized
signal object_dropped
signal clicked_on_selecatable_object

var speed
var speed_multiplier = 1.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 8.0
const SENSITIVITY = 0.004

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

var gravity = 15

var default_floor_ray_length = 7.5
var current_ray_length = 7.5
var scale_down = 0.9090909090909
var ray_scale_up =  1.08
var ray_scale_down = 0.92593

@export var max_block_size = 5
@export var mix_block_size = 0.2

@onready var head: Node3D = get_node(head_path)
@onready var camera: Node3D = get_node(camera_path)

@export var interaction_raycast_path: NodePath
@export var floor_raycast_path: NodePath
@export var object_holding_point_path: NodePath
@export var interact_timer_path: NodePath
@onready var interaction_raycast: RayCast3D = get_node(interaction_raycast_path)
@onready var floor_raycast: RayCast3D = get_node(floor_raycast_path)
@onready var object_holding_point: Marker3D = get_node(object_holding_point_path)
@onready var interact_timer: Timer = get_node(interact_timer_path)

var reload_ready = true

@onready var walking_sound: AudioStreamPlayer3D = $WalkingSound
@onready var pickup_sound: AudioStreamPlayer3D = $PickupSound

var picked_object: RigidBody3D
var pull_power = 4
@export var head_path: NodePath
@export var camera_path: NodePath

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	interact_timer.start()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var y_offset = -event.relative.x * SENSITIVITY
		var y_rotation = head.rotation.y + y_offset
		head.rotation.y = y_rotation

		var x_offset = -event.relative.y * SENSITIVITY
		var x_rotation = clamp(camera.rotation.x + x_offset, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = x_rotation
	if event.is_action_pressed("restart"):
		get_tree().call_deferred("reload_current_scene")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	speed = WALK_SPEED * speed_multiplier

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (global_transform.basis * head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if not walking_sound.playing:
				walking_sound.play()
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)

			walking_sound.stop()
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	_run_pickup_object_logic()
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_coin_coin_collected():
	speed_multiplier = 1.5
	await get_tree().create_timer(10.0).timeout
	speed_multiplier = 1.0

func _input(_event):
	if Input.is_action_just_pressed("left_click") and reload_ready:
		if not picked_object:
			_pick_object()
			reload_ready = false
		elif picked_object and is_instance_valid(picked_object):
			_drop_object()

	if Input.is_action_just_released("left_click"):
		reload_ready = true

	_run_resize_object_logic()

func _run_resize_object_logic():
	if picked_object and is_instance_valid(picked_object):
		var mesh: MeshInstance3D = picked_object.get_node("MeshInstance3D")
		var collision: CollisionShape3D = picked_object.get_node("CollisionShape3D")
		if Input.is_action_pressed("scroll_wheel_up"):
			object_resized.emit()
			# x, y, and z are always the same and MeshInstance3D and CollisionShape3D will always be the same size
			if mesh.scale.x <= max_block_size:
				mesh.scale *= 1.1
				collision.scale *= 1.1

				# MAYBE PROBLEM HERE @MIYAZUKi
				$Head/Camera3D/RayCast3D.target_position *= ray_scale_up

		if Input.is_action_pressed("scroll_wheel_down"):
			object_resized.emit()
			# x, y, and z are always the same and MeshInstance3D and CollisionShape3D will always be the same size
			if mesh.scale.x >= mix_block_size:
				mesh.scale *= scale_down
				collision.scale *= scale_down

				# MAYBE PROBLEM HERE @MIYAZUKi
				$Head/Camera3D/RayCast3D.target_position *= ray_scale_down


func _run_pickup_object_logic():
	if picked_object and is_instance_valid(picked_object):
		var a = picked_object.global_position
		var b = object_holding_point.global_position

		#interaction_raycast.set_collision_mask_value(2, false)
		#var floor: Node3D = interaction_raycast.get_collider()
		# TODO: IF THE object_holding_point IS IN TERRAIN, OVERRIDE IT TO BE ON TOP OF THE TERRAIN
		#interaction_raycast.set_collision_mask_value(2, true)

		var floor_raycast_collider = floor_raycast.get_collider()

		# MAYBE ADD ANGLE LOCK CODE HERE

		if not floor_raycast_collider:
			picked_object.set_linear_velocity((b - a) * pull_power)

		else:
			# BLOCK HOVERING ABOVE FLOOR
			var mesh: MeshInstance3D = picked_object.get_node("MeshInstance3D")
			picked_object.set_linear_velocity((floor_raycast.get_collision_point() - a
			+ Vector3(0, mesh.scale.y / 2, 0)) * pull_power)

	elif not is_instance_valid(picked_object):
		picked_object = null

func _pick_object():
	var collider = interaction_raycast.get_collider()
	if collider and collider.is_in_group("ResizeableObjects"):
		object_picked.emit()
		picked_object = collider
		clicked_on_selecatable_object.emit(picked_object)

		# Fix the band aid solution
		$Head/Camera3D/RayCast3D.target_position.z = -1 * default_floor_ray_length * (ray_scale_up ** (picked_object.get_node("MeshInstance3D").scale.x / 1.1))
		#current_ray_length = default_floor_ray_length

		picked_object.set_collision_layer_value(2, false)
		picked_object.set_collision_layer_value(3, false)
		picked_object.set_collision_mask_value(1, false)
		picked_object.set_collision_mask_value(2, false)
		picked_object.set_collision_mask_value(3, false)

		pickup_sound.play()

		_make_selected_object_glow(picked_object)

func _drop_object():
	if picked_object:

		if picked_object.position.distance_to(position) <= 0.5:
			picked_object.position += Vector3(0, 6, 0)

		#picked_object.set_axis_velocity(Vector3(0, 0, 0))

		var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
		audio.play()

		object_dropped.emit()
		clicked_on_selecatable_object.emit(picked_object)
		picked_object.set_collision_layer_value(2, true)
		picked_object.set_collision_layer_value(3, true)
		picked_object.set_collision_mask_value(1, true)
		picked_object.set_collision_mask_value(2, true)
		picked_object.set_collision_mask_value(3, true)
		picked_object = null

func _make_selected_object_glow(object: Node3D):
	var mesh: MeshInstance3D = object.get_node("MeshInstance3D")
	#mesh.mesh.surface_get_material(0).next_pass.set("shader_parameter/outline_width", 0)
