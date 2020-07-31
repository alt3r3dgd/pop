extends TextureRect
class_name Field

export (Array, ShaderMaterial) var bubble_materials: Array
export (Texture) var bomb_tex
export (Texture) var lock_tex
export (Texture) var coin_tex
export (Texture) var gem_tex
export (Texture) var eye_tex
export (Texture) var timer_tex
export (AudioStream) var start_sound
export (AudioStream) var shoot_sound
export (AudioStream) var pop_sound
export (AudioStream) var bomb_sound
export (AudioStream) var lock_sound
export (AudioStream) var coin_sound
export (AudioStream) var gem_sound
export (AudioStream) var eye_sound
export (AudioStream) var closed_sound
export (AudioStream) var opened_sound
export (AudioStream) var timer_sound

var node: PackedScene = load("res://Prefabs/Bubble.tscn")
var mc_node = load("res://Prefabs/MultiColorBubble.tscn")
var pointer_gradient: Gradient = load("res://Resources/PointerGradient.tres")
var difficulty := Globals.difficulty

var moving: Bubble
var queued_1: Bubble
var queued_2: Bubble
var queued_3: Bubble
var queued_4: Bubble

var started := false
var is_cooldown := false
var first_row_is_wide := true
var is_game_over := false setget ,get_is_game_over
var pointer_is_shown := false

var bomb_chance := 1 - 0.1 * difficulty
var lock_chance := bomb_chance + 0.5 + 0.1 * difficulty
var coin_chance := lock_chance + 0.5
var gem_chance := coin_chance + 0.3
var blind_chance := gem_chance + 0.05 * difficulty
var timer_chance := blind_chance + 0.075 * difficulty
var mc_chance := 0.6

var score := 0
var target_score := 0
var shots := 0
var moving_count := 0

onready var pointer: Line2D = $c/Pointer
onready var tween: Tween = $Tween

signal shot_ended
signal game_over

func get_is_game_over() -> bool:
	return is_game_over


func _ready():
	if difficulty == 0:
		coin_chance = 0
		gem_chance = 0
		mc_chance = 0
		$Score.visible = false
	rect_pivot_offset = rect_size * 0.5
	set_game_theme(Globals.get_current_theme())
	$Sound.volume_db = log(Globals.volume) * 20
	$Sound.play()
	
	for i in range(5):
		for j in range(10 if i % 2 == 0 else 9):
# warning-ignore:return_value_discarded
			init_bubble(Vector2((24 if i % 2 == 0 else 58) + 68 * j, 224 + 60 * i), 1, 0.05 * (i + j))
	queued_1 = init_bubble(Vector2(330, 1205), 1, 0, 1, true)
	queued_2 = init_bubble(Vector2(400, 1205), 0.8, 0, 0.75, true)
	queued_3 = init_bubble(Vector2(456, 1205), 8.0 / 15, 0, 0.5, true)
	queued_4 = init_bubble(Vector2(496, 1205), 4.0 / 15, 0, 0.5, true)
	AdMob.load_interstitial()
	
	if Globals.first_play:
		var tutorial_scene = load("res://Scenes/TutorialPopup.tscn")
		var tutorial = tutorial_scene.instance()
		Globals.field_is_focused = false
		add_child(tutorial)
		tutorial.connect("exited", self, "_on_Tutorial_exited")


func _process(_delta):
	if pointer_is_shown:
		set_pointer(get_viewport().get_mouse_position() - $Bubbles.rect_position)
	if $Bubbles.get_child_count() == 4:
		# Achievement "The void"
		Globals.unlock_achievement(5)


func set_game_theme(theme: GameTheme):
	self_modulate = theme.bounds_color
	$TextureRect.self_modulate = theme.bounds_color
	$TextureRect2.self_modulate = theme.bounds_color
	$Score.set("custom_colors/font_color", theme.paragraph_color)
	$BorderLine.self_modulate = theme.borderline_color
	$PanelContainer.get_stylebox("panel").set("bg_color", theme.bg_color)
	$PanelContainer/Wallet/Coins.set("custom_colors/font_color", theme.header_color)
	$PanelContainer/Wallet/Gems.set("custom_colors/font_color", theme.header_color)
	$PauseButton.self_modulate = theme.paragraph_color
	for i in range(6):
		bubble_materials[i].set("shader_param/color_from", theme.bubble_colors[i])
		bubble_materials[i].set("shader_param/color_to", theme.bubble_front_colors[i])


func init_bubble(position: Vector2, scale: float, delay: float = 0, alpha: float = 1, queued = false) -> Bubble:
	var chance = rand_range(0, 10) if difficulty < 4 else 11.0
	var bubble: Bubble
	if chance <= mc_chance:
		bubble = mc_node.instance()
		var color = bubble.modulate; color.a = alpha
		bubble.modulate = color
	else:
		bubble = node.instance()
		var color = bubble.self_modulate; color.a = alpha
		bubble.self_modulate = color
	
	if not queued:
		randomize()
		var type_chance := rand_range(0, 10)
		if type_chance <= bomb_chance: bubble.type = 1
		elif type_chance <= lock_chance: bubble.type = 2
		elif type_chance <= coin_chance: bubble.type = 3
		elif type_chance <= gem_chance: bubble.type = 4
		elif type_chance <= blind_chance: bubble.type = 5
		elif type_chance <= timer_chance: bubble.type = 6
	
	$Bubbles.add_child(bubble)
	bubble.rect_position = position
	bubble.rect_scale = Vector2.ZERO
	bubble.is_queued = queued
	bubble.connect("shot_ended", self, "end_shot")
	tween.interpolate_property(bubble, "rect_scale", bubble.rect_scale, Vector2.ONE * scale,
		0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	tween.start()
	return bubble


func move_bubble(bubble: TextureRect, position: Vector2, scale: float, alpha: float = 1):
	tween.interpolate_property(bubble, "rect_position", bubble.rect_position, position, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(bubble, "rect_scale", bubble.rect_scale, Vector2.ONE * scale, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	if bubble.get_class() == "MultiColorBubble":
		var color = bubble.modulate; color.a = alpha
		tween.interpolate_property(bubble, "modulate", bubble.modulate, color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	else:
		var color = bubble.self_modulate; color.a = alpha
		tween.interpolate_property(bubble, "self_modulate", bubble.self_modulate, color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func _input(event: InputEvent):
	if not Globals.field_is_focused: return
	if started and event is InputEventScreenTouch:
		if event.pressed:
			if pointer_is_shown:
				return
			pointer_is_shown = true
			tween.interpolate_property(pointer, "modulate", Color.transparent, Color(1, 1, 1, 0.5), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()
			if queued_1 is MultiColorBubble:
				pointer_gradient.colors[0] = Globals.get_current_theme().bubble_colors[queued_1.color_index_left]
				pointer_gradient.colors[1] = Globals.get_current_theme().bubble_colors[queued_1.color_index_right]
				pointer.gradient = pointer_gradient
			else:
				pointer.default_color = Globals.get_current_theme().bubble_colors[queued_1.color_index]
				pointer.gradient = null
		else:
			if not pointer_is_shown:
				return
			pointer_is_shown = false
			tween.interpolate_property(pointer, "modulate", Color(1, 1, 1, 0.5), Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()
			shoot(event.position)
	else:
		started = true


func reset_cooldown():
	is_cooldown = false


func shoot(touch_pos: Vector2):
	if is_cooldown or moving_count >= 3: return
	$Sound.pitch_scale = rand_range(0.75, 1.25)
	$Sound.volume_db = log(Globals.volume) * 20
	$Sound.stream = shoot_sound
	$Sound.play()
	moving = queued_1; queued_1 = queued_2; queued_2 = queued_3; queued_3 = queued_4
	move_bubble(queued_1, Vector2(330, 1205), 1)
	move_bubble(queued_2, Vector2(400, 1205), 0.8, 0.75)
	move_bubble(queued_3, Vector2(456, 1205), 8.0 / 15, 0.5)
	queued_4 = init_bubble(Vector2(496, 1205), 4.0 / 15, 0, 0.5, true)
	
	moving.is_moving = true
	moving.start_bubblefly()
	moving_count += 1
	var velocity: Vector2 = (touch_pos - Vector2(.get_size().x / 2, 195 + .get_size().y / 2)).normalized()
	if velocity.y >= -0.1:
		velocity.y = -0.1
		velocity = velocity.normalized()
	moving.velocity = velocity
	is_cooldown = true
	$Cooldown.start(0.2)


func add_points(points: int):
	target_score += points
	$Counter.start(0.1)


func set_pointer(mouse_pos: Vector2):
	var delta_pos := mouse_pos - Vector2(360, 1035)
	if delta_pos.x == 0:
		delta_pos = Vector2(0, -2000)
	else:
		if delta_pos.y >= -33 * abs(delta_pos.x) / 320:
			delta_pos.y = -33
		else:
			delta_pos.y = delta_pos.y / abs(delta_pos.x) * 320
		delta_pos.x = -320 if delta_pos.x < 0 else 320
	if delta_pos.y < -985:
		delta_pos.x = delta_pos.x / delta_pos.y * -985
		delta_pos.y = -985
		pointer.set_point_position(1, delta_pos + Vector2(360, 1235))
		if pointer.get_point_count() == 3:
			pointer.remove_point(2)
		return
	pointer.set_point_position(1, delta_pos + Vector2(360, 1235))
	if pointer.get_point_count() == 2:
		pointer.add_point(Vector2.ZERO)
	var first_point := delta_pos
	if delta_pos.x != 0:
		delta_pos.y *= 3
		delta_pos.x *= -1
	if delta_pos.y < -985:
		delta_pos.x = delta_pos.x / (delta_pos.y - first_point.y) * (-985 - first_point.y) * 2 - (320 * sign(delta_pos.x))
		delta_pos.y = -985
	pointer.set_point_position(2, delta_pos + Vector2(360, 1235))


func add_point():
	if score < target_score:
		score += 1
		$Score.text = str(score)
		$Counter.start(0.05)


func add_row():
	first_row_is_wide = not first_row_is_wide
	for bubble in $Bubbles.get_children():
		if not bubble.is_queued:
			bubble.target_position += Vector2.DOWN * 60
			bubble.get_node("Tween").stop_all()
			tween.interpolate_property(bubble, "rect_position", bubble.rect_position, bubble.target_position, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	for i in range(10 if first_row_is_wide else 9):
# warning-ignore:return_value_discarded
		init_bubble(Vector2((24 if first_row_is_wide else 58) + 68 * i, 224), 1, 0.1)


func show_wallet():
	$PanelContainer/Wallet/Coins.text = str(Globals.coins)
	$PanelContainer/Wallet/Gems.text = str(Globals.gems)
	tween.interpolate_property($PanelContainer, "rect_position", Vector2($PanelContainer.rect_position.x, 216), Vector2($PanelContainer.rect_position.x, 232), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property($PanelContainer, "rect_position", Vector2($PanelContainer.rect_position.x, 232), Vector2($PanelContainer.rect_position.x, 216), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN, 2)
	tween.interpolate_property($PanelContainer, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property($PanelContainer, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN, 2)
	tween.start()


func end_shot():
	moving_count -= 1
	emit_signal("shot_ended")
	Globals.save_game()


func end_game():
	if AdMob._is_interstitial_loaded:
		AdMob.show_interstitial()
	emit_signal("game_over", score)
	is_game_over = true
	# Achievement "New starts"
	Globals.unlock_achievement(0)
	Globals.save_game()


func _on_PauseButton_pressed():
	Globals.field_is_focused = false
	var pause_scene = load("res://Scenes/PausePopup.tscn")
	var pause_popup = pause_scene.instance()
	pause_popup.connect("quit_pressed", get_parent(), "_on_Field_quit_pressed")
	add_child(pause_popup)
	get_tree().paused = true


func _on_PauseButton_button_down():
	Globals.field_is_focused = false
	pointer_is_shown = false
	tween.remove(pointer)
	pointer.modulate = Color.transparent


func _on_PauseButton_button_up():
	Globals.field_is_focused = true


func _on_Tutorial_exited():
	Globals.field_is_focused = true
	Globals.first_play = false


func update_bubble_decos():
	for bubble in $Bubbles.get_children():
		bubble.set_decorations(Globals.get_current_decos())
