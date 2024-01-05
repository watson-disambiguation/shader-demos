extends Camera3D

class_name RaymarchCamera

@export var raymarch_shader: ShaderMaterial
@export var rotation_speed: float
@export var speed: float = 1
@onready var quad = $MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	quad.mesh.material = raymarch_shader

func _process(delta):
	var theta = rotation.y
	var vert = Vector3.UP * Input.get_axis("ui_in","ui_out")
	var forward = Vector3(-sin(theta),0,-cos(theta)) * Input.get_axis("ui_down","ui_up")
	var side = Vector3(-cos(theta),0,sin(theta)) * Input.get_axis("ui_left","ui_right")
	var velocity = vert + forward + side
	velocity = velocity.normalized() * delta * speed
	position += velocity
	print(position)
	print(Engine.get_frames_per_second())

func _input(event):
	if event is InputEventMouseMotion:
		rotation.x += event.relative.y * rotation_speed
		rotation.y += event.relative.x * rotation_speed
		rotation.x = clamp(rotation.x, -PI/2, PI/2 )
