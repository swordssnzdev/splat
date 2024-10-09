extends Area2D

@export var animation_player: AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.get_name() == "Player":
		body.emit_signal("trigger")
		if animation_player != null && !animation_player.is_playing():
			animation_player.play("activate")
