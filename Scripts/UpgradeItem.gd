extends Panel
class_name UpgradeItem, "res://Sprites/Icons/shop.png"

signal pressed(id)
var id: int


func setup(_id: int) -> void:
	id = _id


func _ready() -> void:
	set_colors(Globals.get_current_theme())
	set_info()


func set_colors(_theme: GameTheme) -> void:
	self_modulate = _theme.button_color
	$NameCost/Name.self_modulate = _theme.header_color
	$NameCost/Cost/Cost.self_modulate = _theme.header_color
	$Description.self_modulate = _theme.paragraph_color
	$Level1.self_modulate = _theme.borderline_color
	$Level2.self_modulate = _theme.borderline_color
	$Level3.self_modulate = _theme.borderline_color
	$Level4.self_modulate = _theme.borderline_color


func set_colors_transition(_theme: GameTheme) -> void:
	$Tween.interpolate_property(self, "self_modulate", self_modulate, _theme.button_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($NameCost/Name, "self_modulate", $NameCost/Name.self_modulate, _theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($NameCost/Cost/Cost, "self_modulate", $NameCost/Cost/Cost.self_modulate, _theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Description, "self_modulate", $Description.self_modulate, _theme.paragraph_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	var level = Globals.upgrade_levels[id]
	if level < 1: $Tween.interpolate_property($Level1, "self_modulate", $Level1.self_modulate, _theme.borderline_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	if level < 2: $Tween.interpolate_property($Level2, "self_modulate", $Level2.self_modulate, _theme.borderline_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	if level < 3: $Tween.interpolate_property($Level3, "self_modulate", $Level3.self_modulate, _theme.borderline_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	if level < 4: $Tween.interpolate_property($Level4, "self_modulate", $Level4.self_modulate, _theme.borderline_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func set_info() -> void:
	$NameCost/Name.text = Globals.upgrades[id].name
	if Globals.get_upgrade_cost(id) == -1:
		$NameCost/Cost.visible = false
		$Button.disabled = true
	else:
		match Globals.get_upgrade_currency(id):
			0:
				if Globals.coins < Globals.get_upgrade_cost(id):
					$Button.disabled = true
			1:
				if Globals.gems < Globals.get_upgrade_cost(id):
					$Button.disabled = true
		$NameCost/Cost/Currency.texture = Globals.currency_textures[Globals.get_upgrade_currency(id)]
		$NameCost/Cost/Cost.text = String(Globals.get_upgrade_cost(id))
	$Description.text = Globals.get_upgrade_description(id)
	$Icon.texture = Globals.upgrades[id].icon
	set_level(Globals.upgrade_levels[id])


func set_level(level: int) -> void:
	var color = Color().from_hsv(150.0 / 360.0, 0.5, 1.0)
	if level >= 1: $Level1.self_modulate = color
	if level >= 2: $Level2.self_modulate = color
	if level >= 3: $Level3.self_modulate = color
	if level == 4: $Level4.self_modulate = color


func _on_Button_button_down():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE * 0.9, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", modulate, Color.white.darkened(0.1), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_Button_button_up():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", modulate, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_Button_pressed():
	emit_signal("pressed", id)
