extends Panel
class_name ShopItem, "res://Sprites/Icons/shop.png"

signal pressed
var type: int
var id: int

func setup(_type: int, _id: int):
	type = _type
	id = _id

func _ready():
	if Globals.has_item(type, id):
		remove_cost()
	match type:
		0:
			var theme: GameTheme = Globals.themes[id]
			set_colors(theme)
			set_bubble_colors(theme)
			set_bubble_decos(Globals.get_current_decos())
			set_background(Globals.get_current_backg())
			set_cost(theme.currency, theme.cost)
		1:
			var decos: BubbleDecorations = Globals.decorations[id]
			set_colors(Globals.get_current_theme())
			set_bubble_decos(decos)
			set_background(Globals.get_current_backg())
			set_cost(decos.currency, decos.cost)
		2:
			var backg: Background = Globals.backgrounds[id]
			$Bubbles.visible = false
			set_colors(Globals.get_current_theme())
			set_background(backg)
			set_cost(backg.currency, backg.cost)

func set_colors(theme: GameTheme):
	self.self_modulate = theme.bg_color
	$Background.self_modulate = theme.bg_front_color
	$CostContainer/Cost.set("custom_colors/font_color", theme.button_text_color)


func set_bubble_colors(theme: GameTheme):
	var bubbles = $Bubbles.get_children()
	for i in range(6):
		bubbles[i].material = bubbles[i].material.duplicate()
		bubbles[i].material.set("shader_param/color_from", theme.bubble_colors[i])
		bubbles[i].material.set("shader_param/color_to", theme.bubble_front_colors[i])


func set_colors_transition(theme: GameTheme):
	$Tween.interpolate_property(self, "self_modulate", get_self_modulate(), theme.bg_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Background, "self_modulate", $Background.self_modulate, theme.bg_front_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($CostContainer/Cost, "custom_colors/font_color", $CostContainer/Cost.get("custom_colors/font_color"), theme.button_text_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	var bubbles = $Bubbles.get_children()
	for i in range(6):
		$Tween.interpolate_property(bubbles[i].material, "shader_param/color_from", bubbles[i].material.get("shader_param/color_from"), theme.bubble_colors[i], 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property(bubbles[i].material, "shader_param/color_to", bubbles[i].material.get("shader_param/color_to"), theme.bubble_front_colors[i], 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func set_bubble_decos(decorations: BubbleDecorations):
	$Bubbles/RedBubble.texture = decorations.red_bubble
	$Bubbles/OrangeBubble.texture = decorations.orange_bubble
	$Bubbles/YellowBubble.texture = decorations.yellow_bubble
	$Bubbles/GreenBubble.texture = decorations.green_bubble
	$Bubbles/LightBlueBubble.texture = decorations.lblue_bubble
	$Bubbles/BlueBubble.texture = decorations.blue_bubble


func set_background(background: Background):
	$Background.texture = background.preview


func set_cost(currency: int, cost: int):
	$CostContainer/Currency.texture = Globals.currency_textures[currency]
	$CostContainer/Cost.text = str(cost)


func remove_cost():
	$Panel.visible = false
	$CostContainer.visible = false


func _on_Button_button_down():
	$Tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ONE * 0.9, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", .get_modulate(), Color.white.darkened(0.1), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_Button_button_up():
	$Tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", .get_modulate(), Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_Button_pressed():
	emit_signal("pressed", type, id)
