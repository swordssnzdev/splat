extends Area2D

enum State {DEFAULT, HIT, HEARD, EW}

const BASE_SPEED = 50

@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var ew_audio_stream_player_2d: AudioStreamPlayer2D = $EwAudioStreamPlayer2D
@onready var comment_audio_stream_player_2d: AudioStreamPlayer2D = $CommentAudioStreamPlayer2D

var direction = 1
var state = State.DEFAULT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func goToState(s: State):
	if s == state:
		return
	
	match s:
		State.DEFAULT:
			animation_player.play("walk")
			pass
		State.HIT, State.HEARD:
			timer.start()
			pass
		State.EW:
			animation_player.stop()
			timer.start()
			sprite_2d.set_frame(2)
			ew_audio_stream_player_2d.play()
			pass
	
	state = s

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.DEFAULT, State.HIT, State.HEARD:
			if !ray_cast_2d_left.is_colliding() && !ray_cast_2d_right.is_colliding():
				direction = 0
			match direction:
				1:
					if !ray_cast_2d_right.is_colliding():
						direction = -1
				-1:
					if !ray_cast_2d_left.is_colliding():
						direction = 1
			
			if direction:
				animation_player.play("walk")
				position.x += delta * BASE_SPEED * direction
				sprite_2d.flip_h = direction < 0
			elif sprite_2d.get_frame() == 0:
				animation_player.pause()
		State.EW:
			pass

func _on_area_entered(area: Area2D) -> void:
	if state == State.DEFAULT:
		if area.get_name() == "AttackSnz":
			goToState(State.HIT)
		if area.get_name() == "SnzAudible":
			goToState(State.HEARD)

func _on_timer_timeout() -> void:
	match state:
		State.HIT:
			goToState(State.EW)
		State.EW:
			goToState(State.DEFAULT)
		State.HEARD:
			comment_audio_stream_player_2d.play()
			goToState(State.DEFAULT)
