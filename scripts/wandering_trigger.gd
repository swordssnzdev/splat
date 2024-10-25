extends Node2D

@export var spec: TriggerResource
@onready var wanderer: Wanderer = $Wanderer
@onready var trigger: Trigger = $Trigger


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.spec = spec


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += wanderer.wander(delta)
