extends Position2D

var colliding = false
var old_position : Vector2
var coll_position : Vector2
var collision_rad : float = 8

var collision_data = {}

var last_collide = null
var collision_info = null

func _ready():
	old_position = position
	$CircleColl/CollisionShape2D.shape.radius = collision_rad

func _process(delta):

	if colliding :
		$Sprite.modulate = Color.red
	else:
		$Sprite.modulate = Color.green

func _physics_process(delta):
	
	var bodies = $CircleColl.get_overlapping_bodies()
	if bodies:
		for body in bodies:
			if body.is_in_group("Solid"):
				var world = get_world_2d().direct_space_state
				var collision = world.intersect_ray(global_position, body.global_position)
				
				if collision:
					collision_info = collision
					
					if !collision_data.has(collision.get("collider_id")):
						#collision_data.append({str(collision.get("collider_id")): collision})
						collision_data[collision.get("collider_id")] = collision
						#print(collision_data, "\n\n\n")
					last_collide = collision
					colliding = true
	
	

#func _on_CircleColl_body_entered(body):
#	if body.is_in_group("Solid"):
#			var world = get_world_2d().direct_space_state
#			var collision = world.intersect_ray(global_position, body.global_position)
#
#			if collision:
#				collision_info = collision
#
#				if !collision_data.has(collision.get("collider_id")):
#					#collision_data.append({str(collision.get("collider_id")): collision})
#					collision_data[collision.get("collider_id")] = collision
#					#print(collision_data, "\n\n\n")
#				last_collide = collision
#				colliding = true


func _on_CircleColl_body_exited(body):
	if colliding and last_collide.get("collider") == body:
		colliding = false
		collision_data.erase(last_collide.get("collider_id"))
		last_collide = null
