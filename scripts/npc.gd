extends Area2D

class_name Npc

@export var spec: NpcResource

enum State {DEFAULT, HIT, HEARD, EW}

@onready var wanderer: Wanderer = $Wanderer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var ew_audio_stream_player_2d: AudioStreamPlayer2D = $EwAudioStreamPlayer2D
@onready var comment_audio_stream_player_2d: AudioStreamPlayer2D = $CommentAudioStreamPlayer2D

var direction = 1
var state = State.DEFAULT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.set_texture(spec.texture)
	if spec.direction == NpcResource.NpcDirection.LEFT:
		sprite_2d.set_flip_h(true)
	setRandomAudios(ew_audio_stream_player_2d, spec.audio.ew)
	setRandomAudios(comment_audio_stream_player_2d, spec.audio.comment)

func setRandomAudios(player: AudioStreamPlayer2D, wavs: Array[AudioStream]):
	var rand_stream = AudioStreamRandomizer.new()
	player.set_volume_db(15)
	player.set_pitch_scale(1)
	var i = 0
	for wav: AudioStream in wavs:
		rand_stream.add_stream(i, wav)
		i += 1
	player.set_stream(rand_stream)

func goToState(s: State):
	if s == state:
		return
	
	match s:
		State.DEFAULT:
			if spec.shouldWander():
				animation_player.play("walk")
			else:
				sprite_2d.set_frame(0)
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
	# print(str(state) + " " + str(ray_cast_2d_left_floor.is_colliding()) + " " + str(ray_cast_2d_right_floor.is_colliding()) + " " + str(ray_cast_2d_left_wall.is_colliding()) + " " +str(ray_cast_2d_right_wall.is_colliding()) + "")
	match state:
		State.DEFAULT, State.HIT, State.HEARD:
			if spec.shouldWander():
				position.x += wanderer.wander(delta)
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
