extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.get_name() == "Player":
		body.emit_signal("trigger")
		if !animation_player.is_playing():
			animation_player.play("activate")
