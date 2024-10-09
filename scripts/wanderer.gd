extends Node2D

class_name Wanderer


@export var sprite_2d: Sprite2D
@export var animation_player: AnimationPlayer

@onready var ray_cast_2d_right_floor: RayCast2D = $RayCast2DRightFloor
@onready var ray_cast_2d_left_floor: RayCast2D = $RayCast2DLeftFloor
@onready var ray_cast_2d_right_wall: RayCast2D = $RayCast2DRightWall
@onready var ray_cast_2d_left_wall: RayCast2D = $RayCast2DLeftWall

var baseSpeed = 50 + randi() % 10 - 5
var direction = 1 if randi() % 2 == 0 else -1 

func wander(delta) -> float:
	var no_floor = !ray_cast_2d_left_floor.is_colliding() && !ray_cast_2d_right_floor.is_colliding()
	var both_walls = ray_cast_2d_left_wall.is_colliding() && ray_cast_2d_right_wall.is_colliding()
	if (no_floor || both_walls):
		direction = 0
	else:
		if !ray_cast_2d_right_floor.is_colliding() || ray_cast_2d_right_wall.is_colliding():
			direction = -1
		if !ray_cast_2d_left_floor.is_colliding() || ray_cast_2d_left_wall.is_colliding():
			direction = 1
	
	if direction:
		animation_player.play("walk")
		sprite_2d.flip_h = direction < 0
	elif sprite_2d.get_frame() == 0:
		animation_player.pause()
	
	return delta * baseSpeed * direction
