extends Area2D

enum State {OK, DESTROYED}

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var state = State.OK

func _on_area_entered(area: Area2D) -> void:
	if area.get_name() == "AttackSnz":
		if state == State.OK:
			sprite_2d.frame = 1
			audio_stream_player_2d.play()
			state = State.DESTROYED
