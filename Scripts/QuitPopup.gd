extends ColorRect
class_name QuitPopup

func _ready():
	rect_pivot_offset = rect_size * 0.5
	set_colors(Globals.get_current_theme())
	$Tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.1, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func set_colors(theme: GameTheme):
	$Panel.self_modulate = theme.bg_color
	$Panel/Title.set("custom_colors/font_color", theme.header_color)

func _on_No_pressed():
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.set_wait_time(0.3)
	$Timer.start()
	Globals.field_is_focused = true
	get_parent().is_quit_menu = false


func _on_Yes_pressed():
	Globals.save_game()
	get_tree().quit()
