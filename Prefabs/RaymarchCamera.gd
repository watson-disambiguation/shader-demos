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
	
	var velocity = Vector3(
		Input.get_axis("ui_right","ui_left"),
		Input.get_axis("ui_in","ui_out"),
		Input.get_axis("ui_up","ui_down"));
	velocity = velocity.normalized() * delta * speed
	position += velocity

func _input(event):
	if event is InputEventMouseMotion:
		rotation.x += event.relative.y * rotation_speed
		rotation.y += event.relative.x * rotation_speed
		rotation.x = clamp(rotation.x, -PI/2, PI/2 )
