extends TextureRect
class_name Bubble, "res://Sprites/Bubbles/0/full.png"

const speed = 840

var explosion = load("res://Prefabs/Explosion.tscn")

var blind_chain: Array = []

var color_index: int = round(rand_range(0, 5))
var type: int = 0
var new_row_mult: int
var remove_floating: bool

var is_in_chain := false
var lock_removed := false
var is_moving := false
var is_queued := false
var is_in_cluster := false
var just_appeared := true
var is_being_destroyed := false
var is_blind := false
var to_bomb := false

var target_position = Vector2.ZERO setget target_position_set, target_position_get
var velocity = Vector2.ZERO
var destroy_delay := 0.0

onready var tween: Tween = $Tween
onready var field := $"../.."

signal shot_ended

func _ready():
	randomize()
	set_colors(Globals.themes[Globals.current_theme])
	set_decorations(Globals.decorations[Globals.current_decos])
	# setting the gimmick texture and some other stuff
	match type:
		1: $Sprite.texture = field.bomb_tex
		2: $Sprite.texture = field.lock_tex
		3: $Sprite.texture = field.coin_tex
		4: $Sprite.texture = field.gem_tex
		5:
			$Sprite.texture = field.eye_tex
			if Globals.current_decos <= 1:
				$BlindMask.rect_scale = Vector2(0.75, 0.75)
			else:
				$BlindMask.texture = texture
			field.connect("shot_ended", self, "add_blind")
		6:
			$Sprite.texture = field.timer_tex
			$TProgress.value = 30
	var difficulty = field.difficulty
	new_row_mult = 10 if difficulty == 0 or difficulty == 2 else 7 if difficulty == 1 else 5
	remove_floating = difficulty <= 1
	$Sound.volume_db = log(Globals.volume) * 20


func set_decorations(decorations: BubbleDecorations):
	match color_index:
		0: texture = decorations.red_bubble
		1: texture = decorations.orange_bubble
		2: texture = decorations.yellow_bubble
		3: texture = decorations.green_bubble
		4: texture = decorations.lblue_bubble
		5: texture = decorations.blue_bubble


func set_colors(theme: GameTheme):
	material = field.bubble_materials[color_index]
	$BlindMask.material.set("shader_param/color_to", theme.blind_bubble_color)


func _process(delta) -> void:
	if type == 6:
		$TProgress.value -= delta
		if $TProgress.value <= 0 and not is_being_destroyed:
			explode_timer()


func _physics_process(delta) -> void:
	# resetting variables
	is_in_chain = false
	is_in_cluster = false
	just_appeared = false
	if lock_removed:
		type = 0
		lock_removed = false
	
	if is_moving:
		# hitting walls
		if rect_position.x <= 16 or rect_position.x >= 644:
			velocity = Vector2(-velocity.x, velocity.y)
		
		# hitting the ceiling
		if rect_position.y <= 224:
			is_moving = false; velocity = Vector2.ZERO
			var curr_x: int = round(rect_position.x)
			var start = 24 if field.first_row_is_wide else 58
			var closest_x = closest_number(curr_x - start, 68) + start
			if closest_x < start: closest_x += 68
			elif closest_x > 720 - start: closest_x -= 68
			var closest = Vector2(closest_x, 224)
			tween.interpolate_property(self, "rect_position", rect_position, closest, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()
			target_position = closest
			end_shot()
			return
		
		# checking for other bubbles to be hit
		var areas = $Area2D.get_overlapping_areas()
		if areas.size() > 0:
			var bubble: Bubble
			for area in areas:
				var candidate: Bubble = area.get_parent()
				if not candidate.is_queued and not candidate.is_being_destroyed:
					bubble = candidate; break
			if bubble != null:
				var row: int = round((rect_position.y - 224) / 60)
				var row_is_wide = (row % 2 == 0) == field.first_row_is_wide
				var row_start = 24 if row_is_wide else 58
				var curr_x = round(rect_position.x)
				var closest_x = closest_number(curr_x - row_start, 68) + row_start
				if closest_x < row_start: closest_x += 68
				elif closest_x > 720 - row_start: closest_x -= 68
				is_moving = false; velocity = Vector2.ZERO
				var closest = Vector2(closest_x, 224 + row * 60)
				tween.interpolate_property(self, "rect_position", rect_position, closest, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				tween.start()
				target_position = closest
				end_shot()
				return
		# if nothing happened then just move
		rect_position += velocity * delta * speed
	# checking if the game should be over
	elif rect_position.y >= 1064 and not is_queued and not field.is_game_over: field.end_game()


func end_shot():
	is_queued = false
	$Bubblefly.stop()
	field.shots += 1
	if field.shots % new_row_mult == 0:
		field.add_row()
	check_combo()
	if Globals.combo.size() >= 3:
		field.add_points(Globals.combo.size() - 2)
		remove_combo()
		if remove_floating:
			remove_floating_clusters()
	Globals.combo.clear()
	if Globals.show_wallet:
		field.show_wallet()
		Globals.show_wallet = false
	emit_signal("shot_ended")


func check_combo(delay: float = 0):
	Globals.combo.append(self)
	is_in_chain = true
	destroy_delay = delay
	for bubble in get_parent().get_children():
		if bubble.is_in_chain or bubble.is_being_destroyed:
			continue
		if bubble_is_close(bubble.target_position_get()):
			if bubble.get_class() == "MultiColorBubble":
				if bubble.color_index_left == color_index or bubble.color_index_right == color_index:
					bubble.check_combo(delay + 0.1)
			elif bubble.color_index == color_index:
				bubble.check_combo(delay + 0.1)


func check_bomb(delay: float = 0) -> int:
	var chance = rand_range(0.0, 1.0)
	var rad := 1 if chance < Globals.get_upgrade_level(0) and Globals.difficulty > 0 else 0
	var expl: Explosion = explosion.instance()
	var colors := 0
	field.get_node("Explosions").add_child(expl)
	expl.get_node("Sprite").self_modulate = Globals.get_current_theme().bubble_colors[color_index]
	expl.rect_position = .get_position()
	expl.explode(delay, rad)
	field.add_points(2)
	for bubble in get_parent().get_children():
		if bubble_is_close(bubble.target_position_get(), rad):
			if bubble.is_in_chain or bubble.is_being_destroyed:
				continue
			bubble.is_in_chain = true
			if bubble.type == 1:
				bubble.check_bomb(delay + 0.1)
			bubble.destroy_delay = delay
			bubble.remove()
			if bubble.type != 1:
				bubble.get_node("Sound").stream = null
			colors = colors | 1 << bubble.color_index
			if bubble.get_class() == "MultiColorBubble":
				colors = colors | 1 << bubble.color_index_right
	return colors


func remove_lock(delay: float = 0):
	$Sound.stream = field.lock_sound
	$SoundTimer.start(delay + rand_range(-0.01, 0.025))
	tween.interpolate_property($Sprite, "scale", Vector2.ONE, Vector2.ZERO, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	tween.start()
	field.add_points(1)
	is_in_chain = true
	lock_removed = true


func remove_combo():
	var colors := 0
	Globals.check_combo_size()
	for bubble in Globals.combo:
		if bubble.type == 1: colors = colors | bubble.check_bomb(bubble.destroy_delay)
		bubble.remove()
		colors = colors | 1 << bubble.color_index
		if bubble.get_class() == "MultiColorBubble":
			colors = colors | 1 << bubble.color_index_right
	if colors == 63:
		Globals.unlock_achievement(9)


func remove():
	if type == 2 and not lock_removed:
		remove_lock(destroy_delay)
	else:
		force_remove()


func force_remove():
	is_being_destroyed = true
	match type:
		0:
			$Sound.stream = field.pop_sound
		1:
			$Sound.stream = field.bomb_sound
		3:
			Globals.show_wallet = true
			Globals.coins += round(rand_range(1, 5))
			$Sound.stream = field.coin_sound
		4:
			Globals.show_wallet = true
			Globals.gems += 1
			$Sound.stream = field.gem_sound
		5:
			field.disconnect("shot_ended", self, "add_blind")
			remove_blind_chain(destroy_delay)
			$Sound.stream = field.eye_sound
			# Achievement "Eye candy"
			Globals.unlock_achievement(3)
		6:
			# Achievement "Hurry up!"
			Globals.unlock_achievement(7)
	tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ZERO, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, destroy_delay)
	tween.start()
	$Timer.start(destroy_delay + 0.3)
	$SoundTimer.start(destroy_delay + rand_range(-0.01, 0.025))


func find_cluster():
	is_in_cluster = true
	var cluster := [self]
	for bubble in get_parent().get_children():
		if bubble.is_in_cluster or (bubble.is_in_chain and not bubble.lock_removed) or bubble.is_queued or bubble.is_being_destroyed: continue
		if bubble_is_close(bubble.target_position_get()):
			cluster.append(bubble)
			cluster += bubble.find_cluster()
	return cluster


func remove_floating_clusters():
	for bubble in get_parent().get_children():
		if bubble.is_in_cluster or (bubble.is_in_chain and not bubble.lock_removed) or bubble.is_queued or bubble.is_being_destroyed: continue
		var cluster = bubble.find_cluster()
		var is_floating = true
		for b in cluster:
			if b.target_position_get().y == 224:
				is_floating = false
		if is_floating:
			for b in cluster:
				b.destroy_delay = Globals.combo.size() * 0.1 + 0.1
				field.add_points(1)
				b.force_remove()


func add_blind():
	if is_being_destroyed or just_appeared: return
	var chance = rand_range(0.0, 1.0)
	if chance < Globals.get_upgrade_value(1) and Globals.difficulty > 0: return
	if blind_chain.size() == 0:
		blind_chain.append(self)
		make_blind()
		return
	
	var indecies: Array = []
	for i in range(blind_chain.size()):
		if blind_chain[i] != null:
			if blind_chain[i].is_being_destroyed: indecies.append(i)
	for i in range(indecies.size()):
		blind_chain.remove(indecies[i] - i)
	
	var found: bool = false
	var ix = -1
	while not found:
		if ix < -blind_chain.size(): break
		var last = blind_chain[ix]
		var candidates: Array = []
		for bubble in get_parent().get_children():
			if bubble.is_blind or bubble.is_queued or bubble.is_in_chain or bubble.is_being_destroyed: continue
			if last.bubble_is_close(bubble.target_position_get()):
				candidates.append(bubble)
		if candidates.size() == 0:
			ix -= 1
			continue
		var id = round(rand_range(0, candidates.size() - 1))
		blind_chain.append(candidates[id])
		candidates[id].make_blind()
		found = true


func remove_blind_chain(delay: float):
	for i in range(blind_chain.size()):
		if blind_chain[i] == null: continue
		blind_chain[i].make_not_blind(delay + i * 0.05)


func make_blind():
	is_blind = true
	$Sound.stream = field.closed_sound
	$SoundTimer.start(rand_range(0, 0.05))
	tween.interpolate_property($BlindMask.material, "shader_param/time", 1.0, -0.01, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func make_not_blind(delay: float):
	is_blind = false
	self_modulate = Color.white
	$Sound.stream = field.opened_sound
	$SoundTimer.start(delay + rand_range(0, 0.05))
	tween.interpolate_property($BlindMask.material, "shader_param/time", 0.0, 1.0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	tween.start()


func explode_timer():
	var expl: Explosion = explosion.instance()
	field.get_node("Explosions").add_child(expl)
	expl.get_node("Sprite").self_modulate = Globals.get_current_theme().bubble_colors[color_index]
	expl.rect_position = .get_position()
	expl.explode(0)
	$Sound.stream = field.timer_sound
	$SoundTimer.start(rand_range(0, 0.05))
	randomize()
	var chance = rand_range(0.0, 1.0)
	if chance < Globals.get_upgrade_value(2):
		change_to_bomb()
	else:
		change_to_lock()
	for bubble in get_parent().get_children():
		if bubble.is_queued or bubble.is_in_chain or bubble.is_being_destroyed: continue
		if bubble_is_close(bubble.target_position):
			chance = rand_range(0.0, 1.0)
			if chance < Globals.get_upgrade_value(2) and Globals.difficulty > 0:
				bubble.change_to_bomb()
			else:
				bubble.change_to_lock()
	pass


func change_to_lock():
	if type == 2 or type == 5: return
	elif type == 0:
		tween.interpolate_property($Sprite, "scale", Vector2.ZERO, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Sprite.texture = field.lock_tex
	else:
		tween.interpolate_property($Sprite, "scale", Vector2.ONE, Vector2.ZERO, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property($Sprite, "scale", Vector2.ZERO, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		$LockTimer.start()
	type = 2
	tween.start()


func change_to_bomb():
	if type == 1 or type == 5: return
	elif type == 0:
		tween.interpolate_property($Sprite, "scale", Vector2.ZERO, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Sprite.texture = field.bomb_tex
	else:
		tween.interpolate_property($Sprite, "scale", Vector2.ONE, Vector2.ZERO, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property($Sprite, "scale", Vector2.ZERO, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		$LockTimer.start()
	type = 1
	to_bomb = true
	tween.start()


func target_position_set(value: Vector2): target_position = value
func target_position_get(): return target_position if target_position != Vector2.ZERO else .get_position()


func bubble_is_close(bubble_pos: Vector2, rad: int = 0) -> bool:
	var diff_x: int = abs(bubble_pos.x - target_position_get().x)
	var diff_y: int = abs(bubble_pos.y - target_position_get().y)
	if rad == 0:
		return diff_x <= 70 and diff_y <= 62
	return (diff_x <= 70 + 68 * rad and diff_y <= 62 + 60 * rad) and not (diff_x == 68 * (rad + 1) and diff_y == 60 * (rad + 1))


func closest_number(n: int, m: int) -> int:
	var q = n / m; var n1 = m * q
	var n2 = m * (q + 1) if n * m > 0 else m * (q - 1)
	return n1 if abs(n - n1) < abs(n - n2) else n2


func _on_SoundTimer_timeout():
	$Sound.pitch_scale = rand_range(0.75, 1.25)
	$Sound.volume_db = log(Globals.volume) * 20
	$Sound.play()


func _on_LockTimer_timeout():
	$Sprite.texture = field.bomb_tex if to_bomb else field.lock_tex


func start_bubblefly():
	print("started oof")
	$Bubblefly.start(7)

func _on_Bubblefly_timeout() -> void:
	Globals.unlock_achievement(8)


func set_children_process(process: bool) -> void:
	$Timer.paused = not process
	$SoundTimer.paused = not process
	$LockTimer.paused = not process
	$Bubblefly.paused = not process
	$Tween.set_process(process)
