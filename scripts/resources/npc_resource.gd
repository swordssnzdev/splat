extends Resource

class_name NpcResource

enum NpcDirection {LEFT, RIGHT, WANDER}

@export var texture: Texture
@export var audio_folder: String
@export var direction: NpcDirection = NpcDirection.WANDER

func _init(t: Texture = preload("res://assets/sprites/npc1.png"), af: String = "", d: NpcDirection = NpcDirection.WANDER):
	texture = t
	audio_folder = af
	direction = d

func shouldWander():
	return direction == NpcDirection.WANDER
