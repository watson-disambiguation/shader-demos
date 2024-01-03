extends Node3D

@export var look_sensitivity = 0.5
@onready var camera = $RaymarchCamera



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseMotion:
		event.relative.x * look_sensitivity
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
