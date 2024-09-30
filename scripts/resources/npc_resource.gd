extends Resource

class_name NpcResource

@export var texture: Texture
@export var audio_folder: String

func _init(t: Texture = preload("res://assets/sprites/npc1.png"), af: String = ""):
	texture = t
	audio_folder = af
