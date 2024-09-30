extends Resource

class_name DestructibleResource

@export var texture: Texture
@export var audio: AudioStream

func _init(t: Texture = preload("res://assets/sprites/npc1.png"), a: AudioStream = preload("res://assets/sounds/entities/freesound_com_porkmuncher__leaves_impact.wav")):
	texture = t
	audio = a
