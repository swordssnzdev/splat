extends Node2D

@export var spec: TriggerResource
@export var texture: Texture

@onready var trigger: Trigger = $Trigger
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.spec = spec
	sprite_2d.texture = texture
