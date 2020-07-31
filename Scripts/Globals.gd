extends Node

const save_path = "user://owowhatsthis.stuff"
#                          New starts            Big chain             Bigger chain          Eye candy             Higher and higher!    The void              Like a boss           Hurry up!             Bubblefly             Caulibubble
const achievements_ids := ["CgkImsqr5KoCEAIQAQ", "CgkImsqr5KoCEAIQAg", "CgkImsqr5KoCEAIQAw", "CgkImsqr5KoCEAIQBA", "CgkImsqr5KoCEAIQBQ", "CgkImsqr5KoCEAIQCg", "CgkImsqr5KoCEAIQCw", "CgkImsqr5KoCEAIQDA", "CgkImsqr5KoCEAIQDQ", "CgkImsqr5KoCEAIQDg"]
#                          Easy                  Normal                Medium                Hard
const leaderboards_ids := ["CgkImsqr5KoCEAIQAA", "CgkImsqr5KoCEAIQBw", "CgkImsqr5KoCEAIQCA", "CgkImsqr5KoCEAIQCQ"]
const hidden_achievements := 376
const combo := []

var show_wallet := false
var field_is_focused := false
var light_mask := 2

var volume := 1.0
var first_play := true
var high_scores := [0, 0, 0, 0]
var difficulty := 2
var coins := 0
var gems := 0

var purchased_themes := [true, false, false, false, false, false]
var purchased_decos := [true, false, false, false, false, false]
var purchased_backgs := [true, false, false, false, false, false, false]

var upgrade_levels := [0, 0, 0]

var current_theme := 0
var current_decos := 0
var current_backg := 0

var hs_streak := 0

export (Array, Texture) var currency_textures: Array
export (Array, Texture) var currency_textures_large: Array
export (Array, Resource) var themes: Array
export (Array, Resource) var decorations: Array
export (Array, Resource) var backgrounds: Array
export (Array, Resource) var upgrades: Array

func _init() -> void:
	load_game()


func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()


func save() -> Dictionary:
	return {
		"volume" : volume,
		"first_play" : first_play,
		"high_scores" : high_scores,
		"difficulty" : difficulty,
		"coins" : coins,
		"gems" : gems,
		"purchased_themes" : purchased_themes,
		"purchased_decos" : purchased_decos,
		"purchased_backgs" : purchased_backgs,
		"upgrade_levels" : upgrade_levels,
		"current_theme" : current_theme,
		"current_decos" : current_decos,
		"current_backg" : current_backg,
	}


func save_game() -> void:
	var save_game = File.new()
	save_game.open_encrypted_with_pass(save_path, File.WRITE, OS.get_unique_id())
	save_game.store_line(to_json(save()))
	save_game.close()


func load_game() -> void:
	var save_game = File.new()
	if not save_game.file_exists(save_path):
		return
	
	save_game.open_encrypted_with_pass(save_path, File.READ, OS.get_unique_id())
	var line: Dictionary = parse_json(save_game.get_line())
	
	if line.has("volume"): volume = line["volume"]
	if line.has("first_play"): first_play = line["first_play"]
	if line.has("high_scores"): high_scores = line["high_scores"]
	if line.has("difficulty"): difficulty = line["difficulty"]
	if line.has("coins"): coins = line["coins"]
	if line.has("gems"): gems = line["gems"]
	
	if line.has("purchased_themes"):
		var obj = line["purchased_themes"]
		if not obj is Array:
			obj = obj as int
			var i := 0
			while obj >= 1:
				purchased_themes[i] = (obj >> i) % 2 == 1
				i += 1
				obj /= 2
		else:
			purchased_themes = obj
	
	if line.has("purchased_decos"):
		var obj = line["purchased_decos"]
		if not obj is Array:
			obj = obj as int
			var i := 0
			while obj >= 1:
				purchased_decos[i] = (obj >> i) % 2 == 1
				i += 1
				obj /= 2
		else:
			purchased_decos = obj
	
	if line.has("purchased_backgs"):
		var obj = line["purchased_backgs"]
		if not obj is Array:
			obj = obj as int
			var i := 0
			while obj >= 1:
				purchased_backgs[i] = (obj >> i) % 2 == 1
				i += 1
				obj /= 2
		else:
			purchased_backgs = obj
			
	if line.has("upgrade_levels"): upgrade_levels = line["upgrade_levels"]
	if line.has("current_theme"): current_theme = line["current_theme"]
	if line.has("current_decos"): current_decos = line["current_decos"]
	if line.has("current_backg"): current_backg = line["current_backg"]
	
	save_game.close()
	if volume > 1: volume = 1
	elif volume < 0.0001: volume = 0.0001


func add_item(type: int, id: int) -> void:
	match type:
		0: purchased_themes[id] = true
		1: purchased_decos[id] = true
		2: purchased_backgs[id] = true
	save_game()


func has_item(type: int, id: int) -> bool:
	match type:
		0: return purchased_themes[id]
		1: return purchased_decos[id]
		2: return purchased_backgs[id]
	return false


func get_upgrade_level(id: int) -> int:
	if id >= upgrade_levels.size():
		return 0
	return upgrade_levels[id]


func increment_upgrade(id: int) -> void:
	upgrade_levels[id] += 1
	if upgrade_levels[id] == 4:
		# Achievement "Like a boss"
		unlock_achievement(6)


func get_upgrade_description(id: int) -> String:
	if get_upgrade_cost(id) == -1:
		return String(get_upgrade_value(id) * 100) + "% " + upgrades[id].description
	return String(get_upgrade_value(id) * 100) + "% -> " + String(upgrades[id].values[upgrade_levels[id] + 1] * 100) + "% " + upgrades[id].description


func get_upgrade_currency(id: int) -> int:
	return upgrades[id].currencies[upgrade_levels[id]] if upgrades[id].currencies.size() > upgrade_levels[id] else -1


func get_upgrade_cost(id: int) -> int:
	return upgrades[id].costs[upgrade_levels[id]] if upgrades[id].costs.size() > upgrade_levels[id] else -1


func get_upgrade_value(id: int) -> float:
	return upgrades[id].values[upgrade_levels[id]]


func unlock_achievement(id: int) -> void:
	if difficulty == 0: return
	if achievement_is_hidden(id):
		GPGS.reveal_achievement(achievements_ids[id])
	GPGS.unlock_achievement(achievements_ids[id])
	print("Achievement id %d unlocked" % id)


func achievement_is_hidden(id: int) -> bool:
	return (hidden_achievements >> id) % 2 == 1


func set_new_high(score: int) -> bool:
	if score > high_scores[difficulty - 1] and difficulty != 0:
		high_scores[difficulty - 1] = score
		submit_leaderboard(score)
		hs_streak += 1
		if hs_streak == 3:
			# Achievement "Higher and higher!"
			unlock_achievement(4)
		return true
	else:
		hs_streak = 0
		return false


func check_combo_size() -> void:
	if combo.size() >= 12:
		unlock_achievement(2)
	elif combo.size() >= 6:
		unlock_achievement(2)


func submit_leaderboard(score: int) -> void:
	GPGS.submit_leaderboard_score(leaderboards_ids[difficulty - 1], score)


func get_current_theme() -> GameTheme:
	return themes[current_theme] if current_theme < themes.size() else themes[0]


func get_current_decos() -> BubbleDecorations:
	return decorations[current_decos] if current_decos < decorations.size() else decorations[0]


func get_current_backg() -> Background:
	return backgrounds[current_backg] if current_backg < backgrounds.size() else backgrounds[0]
