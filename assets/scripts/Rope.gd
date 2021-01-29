extends Node2D

export var rope_length = 300
export var constrain = 10
var ropes = []
export var start_pin = true
export var end_pin = false


var friction = 0.98
var gravity = Vector2(0, 9.8)

var rope_node = preload("res://assets/objects/RopeNode.tscn")


func _ready():
	
	var last_node = null
	for i in range(rope_length / constrain):
		var node = rope_node.instance()
		node.position = position + Vector2(constrain * i, 0)
		node.old_position = node.position
		$rNodes.add_child(node)
		ropes.append(node)


		
func _process(delta):
	
	if Input.is_action_pressed("left_click"):
		ropes[0].position =  get_global_mouse_position() - global_position
	if Input.is_action_just_pressed("right_click"):
		start_pin = !start_pin
	
	update_nodes(delta)
	update_distance()
	var line_segments : PoolVector2Array 
	for rope in ropes:
		line_segments.append(rope.position)
	$Line2D.points = line_segments
	
	


func update_nodes(delta):
	for i in range(ropes.size()):
		if(i != 0 && i!=ropes.size()-1) || (i == 0 && !start_pin) || (i==ropes.size()-1 && !end_pin):
			var motion = (ropes[i].position - ropes[i].old_position) * friction
			ropes[i].old_position = ropes[i].position
			
			if ropes[i].colliding :
				var dir = Vector2(ropes[i].position - to_local(ropes[i].coll_position)).normalized()
				var hitPos = to_local(ropes[i].coll_position) + dir 
				ropes[i].position = hitPos
				#print(ropes[i].position, " ", ropes[i].coll_position)
			else:
				ropes[i].position +=  motion + (gravity * delta)

			
	position = Vector2.ZERO


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
		else:
			if (i+1 == ropes.size()-1 && end_pin):
				ropes[i].position += motion * percent
			elif ropes[i].colliding:
				ropes[i+1].position += motion * percent
			else:
				ropes[i].position -= motion * (percent/2)
				ropes[i+1].position += motion * (percent/2)

