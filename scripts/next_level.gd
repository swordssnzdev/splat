extends Area2D

@export var NextScene: PackedScene
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.set_process_mode(Node.PROCESS_MODE_ALWAYS)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if (body.get_name() == "Player"):
		get_tree().paused = true
		timer.start()

func _on_timer_timeout() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(NextScene)
