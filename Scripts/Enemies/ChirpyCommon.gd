# Copyright 2026 CE-Studio: AGPL-3.0-only
# Original code Copyright 2011 Auriplane, used with permission
class_name ChirpyCommon
extends Enemy


#region Variables
const SIN_ACCEL = 700
const MAX_OFF_SCREEN_TIME = 3.0

var velocity:Vector2 = Vector2.ZERO
var theta:float = 0.0
var theta_mult:float = 5.0
var fly_speed:float = 140.0
var fly_amplitude:float = 40.0
var going_up:bool = true
var facing_left:bool = false
var taken_off:bool = false
var off_screen_time:float = 0.0
var target_altitude:float = 0.0

@export var sfx_chirp:AudioStreamPlayer
#endregion


func _ready() -> void:
	my_type = EnemyTypes.CHIRPY
	super.spawn()
	
	theta = position.x * position.x * 13.7
	theta_mult += sin(position.x * 1.732 - position.y * 3.2)
	fly_speed += sin(position.x * 2.332 - position.y * 1.9) * 10.0
	fly_amplitude += sin(position.x * 7.3 + position.y) * 5.0
	target_altitude = origin.y
	
	if display_mode:
		taken_off = true
		facing_left = randf() < 0.5
		fly_amplitude = 16.0


func _process(delta: float) -> void:
	super(delta)
	if not ai_active and not display_mode:
		return
	
	if vis.is_on_screen() and not taken_off:
		get_going()
	
	if taken_off:
		theta += delta
		position += velocity * delta
		position.y = target_altitude + sin(theta * theta_mult) * fly_amplitude
		var player_pos = GameCore.instance.player.position
		if player_pos.y > target_altitude:
			target_altitude += 35 * delta
		elif player_pos.y < target_altitude:
			target_altitude -= 35 * delta
		if position.y > target_altitude and not going_up:
			going_up = true
			_play_anim(true)
		elif position.y < target_altitude and going_up:
			going_up = false
			_play_anim(false)
		if display_mode:
			return
		if vis.is_on_screen():
			off_screen_time = 0
		else:
			off_screen_time += delta
			if off_screen_time >= MAX_OFF_SCREEN_TIME:
				queue_free()


func get_going() -> void:
	if taken_off:
		return
	taken_off = true
	sfx_chirp.play()
	facing_left = GameCore.instance.player.position.x < position.x
	velocity.x = fly_speed * (-1.0 if facing_left else 1.0)
	_play_anim(going_up)


func _play_anim(up:bool) -> void:
	var v:String = "up_" if up else "down_"
	var h:String = "left" if facing_left else "right"
	sprite.play(v + h)
	sprite.flip_h = not facing_left
