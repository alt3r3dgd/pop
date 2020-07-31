extends Button

onready var color = .get_self_modulate()

func _ready():
	rect_pivot_offset = rect_size * 0.5
	set_colors(Globals.get_current_theme())

func set_colors(theme: GameTheme):
	set("custom_colors/font_color", theme.button_text_color)
	set("custom_colors/font_color_hover", theme.button_text_color)
	set("custom_colors/font_color_pressed", theme.button_text_color)
	get_stylebox("normal").set("bg_color", theme.button_color)


func _on_Button_button_down():
	$Tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ONE * 0.9, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "self_modulate", .get_self_modulate(), color.darkened(0.1), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_Button_button_up():
	$Tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "self_modulate", .get_self_modulate(), color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
