extends CharacterBody2D

# State machine
enum State {NO_SNZ, DEFAULT, BUILDUP, SNZ_GROUND, RESNZ_GROUND, SNZ_JUMP, RECOVER, BLOW}

const BASE_SPEED = 150.0
const BASE_JUMP_VELOCITY = -200.0
const BASE_BUILDUP_LENGTH = 100
const BASE_SNZ_INTERVAL = 250
const SNZ_JUMP_VELOCITY = -450.0
const BASE_RESNZ_RATE_ONE_IN_N = 2;

signal trigger

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attacksnz_animation_player: AnimationPlayer = $AttackSnz/AnimationPlayer
@onready var attacksnz_sprite_2d: Sprite2D = $AttackSnz/Sprite2D
@onready var snz_audio_stream_player_2d: AudioStreamPlayer2D = $SnzAudioStreamPlayer2D
@onready var covered_snz_audio_stream_player_2d_2: AudioStreamPlayer2D = $CoveredSnzAudioStreamPlayer2D2
@onready var blow_audio_stream_player_2d: AudioStreamPlayer2D = $BlowAudioStreamPlayer2D
@onready var buildup_audio_stream_player_2d: AudioStreamPlayer2D = $BuildupAudioStreamPlayer2D
@onready var recover_audio_stream_player_2d: AudioStreamPlayer2D = $RecoverAudioStreamPlayer2D
@onready var trigger_audio_stream_player_2d: AudioStreamPlayer2D = $TriggerAudioStreamPlayer2D
@onready var snz_jump_timer: Timer = $SnzJumpTimer

var snzInterval = BASE_SNZ_INTERVAL
var resnzRateOneInN = BASE_RESNZ_RATE_ONE_IN_N

var state = State.NO_SNZ
# Count down to snz
var buildupProgress = BASE_BUILDUP_LENGTH
# Count down to start of buildup
var nextSnzProgress = BASE_SNZ_INTERVAL
# Enough snz time has elapsed for the jump to start
var canJump
var covered = false
var vrotation = 0

func _ready() -> void:
	#load_snz_sounds(snz_audio_stream_player_2d, "swords", "snz")
	#load_snz_sounds(covered_snz_audio_stream_player_2d_2, "swords", "snz_covered")
	animation_player.play("no_snz")

#func load_snz_sounds(player: AudioStreamPlayer2D, character: String, category:String):
	#var rand_stream = AudioStreamRandomizer.new()
	#
	#var dir := DirAccess.open("res://assets/sounds/player/" + character + "/" + category)
	#if dir == null: 
		#printerr("Could not open folder")
		#return
	#dir.list_dir_begin()
	#var i = 0
	#for file: String in dir.get_files():
		#if file.ends_with(".wav"):
			#var clip := load(dir.get_current_dir() + "/" + file)
			#print("clip " + character + " " + category + " " + str(clip) + " " + str(file))
			#rand_stream.add_stream(i, clip)
			#i += 1
	#dir.list_dir_end()
	#player.set_stream(rand_stream)

func goToState(s: State) -> void:
	if state == s && s != State.RESNZ_GROUND:
		return
		
	match s:
		State.NO_SNZ:
			covered = false
			animation_player.play("no_snz")
		State.DEFAULT:
			covered = false
			if state == State.RECOVER && !snz_audio_stream_player_2d.is_playing():
				recover_audio_stream_player_2d.play()
			nextSnzProgress = 0 if state == State.NO_SNZ else snzInterval
			animation_player.play("default")
			pass
		State.BUILDUP:
			animation_player.play("buildup")
			buildupProgress = BASE_BUILDUP_LENGTH
			pass
		State.SNZ_GROUND:
			velocity.x = 0
			if covered:
				covered_snz_audio_stream_player_2d_2.play()
				animation_player.play("snz_covered")
			else:
				# I wanted particles but they don't work on my computer
				attacksnz_animation_player.play("spray")
				animation_player.play("snz")
				snz_audio_stream_player_2d.play()
				snz_jump_timer.start()
		State.RESNZ_GROUND:
			sprite_2d.flip_h = !sprite_2d.flip_h
			if covered:
				covered_snz_audio_stream_player_2d_2.play()
				animation_player.play("resnz_covered")
			else:
				# I wanted particles but they don't work on my computer
				attacksnz_animation_player.play("spray")
				animation_player.play("resnz")
				snz_audio_stream_player_2d.play()
		State.SNZ_JUMP:
			# Start spinning
			vrotation = 1
		State.RECOVER:
			# Stop moving
			velocity = Vector2.ZERO
			vrotation = 0
			sprite_2d.set_rotation(0)
			if covered:
				animation_player.play("recover_covered")
			else:
				animation_player.play("recover")
		State.BLOW:
			velocity = Vector2.ZERO
			animation_player.play("blow")
			blow_audio_stream_player_2d.play()
	
	state = s

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset") || self.get_position().y > 250:
		die()
		return
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("left", "right")

	match state:
		State.NO_SNZ:
			walk(direction)
		State.DEFAULT:
			nextSnzProgress -= delta * 100
			walk(direction)
			if nextSnzProgress <= 0 || Input.is_action_just_pressed("debug_snz"):
				goToState(State.BUILDUP)
		State.BUILDUP:
			if !covered && Input.is_action_pressed("blow"):
				covered = true
				animation_player.play("buildup_covered")
			
			# Speed up animation as buildup progresses
			animation_player.speed_scale = 1 + 8 * (BASE_BUILDUP_LENGTH - buildupProgress) / BASE_BUILDUP_LENGTH
			if direction:
				# Slow down movement as buildup progresses
				velocity.x = direction * BASE_SPEED * (buildupProgress * 1.0 / BASE_BUILDUP_LENGTH)
			else:
				velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
			
			# For the first 90% of the buildup, play buildup sounds that increase in pitch and volume
			if !trigger_audio_stream_player_2d.is_playing() && !buildup_audio_stream_player_2d.is_playing() && buildupProgress > BASE_BUILDUP_LENGTH * 0.1:
				buildup_audio_stream_player_2d.set_pitch_scale(1 + (BASE_BUILDUP_LENGTH - buildupProgress) / (BASE_BUILDUP_LENGTH * 5))
				buildup_audio_stream_player_2d.set_volume_db(5 + 5 * (BASE_BUILDUP_LENGTH - buildupProgress) / BASE_BUILDUP_LENGTH)
				buildup_audio_stream_player_2d.play()
			
			buildupProgress -= delta * 100
			
			if direction:
				sprite_2d.flip_h = velocity.x < 0
			
			if buildupProgress <= 0:
				animation_player.speed_scale = 1 # Reset
				goToState(State.SNZ_GROUND)
		State.SNZ_GROUND:
			if !covered && Input.is_action_pressed("jump") && is_on_floor() && snz_jump_timer.is_stopped():
				velocity.y = SNZ_JUMP_VELOCITY
				velocity.x = direction * BASE_SPEED
				goToState(State.SNZ_JUMP)
		State.RESNZ_GROUND:
			pass
		State.SNZ_JUMP:
			if is_on_floor():
				goToState(State.RECOVER)
			else:
				# Can't control if snz on the ground, but more fun to be able to control the jump
				# TODO pull this out, it's used in a few places
				if direction:
					velocity.x = direction * BASE_SPEED
				else:
					velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
				# Spin!
				sprite_2d.set_rotation(sprite_2d.get_rotation() + vrotation)
				# Decrease the spin speed
				vrotation = move_toward(vrotation, 0, 5 * delta)
				
				if direction:
					sprite_2d.flip_h = velocity.x < 0
					attacksnz_sprite_2d.flip_h = velocity.x < 0
		State.RECOVER:
			pass
		State.BLOW:
			pass


	attacksnz_sprite_2d.flip_h = sprite_2d.flip_h
	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"snz", "resnz", "snz_covered", "resnz_covered":
			end_snz()
		"recover", "recover_covered":
			goToState(State.DEFAULT)
		"blow":
			goToState(State.NO_SNZ)

func end_snz():
	if state == State.SNZ_GROUND || state == State.RESNZ_GROUND:
		if randi() % resnzRateOneInN == 1:
			goToState(State.RESNZ_GROUND)
		else:
			goToState(State.RECOVER)

func die():
	get_tree().reload_current_scene()

func walk(direction):
	# print(position)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = BASE_JUMP_VELOCITY

	if direction:
		sprite_2d.flip_h = velocity.x < 0
		attacksnz_sprite_2d.flip_h = velocity.x < 0
		velocity.x = direction * BASE_SPEED
		animation_player.play()
	else: # Slow down
		if sprite_2d.get_frame() == 0 || sprite_2d.get_frame() == 2:
			animation_player.pause()
		velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
		
	
	
	if Input.is_action_just_pressed("blow"):
		goToState(State.BLOW)
	

func _on_trigger(interval, resnzRate) -> void:
	snzInterval = interval
	resnzRateOneInN = resnzRate
	if state == State.NO_SNZ:
		trigger_audio_stream_player_2d.play()
		goToState(State.DEFAULT)
