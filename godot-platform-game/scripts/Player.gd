class_name Player extends CharacterBody2D

signal player_dead

var dash_animation_time = 0
@onready var dust_scence: PackedScene = preload("res://scenes/dust.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var platform: GodotEssentialsPlatformerMovementComponent = $GodotEssentialsPlatformerMovementComponent
@onready var animated_sprite = $AnimatedSprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var shake_camera: ShakeCameraComponent2D = %ShakeCameraComponent2D
@onready var _state_chart: StateChart = $StateChart

@onready var run_dust:CPUParticles2D = $RunDust

@onready var action_player: AudioStreamPlayer = $ActionPlayer
@onready var jump_audio_stream: AudioStream = preload("res://assets/audios/phaseJump1.ogg")
@onready var down_audio_stream: AudioStream = preload("res://assets/audios/phaserDown2.ogg")
@onready var redash_audio_stream: AudioStream = preload("res://assets/audios/threeTone2.ogg")
@onready var death_audio_stream: AudioStream = preload("res://assets/audios/zapThreeToneDown.ogg")
@onready var dash_audio_stream: AudioStream = preload("res://assets/audios/handleSmallLeather2.ogg")
@onready var run_audio_stream: AudioStream = preload("res://assets/audios/footstep05.ogg")
@export var wall_jump_height:int
# var player_state = "Idle"

func _physics_process(delta):
	platform.apply_gravity(delta)
	if Input.is_anything_pressed():
		animated_sprite.flip_h = direction() < Vector2.ZERO
	platform.move()


# 冲刺特效
func dash_effect():
	if animated_sprite:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)

		get_tree().root.add_child(sprite)
		
		sprite.global_position = animated_sprite.global_position
		sprite.scale = animated_sprite.scale
		sprite.flip_h = animated_sprite.flip_h
		sprite.flip_v = animated_sprite.flip_v
		sprite.modulate = Color(249.0, 58.0, 59.0, 0.75)
		var tween: Tween = create_tween()
		
		tween.tween_property(sprite, "modulate:a", 0.0, 0.7).set_trans(tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_callback(sprite.queue_free)
	
# 冲刺动作后执行的操作
func _on_godot_essentials_platformer_movement_component_dashed(_position):
	# 播放冲刺的音频
	action_player.stream = dash_audio_stream
	action_player.play()
	# 关闭重力
	platform.gravity_enabled = false


func _on_godot_essentials_platformer_movement_component_finished_dash(_initial_position, _final_position):
	platform.gravity_enabled = true

# 跳跃动作后触发的操作
func _on_godot_essentials_platformer_movement_component_jumped(pos2d):
	action_player.stream = jump_audio_stream
	action_player.play()
	# play dust animation
	if dust_scence:
		var dust_effect = dust_scence.instantiate()
		get_tree().root.add_child(dust_effect)
		dust_effect.position.x = pos2d.x-5
		dust_effect.position.y = pos2d.y




func _on_ready():
	pass

# 处理跳跃动作
func _on_jump_state_physics_processing(delta):
	var horizontal_direction = direction()
	platform.accelerate_horizontally(horizontal_direction, delta)\
		.apply_air_friction_vertical()
	if Input.is_action_just_released("jump"):
		platform.shorten_jump()
	# 状态转移到 wall jump
	if is_on_wall() and not is_on_floor() and Input.is_action_just_pressed("jump"):
		_state_chart.send_event("wallJump")

func _is_pressed_move_button(actions:Array)-> bool:
	var result = false
	for action in actions:
		result = result or Input.is_action_pressed(action)
	return result


func direction()->Vector2:
	var vec = Vector2.ZERO
	vec.x = all_direction().x
	return vec
# 获取输入的向量值
func all_direction(face_direction:Vector2 = Vector2.ZERO)->Vector2:
	var vec = Vector2.ZERO
	if _is_pressed_move_button(["button_left","button_right","button_up", "button_down"]):
		vec = Input.get_vector("button_left","button_right","button_up", "button_down")
	else:
		vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") 
	
	if vec.is_zero_approx():
		return face_direction.normalized()
	else:
		return vec.normalized()

# 将输入向量转化成固定的8个方向
func _fixed_direction(orgin_direction:Vector2 = Vector2.ZERO)->Vector2:
	if orgin_direction.is_zero_approx():
		return orgin_direction
	var rad = atan2(orgin_direction.y, orgin_direction.x)
	var degrees = rad_to_deg(rad)
	var angle = wrapf(degrees, 0, 360)
	if angle >= 22.5 && angle < 67.5:
		return Vector2(1, 1)
	elif angle >= 67.5 && angle < 112.5:
		return Vector2.DOWN
	elif angle >= 112.5 && angle < 157.5:
		return Vector2(-1, 1)
	elif angle >= 157.5 && angle < 202.5:
		return Vector2.LEFT
	elif angle >= 202.5 && angle < 247.5:
		return Vector2(-1, -1)
	elif angle >= 247.5 && angle < 292.5:
		return Vector2.UP
	elif angle >= 292.5 && angle < 337.5:
		return Vector2(1, -1)
	else:
		return Vector2.RIGHT


func _on_air_state_physics_processing(_delta):
	if platform.is_falling():
		_state_chart.send_event("fall")
	has_dash_and_send_event()

# 处理下落的动作
func _on_fall_state_physics_processing(delta):
	var horizontal_direction = _fixed_direction(direction())
	animated_sprite.play("downwards")
	# 在空中可以改变方向
	platform.accelerate_horizontally(horizontal_direction, delta)

	if is_on_floor():
		_state_chart.send_event("floor")
		_enter_ground()
	elif is_on_wall():
		if Input.is_action_pressed("climb"):
			_state_chart.send_event("wallClimb")
		elif horizontal_direction == -get_wall_normal():
			_state_chart.send_event("wallSlide")
		elif Input.is_action_pressed("jump"):
			_state_chart.send_event("wallJump")
	


func _on_run_state_physics_processing(_delta):
	animated_sprite.play("run")
	run_dust.emitting = true
	if not action_player.stream == run_audio_stream:
		action_player.stream = run_audio_stream;
	if not action_player.playing:
		action_player.play()

func _on_idle_state_physics_processing(_delta):
	animated_sprite.play()
	

func _on_ground_state_physics_processing(delta):
	platform.reset_jump_queue()
	_reset_dash()
	var horizontal_direction = direction()
	if !horizontal_direction.is_zero_approx():
		_state_chart.send_event("move")
	if horizontal_direction.is_zero_approx():
		if platform.velocity.x == 0.0:
			_state_chart.send_event("stop")
		platform.decelerate_horizontally(delta, true)
	else:
		platform.accelerate_horizontally(horizontal_direction, delta)
	if Input.is_action_just_pressed("jump") && platform.can_jump():
		_state_chart.send_event("jump")
	if platform.is_falling():
		_state_chart.send_event("fall")
	has_dash_and_send_event()

func has_dash_and_send_event():
	var dashed = Input.is_action_just_pressed("dash")
	if dashed:
		_state_chart.send_event("dash")

func _on_dash_state_physics_processing(delta):
	if platform.can_dash():
		var eight_dir = _fixed_direction(all_direction(Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT));
		platform.dash(eight_dir)
		platform.apply_air_friction_horizontal()\
			.apply_air_friction_vertical()
		# shake_camera.shake()
		platform.times_can_dash = 0
		# 当 dash 耗尽时，改变 sprite 的颜色
		animated_sprite.modulate = Color.from_string("3aefffa8", Color.BLUE)
	if platform.is_dashing:		
		animated_sprite.play("dash")
		# 展示 dash 特效
		if animated_sprite.is_playing():
			dash_animation_time += 1
			if dash_animation_time in [1,3,6,9]:
				dash_effect()
	else:
		dash_animation_time = 0
		# 防止dash结束后的滑动
		if is_on_floor():
			platform.velocity.x = 0
			_state_chart.send_event("floor")
		else:
			platform.velocity.y = 0
			platform.decelerate_horizontally(delta, true)
			_state_chart.send_event("leaveFloor")


func _on_wall_jump_state_physics_processing(_delta):
	if Input.is_action_pressed("jump") and platform.can_wall_jump():
		animationPlayer.play("jump_start")
		platform.wall_jump(Vector2.ZERO, wall_jump_height)
	if is_on_floor():
		_state_chart.send_event("floor")

# 进入 jump 状态时触发的操作
func _on_jump_state_entered():
	animationPlayer.play("jump_start")
	platform.jump()
	
func _on_wall_state_physics_processing(_delta):
	if Input.is_action_just_pressed("jump"):
		_state_chart.send_event("wallJump")
		return
	if is_on_floor():
		_state_chart.send_event("floor")
	elif not is_on_wall():	
		_reset_wall_state()
		_state_chart.send_event("leaveFloor")

# 处理 wall sliding 状态
func _on_wall_slide_state_physics_processing(_delta):
	if Input.is_action_just_pressed("climb"):
		_state_chart.send_event("wallClimb")
		return
	var horizontal_direction = direction()
	if platform.can_wall_slide() and _fixed_direction(horizontal_direction) == - get_wall_normal():
		animated_sprite.flip_h = horizontal_direction < Vector2.ZERO
		if animated_sprite.flip_h:
			animated_sprite.offset.x = 10
		else:
			animated_sprite.offset.x = -5
		animated_sprite.play("wall_slide")
		platform.wall_slide()
	else:
		_reset_wall_state()
		_state_chart.send_event("leaveFloor")

# 处理 wall climb 状态
func _on_wall_climb_state_physics_processing(_delta):
	if Input.is_action_pressed("climb") and platform.can_wall_climb():
		var dir = _fixed_direction(all_direction())
		animated_sprite.flip_h = get_wall_normal() > Vector2.ZERO
		if not animated_sprite.flip_h:
			animated_sprite.offset.x = 5
		else:
			animated_sprite.offset.x = 0
		animated_sprite.play("wall_climb")
		platform.wall_climb(dir)
	else:
		_reset_wall_state()
		_state_chart.send_event("leaveFloor")

func _reset_wall_state():
	platform.is_wall_climbing = false
	platform.is_wall_sliding = false


# 触发player死亡
func _on_hurt_box_area_entered(_area):
	_reset_dash()
	_state_chart.send_event("death")

# 随机选择idle状态下的动画
func _on_idle_state_entered():
	animated_sprite.animation = ["idle","idle-1","idle-2"].pick_random()

# 在death动画播放完成后，发送 playe_dead 信号
func _on_animated_sprite_2d_animation_finished():
	if "death" == animated_sprite.animation:
		player_dead.emit()


func _on_death_state_physics_processing(_delta):
	pass

# 处理 death 状态
func _on_death_state_entered():
	platform.gravity_enabled = false
	platform.velocity = Vector2.ZERO
	animated_sprite.play("death")
	action_player.stream = death_audio_stream
	action_player.play()

# 触发转换镜头，给一个向上的速度，帮助player移动
func _on_transition_box_area_entered(_area):
	platform.velocity.y -= 100

# 触发对冲刺操作重新充能
func _on_re_dash_box_area_entered(_area):
	_reset_dash()
	action_player.stream = redash_audio_stream
	action_player.play()

func _reset_dash(): 
	platform.times_can_dash = 1
	animated_sprite.modulate = Color.WHITE


func _enter_ground():
	action_player.stream = down_audio_stream
	action_player.play()


func _on_wall_state_exited():
	animated_sprite.offset.x = 0

# 退出 run 状态后，停止释放 run_dust 粒子特效
func _on_run_state_exited():
	run_dust.emitting = false
