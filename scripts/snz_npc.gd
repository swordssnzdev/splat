extends Area2D

@export var spec: SnzNpcSpec
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var snz_audio_stream_player_2d: AudioStreamPlayer2D = $SnzAudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.set_texture(spec.texture)
	setRandomAudios(snz_audio_stream_player_2d, spec.wavs)
	snz_audio_stream_player_2d.volume_db = -3
	timer.start(randf_range(1, 10))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setRandomAudios(player: AudioStreamPlayer2D, wavs: Array[AudioStream]):
	var rand_stream = AudioStreamRandomizer.new()
	player.set_volume_db(15)
	player.set_pitch_scale(1)
	var i = 0
	for wav: AudioStream in wavs:
		rand_stream.add_stream(i, wav)
		i += 1
	player.set_stream(rand_stream)

func _on_timer_timeout() -> void:
	if !animation_player.is_playing():
		animation_player.play("snz")
		snz_audio_stream_player_2d.play()
	timer.start(randf_range(1, 10))
