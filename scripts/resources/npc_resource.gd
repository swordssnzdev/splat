extends Resource

class_name NpcResource

enum NpcDirection {LEFT, RIGHT, WANDER}

@export var texture: Texture
@export var audio: NpcWavset
@export var direction: NpcDirection = NpcDirection.WANDER

func _init(t: Texture = preload("res://assets/sprites/npc1.png"), wavs: NpcWavset = null, d: NpcDirection = NpcDirection.WANDER):
	texture = t
	audio = wavs
	direction = d

func shouldWander():
	return direction == NpcDirection.WANDER
