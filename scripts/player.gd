extends CharacterBody2D

enum State {DEFAULT, BUILDUP, SNZ_GROUND, SNZ_JUMP, RECOVER}

const BASE_SPEED = 150.0
const BASE_JUMP_VELOCITY = -300.0
const BASE_BUILDUP_LENGTH = 100
const BASE_SNZ_INTERVAL = 250

const SNZ_JUMP_VELOCITY = -500.0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attacksnz_animation_player: AnimationPlayer = $AttackSnz/AnimationPlayer
@onready var attacksnz_sprite_2d: Sprite2D = $AttackSnz/Sprite2D
@onready var snz_audio_stream_player_2d: AudioStreamPlayer2D = $SnzAudioStreamPlayer2D
@onready var blow_audio_stream_player_2d: AudioStreamPlayer2D = $BlowAudioStreamPlayer2D
@onready var buildup_audio_stream_player_2d: AudioStreamPlayer2D = $BuildupAudioStreamPlayer2D

var state = State.DEFAULT
var buildupProgress = BASE_BUILDUP_LENGTH
var nextSnzProgress = BASE_SNZ_INTERVAL
var vrotation = 0

func goToState(s: State) -> void:
	if state == s:
		return
		
	match s:
		State.DEFAULT:
			nextSnzProgress = BASE_SNZ_INTERVAL
			animation_player.play("default")
			pass
		State.BUILDUP:
			animation_player.play("buildup")
			buildupProgress = BASE_BUILDUP_LENGTH
			pass
		State.SNZ_GROUND:
			attacksnz_animation_player.play("spray")
			animation_player.play("snz")
			snz_audio_stream_player_2d.play()
			pass
		State.SNZ_JUMP:
			vrotation = 1
		State.RECOVER:
			velocity = Vector2.ZERO
			vrotation = 0
			sprite_2d.set_rotation(0)
			animation_player.play("recover")
			pass
	
	state = s

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset") || self.get_position().y > 500:
		die()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("left", "right")

	match state:
		State.DEFAULT:
			nextSnzProgress -= delta * 100
			
			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = BASE_JUMP_VELOCITY

			if direction:
				velocity.x = direction * BASE_SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
				
			if Input.is_action_just_pressed("debug_snz") || nextSnzProgress <= 0:
				goToState(State.BUILDUP)
		State.BUILDUP:
			animation_player.speed_scale = 1 + 8 * (BASE_BUILDUP_LENGTH - buildupProgress) / BASE_BUILDUP_LENGTH
			if direction:
				velocity.x = direction * BASE_SPEED * (buildupProgress * 1.0 / BASE_BUILDUP_LENGTH)
			else:
				velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
			
			if !buildup_audio_stream_player_2d.is_playing() && buildupProgress > BASE_BUILDUP_LENGTH * 0.25:
				buildup_audio_stream_player_2d.set_pitch_scale(1 + (BASE_BUILDUP_LENGTH - buildupProgress) / (BASE_BUILDUP_LENGTH * 5))
				buildup_audio_stream_player_2d.set_volume_db((BASE_BUILDUP_LENGTH - buildupProgress) / BASE_BUILDUP_LENGTH)
				buildup_audio_stream_player_2d.play()
			
			buildupProgress -= delta * 100
			if buildupProgress <= 0:
				animation_player.speed_scale = 1
				goToState(State.SNZ_GROUND)
		State.SNZ_GROUND:
			if Input.is_action_pressed("jump") and is_on_floor():
				velocity.y = SNZ_JUMP_VELOCITY
				velocity.x = direction * BASE_SPEED
				goToState(State.SNZ_JUMP)
		State.SNZ_JUMP:
			if is_on_floor():
				goToState(State.RECOVER)
			else:
				if direction:
					velocity.x = direction * BASE_SPEED
				else:
					velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
				sprite_2d.set_rotation(sprite_2d.get_rotation() + vrotation)
				vrotation = move_toward(vrotation, 0, 5 * delta)
		State.RECOVER:
			pass
		
	if direction:
		sprite_2d.flip_h = velocity.x < 0
		attacksnz_sprite_2d.flip_h = velocity.x < 0

	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"snz":
			match state:
				State.SNZ_GROUND:
					goToState(State.RECOVER)
		"recover":
			goToState(State.DEFAULT)

func die():
	blow_audio_stream_player_2d.play()

func _on_blow_audio_stream_player_2d_finished():
	get_tree().reload_current_scene()
