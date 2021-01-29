extends Node2D

export var rope_length = 300
export var constrain = 10
var ropes = []

export var rope_width = 2
export var rope_color : Color = Color.white
export var collision_radius : float = 8
export var start_pin = true
export var end_pin = false



var friction = 0.98
var gravity = Vector2(0, 9.8)

var rope_node = preload("res://assets/objects/RopeNode.tscn")


func _ready():
	
	var last_node = null
	$Line2D.width = rope_width
	$Line2D.default_color = rope_color
	
	for i in range(rope_length / constrain):
		var node = rope_node.instance()
		node.position = position + Vector2(constrain * i, 0)
		node.old_position = node.position
		node.collision_rad = collision_radius
		$rNodes.add_child(node)
		ropes.append(node)


		
func _process(delta):
	
	if Input.is_action_pressed("left_click"):
		ropes[0].position =  get_global_mouse_position() - global_position
	if Input.is_action_pressed("right_click"):
		ropes[ropes.size()-1].position =  get_global_mouse_position() - global_position
	
	if Input.is_action_just_pressed("PinFirst"):
		start_pin = !start_pin
	if Input.is_action_just_pressed("PinLast"):
		end_pin = !end_pin
	
	
	update_nodes(delta)
	update_distance()

	detect_collisions()
	detect_collisions()
	detect_collisions()
	detect_collisions()
	detect_collisions()
	
	var line_segments : PoolVector2Array 
	for rope in ropes:
		line_segments.append(rope.position)
	$Line2D.points = line_segments
	
	

func detect_collisions():
	
	for i in range(ropes.size()):
		
		if ropes[i].colliding :
			var coll_data = ropes[i].collision_data.values()
				
			for j in range(coll_data.size()):
				var coll_info = coll_data[j]#.collision_data[j]
				var collider = coll_info.get("collider")
				var coll_type = collider.get_node("CollisionShape2D").shape
				#var dir = Vector2(ropes[i].position - to_local(ropes[i].coll_position))
				if coll_type is CircleShape2D:
					
					var radius = coll_type.radius * max(collider.scale.x, collider.scale.y)
					var distance = ropes[i].position.distance_to(to_local(collider.global_position))
									
					
					if distance - radius > 0:
						continue;
					
					var dir = Vector2(ropes[i].position -to_local(collider.global_position)).normalized() 
					var hitPos = to_local(collider.global_position) + dir * radius
					ropes[i].position = hitPos
				
				elif coll_type is RectangleShape2D:
					
					var rect_scale = collider.scale
					var rect_size = coll_type.extents
					var local_pos = collider.to_local(ropes[i].global_position) 
					
					var dx = local_pos.x
					var px = rect_size.x - abs(dx)
					if px <= 0:
						continue;
					
					var dy = local_pos.y
					var py = rect_size.y - abs(dy)
					if py <= 0:
						continue;
						
					if px * rect_scale.x < py * rect_scale.y :
						var sx = sign(dx)
						local_pos.x = sx * rect_size.x
					else:
						var sy = sign(dy)
						local_pos.y =  sy * rect_size.y
						
					var hitPos = to_local(collider.to_global(local_pos))
					ropes[i].position = hitPos
				
					
#					var sprite = Sprite.new()
#					sprite.texture = load("res://icon.png")
#					sprite.scale = Vector2(0.1, 0.1)
#					sprite.modulate = Color.red
#					var nod = add_child(sprite)
#					sprite.position = hitPos
	
	


func update_nodes(delta):
	
	for i in range(ropes.size()):
		#if(i != 0 && i!=ropes.size()-1) || (i == 0 && !start_pin) || (i==ropes.size()-1 && !end_pin):
		if (i !=0 && i!=ropes.size()-1) || (i == 0 && !start_pin) || (i==ropes.size()-1 && !end_pin):
			var motion = (ropes[i].position - ropes[i].old_position) * friction
			ropes[i].old_position = ropes[i].position
			ropes[i].position +=  motion + (gravity * delta)

func update_distance():
	for i in range(ropes.size()):
		if i == ropes.size()-1:
			return

		var distance = ropes[i].position.distance_to(ropes[i+1].position)
		var difference = constrain - distance
		var percent = difference / distance
		var motion = ropes[i+1].position - ropes[i].position

		
		
		if i == 0:
			if start_pin:
				ropes[i+1].position += motion * percent
			else:
				ropes[i].position -= motion * (percent/2)
				ropes[i+1].position += motion * (percent/2)
		elif i == ropes.size()-1:
			pass
		else:
			if (i+1 == ropes.size()-1 && end_pin):
				ropes[i].position -= motion * percent
			#elif ropes[i].colliding:
			#	ropes[i+1].position += motion * percent
			else:
				ropes[i].position -= motion * (percent/2)
				ropes[i+1].position += motion * (percent/2)
	

