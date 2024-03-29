extends Position2D

var colliding = false
var old_position : Vector2
var collision_rad : float = 8
var collision_data = {}
var last_collide = null
var pinned = false
var debug = false

func _ready():
	add_to_group("RopeNodes")
	old_position = position
	$CircleColl/CollisionShape2D.shape.radius = collision_rad

func _process(_delta):
	
	if Input.is_action_just_pressed("debug_mode"):
		debug = !debug
		$Sprite.visible = debug
		$Sprite.scale = Vector2((collision_rad/2) / 100, (collision_rad/2) / 100)
	
	if debug :
		if $Sprite.visible:
			if pinned:
				$Sprite.modulate = Color.blue
			elif colliding :
				$Sprite.modulate = Color.red
			else:
				$Sprite.modulate = Color.green

func _physics_process(_delta):
	
	var bodies = $CircleColl.get_overlapping_bodies()
	if bodies and !pinned:
		for body in bodies:
			if body.is_in_group("Solid"):
				var world = get_world_2d().direct_space_state
				var collision = world.intersect_ray(global_position, body.global_position)
				
				if collision:
					if !collision_data.has(collision.get("collider_id")):
						collision_data[collision.get("collider_id")] = collision
					last_collide = collision
					colliding = true

func _on_CircleColl_body_exited(body):
	if colliding and last_collide.get("collider") == body:
		colliding = false
		collision_data.erase(last_collide.get("collider_id"))
		last_collide = null
