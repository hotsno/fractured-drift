extends CharacterBody3D

var speed
var speed_multiplier = 1.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 8.0
const SENSITIVITY = 0.004

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

var gravity = 15

@export var max_block_size = 5
@export var mix_block_size = 0.2

@onready var head: Node3D = get_node(head_path)
@onready var camera: Node3D = get_node(camera_path)

@export var interaction_raycast_path: NodePath
@export var object_holding_point_path: NodePath
@export var interact_timer_path: NodePath
@onready var interaction_raycast: RayCast3D = get_node(interaction_raycast_path)
@onready var object_holding_point: Marker3D = get_node(object_holding_point_path)
@onready var interact_timer: Timer = get_node(interact_timer_path)

var picked_object: RigidBody3D
var pull_power = 4
@export var head_path: NodePath
@export var camera_path: NodePath

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var y_offset = -event.relative.x * SENSITIVITY
		var y_rotation = head.rotation.y + y_offset
		head.rotation.y = y_rotation

		var x_offset = -event.relative.y * SENSITIVITY
		var x_rotation = clamp(camera.rotation.x + x_offset, deg_to_rad(-40), deg_to_rad(60))
		camera.rotation.x = x_rotation

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	speed = WALK_SPEED * speed_multiplier

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
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
	if Input.is_action_just_pressed("left_click"):
		if not picked_object:
			_pick_object()
			interact_timer.start()
		elif picked_object and interact_timer.timeout:
			_drop_object()

	_run_resize_object_logic()

func _run_resize_object_logic():
	if picked_object:
		if Input.is_action_pressed("scroll_wheel_up"):
			# x, y, and z are always the same and MeshInstance3D and CollisionShape3D will always be the same size
			if picked_object.get_node("MeshInstance3D").scale.x <= max_block_size:
				picked_object.get_node("MeshInstance3D").scale *= 1.1
				picked_object.get_node("CollisionShape3D").scale *= 1.1

		if Input.is_action_pressed("scroll_wheel_down"):
			# x, y, and z are always the same and MeshInstance3D and CollisionShape3D will always be the same size
			if picked_object.get_node("MeshInstance3D").scale.x >= mix_block_size:
				picked_object.get_node("MeshInstance3D").scale *= 0.9
				picked_object.get_node("CollisionShape3D").scale *= 0.9


func _run_pickup_object_logic():
	if picked_object:
		var a = picked_object.global_position
		var b = object_holding_point.global_position
		picked_object.set_linear_velocity((b - a) * pull_power)
func _pick_object():
	var collider = interaction_raycast.get_collider()
	if collider and collider.is_in_group("ResizeableObjects"):
		picked_object = collider
		picked_object.set_collision_layer_value(2, false)
		picked_object.set_collision_mask_value(1, false)
		picked_object.set_collision_mask_value(2, false)
		picked_object.set_collision_mask_value(3, false)
func _drop_object():
	if picked_object:
		picked_object.set_collision_layer_value(2, true)
		picked_object.set_collision_mask_value(1, true)
		picked_object.set_collision_mask_value(2, true)
		picked_object.set_collision_mask_value(3, true)
		picked_object = null
