extends Area2D

@export var spec: NpcResource

enum State {DEFAULT, HIT, HEARD, EW}

const BASE_SPEED = 50

@onready var ray_cast_2d_right_floor: RayCast2D = $RayCast2DRightFloor
@onready var ray_cast_2d_left_floor: RayCast2D = $RayCast2DLeftFloor
@onready var ray_cast_2d_right_wall: RayCast2D = $RayCast2DRightWall
@onready var ray_cast_2d_left_wall: RayCast2D = $RayCast2DLeftWall

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
	setRandomAudios(ew_audio_stream_player_2d, spec.audio_folder, "ew")
	setRandomAudios(comment_audio_stream_player_2d, spec.audio_folder, "comment")

func setRandomAudios(player: AudioStreamPlayer2D, folder: String, category: String):
	if folder == null || folder == "" || category == null || category == "":
		return
	var rand_stream = AudioStreamRandomizer.new()
	player.set_volume_db(15)
	player.set_pitch_scale(1)
	
	var dir := DirAccess.open("res://assets/sounds/npc/" + folder + "/" + category)
	if dir == null: 
		printerr("Could not open folder")
		return
	dir.list_dir_begin()
	var i = 0
	for file: String in dir.get_files():
		if file.ends_with(".wav"):
			var clip := load(dir.get_current_dir() + "/" + file)
			rand_stream.add_stream(i, clip)
			i += 1
	dir.list_dir_end()
	player.set_stream(rand_stream)

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
	# print(str(state) + " " + str(ray_cast_2d_left_floor.is_colliding()) + " " + str(ray_cast_2d_right_floor.is_colliding()) + " " + str(ray_cast_2d_left_wall.is_colliding()) + " " +str(ray_cast_2d_right_wall.is_colliding()) + "")
	match state:
		State.DEFAULT, State.HIT, State.HEARD:
			if (!ray_cast_2d_left_floor.is_colliding() && !ray_cast_2d_right_floor.is_colliding()) || (ray_cast_2d_left_wall.is_colliding() && ray_cast_2d_right_wall.is_colliding()):
				direction = 0
			else:
				if !ray_cast_2d_right_floor.is_colliding() || ray_cast_2d_right_wall.is_colliding():
					direction = -1
				if !ray_cast_2d_left_floor.is_colliding() || ray_cast_2d_left_wall.is_colliding():
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
