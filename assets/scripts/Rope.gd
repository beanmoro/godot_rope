extends Node2D

#Rope Node Vars
var ropes = []
export var rope_nodes : int = 100
export var constrain : float = 10.0
export var iterations : int = 5
var rope_node = preload("res://assets/objects/RopeNode.tscn")

#Rope Line Vars
export var rope_width : float = 2
export var rope_color : Color = Color.white
export var collision_radius : float = 16.0
export var rope_texture : StreamTexture = null

#Rope Physics Vars
export var friction : float = 0.98
var gravity = Vector2(0, 9.8)

func _ready() -> void:
	$Line2D.width = rope_width
	$Line2D.default_color = rope_color
	$Line2D.texture = rope_texture
	$Line2D.texture_mode =Line2D.LINE_TEXTURE_TILE
	
	for i in range(rope_nodes):
		var node = rope_node.instance()
		node.position = position + Vector2(constrain * i, 0)
		node.old_position = node.position
		node.collision_rad = collision_radius
		$rNodes.add_child(node)
		ropes.append(node)


func _process(_delta) -> void:
	if Input.is_action_just_pressed("PinFirst"):
		ropes[0].pinned = !ropes[0].pinned 
	if Input.is_action_just_pressed("PinLast"):
		ropes[ropes.size()-1].pinned = !ropes[ropes.size()-1].pinned
	if Input.is_action_just_pressed("PinRand"):
		var index = rand_range(1, ropes.size()-2)
		ropes[index].pinned = !ropes[index].pinned
	if Input.is_action_just_pressed("UnpinAll"):
		for i in range(ropes.size()):
			if ropes[i].pinned:
				ropes[i].pinned = false
		
	var line_segments : PoolVector2Array = []
	for rope in ropes:
		line_segments.append(rope.position)
	$Line2D.points = line_segments
	
		
func _physics_process(delta) -> void:
	
	update_nodes(delta)
	for _i in range(iterations):
		update_distance()
		detect_collisions()

func detect_collisions() -> void:
	
	for i in range(ropes.size()):
		
		if ropes[i].colliding and !ropes[i].pinned :
			var coll_data = ropes[i].collision_data.values()
				
			for j in range(coll_data.size()):
				var coll_info = coll_data[j]
				var collider = coll_info.get("collider")
				var coll_type = collider.get_node("CollisionShape2D").shape
				
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
						local_pos.x = rect_size.x * sx
					else:
						var sy = sign(dy)
						local_pos.y =  rect_size.y * sy
						
					var hitPos = to_local(collider.to_global(local_pos))
					ropes[i].position = hitPos

func update_nodes(delta) -> void:
	for i in range(ropes.size()):
		if  !ropes[i].pinned:
			var motion = (ropes[i].position - ropes[i].old_position) * friction
			ropes[i].old_position = ropes[i].position
			ropes[i].position +=  motion + (gravity * delta) 
			

func update_distance() -> void:
	for i in range(ropes.size()-1):
		
		if Input.is_action_pressed("left_click"):
			ropes[0].position  =  get_viewport().get_mouse_position()
		if Input.is_action_pressed("right_click"):
			ropes[ropes.size()-1].position =  get_viewport().get_mouse_position()
		
		var diff_vec = ropes[i].position - ropes[i+1].position
		var dist = ropes[i].position.distance_to(ropes[i+1].position)
		var difference = 0
		if dist > 0:
			difference = (constrain - dist) / dist
			
		var motion = diff_vec 
		
		if i == 0:
			if ropes[i].pinned:
				ropes[i+1].position -= motion * difference
			else:
				ropes[i].position += motion * (difference/2)
				ropes[i+1].position -= motion * (difference/2)
		else:
			if ropes[i].pinned:
				ropes[i+1].position -= motion * difference
				
			elif (ropes[i+1].pinned):
				ropes[i].position += motion * difference
				
			else:
				ropes[i].position += motion * (difference/2)
				ropes[i+1].position -= motion * (difference/2)
