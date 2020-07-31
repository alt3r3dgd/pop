extends Control
class_name Main

var field_scene: PackedScene = load("res://Scenes/Field.tscn")
var menu_scene: PackedScene = load("res://Scenes/MainMenu.tscn")
var game_over_scene: PackedScene = load("res://Scenes/GameOver.tscn")
var settings_scene: PackedScene = load("res://Scenes/Settings.tscn")
var shop_scene: PackedScene = load("res://Scenes/Shop.tscn")

var field: Field
var menu: MainMenu
var game_over: GameOver
var settings: Settings
var shop: Shop

var rounded_button_style: StyleBoxFlat = load("res://Resources/RoundedButton.tres")

var is_main_menu: bool
var is_quit_menu: bool

onready var background: ColorRect = $Background
onready var bg_texture: TextureRect = $BgTexture
onready var tween: Tween = $Tween
onready var timer: Timer = $Timer

export (Array, ShaderMaterial) var bubble_materials

func _ready() -> void:
	GPGS.sign_in()
	load_menu()
	set_game_theme(Globals.get_current_theme())
	set_background(Globals.get_current_backg())
	AdMob.load_banner()


func load_menu() -> void:
	menu = menu_scene.instance()
	menu.connect("play_pressed", self, "_on_MenuMain_play_pressed")
	menu.connect("settings_pressed", self, "_on_MenuMain_settings_pressed")
	menu.connect("shop_pressed", self, "_on_MenuMain_shop_pressed")
	call_deferred("add_child", menu)
	is_main_menu = true


func load_field() -> void:
	field = field_scene.instance()
	call_deferred("add_child", field)
	AdMob.load_interstitial()
	Globals.field_is_focused = true


func load_game_over() -> void:
	game_over = game_over_scene.instance()
	call_deferred("add_child", game_over)
	if AdMob._is_interstitial_loaded:
		AdMob.load_interstitial()


func load_settings() -> void:
	settings = settings_scene.instance()
	call_deferred("add_child", settings)


func load_shop() -> void:
	shop = shop_scene.instance()
	call_deferred("add_child", shop)


func _on_MenuMain_play_pressed() -> void:
	if field == null:
		load_field()
		field.connect("game_over", self, "_on_Field_game_over")
	else:
		field.set_process(true)
		field.set_game_theme(Globals.get_current_theme())
		field.update_bubble_decos()
		for bubble in field.get_node("Bubbles").get_children():
			bubble.set_physics_process(true)
			bubble.set_process(true)
			bubble.set_children_process(true)
		Globals.field_is_focused = true
	make_transition(menu, field)
	is_main_menu = false


func _on_MenuMain_settings_pressed() -> void:
	load_settings()
	settings.connect("back_pressed", self, "_on_Settings_back_pressed")
	make_transition(menu, settings)
	is_main_menu = false


func _on_MenuMain_shop_pressed() -> void:
	load_shop()
	shop.connect("back_pressed", self, "_on_Shop_back_pressed")
	make_transition(menu, shop)
	is_main_menu = false


func _on_Field_game_over(score: int) -> void:
	load_game_over()
	game_over.connect("try_again_pressed", self, "_on_GameOver_try_again_pressed")
	game_over.connect("back_to_menu_pressed", self, "_on_GameOver_back_to_menu_pressed")
	game_over.get_node("Score").text = String(score)
	if Globals.set_new_high(score):
		game_over.get_node("NewBest").visible = true
	make_transition(field, game_over)
	field = null
	pass


func _on_GameOver_try_again_pressed() -> void:
	load_field()
	field.connect("game_over", self, "_on_Field_game_over")
	make_transition(game_over, field)


func _on_GameOver_back_to_menu_pressed() -> void:
	load_menu()
	make_transition(game_over, menu, true)


func _on_Settings_back_pressed() -> void:
	load_menu()
	make_transition(settings, menu, true)
	

func _on_Shop_back_pressed() -> void:
	load_menu()
	make_transition(shop, menu, true)


func _on_Field_quit_pressed() -> void:
	load_menu()
	Globals.field_is_focused = false
	for bubble in field.get_node("Bubbles").get_children():
		bubble.set_physics_process(false)
		bubble.set_process(false)
		bubble.set_children_process(false)
	field.set_process(false)
	make_transition(field, menu, true, true)


func make_transition(from: Control, to: Control, backwards: bool = false, save: bool = false) -> void:
	tween.interpolate_property(from, "rect_scale", from.rect_scale, Vector2.ONE * 1.1 if backwards else Vector2.ONE * 0.9, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(from, "modulate", from.modulate, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(to, "rect_scale", Vector2.ONE * 0.9 if backwards else Vector2.ONE * 1.1, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(to, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	if not save:
		timer.connect("timeout", from, "queue_free")
		timer.start(0.3)

func set_game_theme(theme: GameTheme) -> void:
	background.color = theme.bg_color
	bg_texture.self_modulate = theme.bg_front_color
	rounded_button_style.set("bg_color", theme.button_color)
	for i in range(6):
		bubble_materials[i].set("shader_param/color_from", theme.bubble_colors[i])
		bubble_materials[i].set("shader_param/color_to", theme.bubble_front_colors[i])


func game_theme_transition(theme: GameTheme) -> void:
	tween.interpolate_property(background, "color", background.color, theme.bg_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(bg_texture, "self_modulate", bg_texture.self_modulate, theme.bg_front_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(rounded_button_style, "bg_color", rounded_button_style.get("bg_color"), theme.button_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	for i in range(6):
		tween.interpolate_property(bubble_materials[i], "shader_param/color_from", bubble_materials[i].get("shader_param/color_from"),  theme.bubble_colors[i], 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(bubble_materials[i], "shader_param/color_to", bubble_materials[i].get("shader_param/color_to"),  theme.bubble_colors[i], 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func set_background(bg: Background) -> void:
	bg_texture.texture = bg.background


func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if get_tree().paused or is_quit_menu: return
		Globals.field_is_focused = false
		var quit_scene = load("res://Scenes/QuitPopup.tscn")
		var quit_popup = quit_scene.instance()
		call_deferred("add_child", quit_popup)
		is_quit_menu = true
	elif what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().paused or is_quit_menu: return
		if is_main_menu:
			Globals.field_is_focused = false
			var quit_scene = load("res://Scenes/QuitPopup.tscn")
			var quit_popup = quit_scene.instance()
			call_deferred("add_child", quit_popup)
			is_quit_menu = true
