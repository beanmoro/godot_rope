extends KinematicBody2D


func _ready():
	pass

func _process(_delta):
	
	var motion = Vector2.ZERO
	
	if Input.is_action_pressed("middle_click"):
		motion = get_viewport().get_mouse_position() - global_position
	
	motion = move_and_slide(motion * 10)
	
