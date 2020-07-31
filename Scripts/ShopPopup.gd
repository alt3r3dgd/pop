extends ColorRect
class_name ShopPopup, "res://Sprites/Icons/shop.png"

var type: int
var id: int

signal confirmed

func setup(_type: int, _id: int):
	type = _type
	id = _id


func _ready():
	rect_pivot_offset = rect_size * 0.5
	self.rect_pivot_offset = self.rect_size / 2.0
	match type:
		0:
			var theme: GameTheme = Globals.themes[id]
			set_colors(theme)
			set_decos(Globals.get_current_decos())
			set_background(Globals.get_current_backg())
			set_cost(theme.currency, theme.cost)
			$Popup/ConfirmText.text = "Buy this theme?"
		1:
			var decos: BubbleDecorations = Globals.decorations[id]
			set_colors(Globals.get_current_theme())
			set_decos(decos)
			set_background(Globals.get_current_backg())
			set_cost(decos.currency, decos.cost)
			$Popup/ConfirmText.text = "Buy these decorations?"
		2:
			var backg: Background = Globals.backgrounds[id]
			set_colors(Globals.get_current_theme())
			set_decos(Globals.get_current_decos())
			set_background(backg)
			set_cost(backg.currency, backg.cost)
			$Popup/ConfirmText.text = "Buy this background?"
	
	$Tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.1, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func set_colors(theme: GameTheme):
	$Popup.get_stylebox("panel").set("bg_color", theme.bg_color)
	$Popup/Background.self_modulate = theme.bg_front_color
	$Popup/Yes.set_colors(theme)
	$Popup/ConfirmText.set("custom_colors/font_color", theme.header_color)
	var bubbles = $Popup/Bubbles.get_children()
	for i in range(6):
		bubbles[i].material.set("shader_param/color_from", theme.bubble_colors[i])
		bubbles[i].material.set("shader_param/color_to", theme.bubble_front_colors[i])


func set_decos(decos: BubbleDecorations):
	$Popup/Bubbles/Red.texture = decos.red_bubble
	$Popup/Bubbles/Orange.texture = decos.orange_bubble
	$Popup/Bubbles/Yellow.texture = decos.yellow_bubble
	$Popup/Bubbles/Green.texture = decos.green_bubble
	$Popup/Bubbles/LightBlue.texture = decos.lblue_bubble
	$Popup/Bubbles/Blue.texture = decos.blue_bubble


func set_background(backg: Background):
	$Popup/Background.texture = backg.popup


func set_cost(currency: int, cost: int):
	match currency:
		0: if Globals.coins < cost:
			$Popup/Yes.set_disabled(true)
		1: if Globals.gems < cost:
			$Popup/Yes.set_disabled(true)
	$Popup/Yes.icon = Globals.currency_textures_large[currency]
	$Popup/Yes.text = str(cost)


func close():
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.set_wait_time(0.3)
	$Timer.start()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		close()


func _on_Yes_pressed():
	emit_signal("confirmed", type, id)
	close()
