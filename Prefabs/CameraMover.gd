extends Camera3D

class_name CameraMover

@export var rotation_speed: float
@export var speed: float = 1
var use_mouse = true;

func set_use_mouse(val: bool):
	use_mouse = val
	if val:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called when the node enters the scene tree for the first time.
func _ready():
	set_use_mouse(true)

func _process(delta):
	var theta = rotation.y
	var vert = Vector3.UP * Input.get_axis("ui_in","ui_out")
	var forward = Vector3(-sin(theta),0,-cos(theta)) * Input.get_axis("ui_down","ui_up")
	var side = Vector3(cos(theta),0,-sin(theta)) * Input.get_axis("ui_left","ui_right")
	var velocity = vert + forward + side
	velocity = velocity.normalized() * delta * speed
	position += velocity

func _input(event):
	if event is InputEventMouseMotion and use_mouse:
		rotation.x -= event.relative.y * rotation_speed
		rotation.y -= event.relative.x * rotation_speed
		rotation.x = clamp(rotation.x, -PI/2, PI/2 )
	if event.is_action_pressed("ui_cancel"):
		set_use_mouse(!use_mouse)
		
	
