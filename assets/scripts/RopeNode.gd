extends Position2D

var colliding = false
var old_position : Vector2
var coll_position : Vector2
var coll_dist : float = 2.5
var nAngle = 0
func _ready():
	old_position = position
	#connect("body_entered", self, "is_colliding")

func _process(delta):
	
	if colliding :
		$Sprite.modulate = Color.red
	else:
		$Sprite.modulate = Color.black

func _physics_process(delta):
	
	pass
	
	
	
	
func detect_coll( raycast : RayCast2D) -> bool :
	var coll = false
	
	if raycast.is_colliding():
		var body = raycast.get_collider()
		if body.is_in_group("Solid"):
			coll_position = raycast.get_collision_point()
			coll = true
	
	return coll
	



func _on_CircleColl_body_entered(body):
	
	pass
