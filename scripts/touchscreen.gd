extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !DisplayServer.is_touchscreen_available() || Input.is_action_just_pressed("hide_touchscreen"):
		queue_free()
