extends Control
class_name Shop, "res://Sprites/Icons/shop.png"

var popup_scene = preload("res://Scenes/ShopPopup.tscn")
var shop_item_node = preload("res://Prefabs/ShopItem.tscn")
var upgrade_node = preload("res://Prefabs/UpgradeItem.tscn")

signal back_pressed

func _ready():
	rect_pivot_offset = rect_size * 0.5
	set_game_theme(Globals.get_current_theme())
	set_wallet()
	for id in Globals.upgrades.size():
		var item: UpgradeItem = upgrade_node.instance()
		item.setup(id)
		item.connect("pressed", self, "_on_upgrade_pressed")
		$ScrollContainer/ShopContainer/Upgrades.call_deferred("add_child", item)
	for id in Globals.themes.size():
		var item: ShopItem = shop_item_node.instance()
		item.setup(0, id)
		item.connect("pressed", self, "_on_item_pressed")
		$ScrollContainer/ShopContainer/Themes.call_deferred("add_child", item)
	for id in Globals.decorations.size():
		var item: ShopItem = shop_item_node.instance()
		item.setup(1, id)
		item.connect("pressed", self, "_on_item_pressed")
		$ScrollContainer/ShopContainer/Decorations.call_deferred("add_child", item)
	for id in Globals.backgrounds.size():
		var item: ShopItem = shop_item_node.instance()
		item.setup(2, id)
		item.connect("pressed", self, "_on_item_pressed")
		$ScrollContainer/ShopContainer/Backgrounds.call_deferred("add_child", item)
	AdMob.connect("rewarded_video_loaded", self, "enable_morecoins")
	AdMob.connect("rewarded", self, "on_rewardvideo_finished")
	if AdMob._is_rewarded_video_loaded:
		enable_morecoins()
	else:
		AdMob.load_rewarded_video()


func set_wallet():
	$Wallet/Coins.text = str(Globals.coins)
	$Wallet/Gems.text = str(Globals.gems)


func _on_BackButton_pressed():
	$BackButton.disabled = true
	emit_signal("back_pressed")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		emit_signal("back_pressed")


func _on_item_pressed(type: int, id: int):
	if Globals.has_item(type, id):
		set_item(type, id)
	else:
		show_popup(type, id)


func _on_upgrade_pressed(id: int) -> void:
	match Globals.get_upgrade_currency(id):
		0: Globals.coins -= Globals.get_upgrade_cost(id)
		1: Globals.gems -= Globals.get_upgrade_cost(id)
	Globals.increment_upgrade(id)
	set_wallet()
	for upgrade in $ScrollContainer/ShopContainer/Upgrades.get_children():
		upgrade.set_info()


func show_popup(type: int, id: int):
	var popup: ShopPopup = popup_scene.instance()
	popup.setup(type, id)
	popup.connect("confirmed", self, "purchase")
	add_child(popup)


func purchase(type: int, id: int):
	Globals.add_item(type, id)
	var item
	match type:
		0:
			$ScrollContainer/ShopContainer/Themes.get_child(id).remove_cost()
			item = Globals.themes[id]
		1:
			$ScrollContainer/ShopContainer/Decorations.get_child(id).remove_cost()
			item = Globals.decorations[id]
		2:
			$ScrollContainer/ShopContainer/Backgrounds.get_child(id).remove_cost()
			item = Globals.backgrounds[id]
	match item.currency:
		0: Globals.coins -= item.cost
		1: Globals.gems -= item.cost
	set_wallet()
	set_item(type, id)


func set_item(type: int, id: int):
	match type:
		0:
			var theme = Globals.themes[id]
			set_theme_transition(theme)
			for upgrades in $ScrollContainer/ShopContainer/Upgrades.get_children():
				upgrades.set_colors_transition(theme)
			for decos in $ScrollContainer/ShopContainer/Decorations.get_children():
				decos.set_colors_transition(theme)
			for backg in $ScrollContainer/ShopContainer/Backgrounds.get_children():
				backg.set_colors_transition(theme)
			Globals.current_theme = id
		1:
			var decos = Globals.decorations[id]
			for theme in $ScrollContainer/ShopContainer/Themes.get_children():
				theme.set_bubble_decos(decos)
			Globals.current_decos = id
		2:
			var backg = Globals.backgrounds[id]
			get_parent().set_background(backg)
			for theme in $ScrollContainer/ShopContainer/Themes.get_children():
				theme.set_background(backg)
			for decos in $ScrollContainer/ShopContainer/Decorations.get_children():
				decos.set_background(backg)
			Globals.current_backg = id
	Globals.save_game()



func set_game_theme(game_theme: GameTheme):
	$BackButton.set_self_modulate(game_theme.header_color)
	$Title.set("custom_colors/font_color", game_theme.header_color)
	$ScrollContainer/ShopContainer/UpgradesTitle.set("custom_colors/font_color", game_theme.header_color)
	$ScrollContainer/ShopContainer/ThemesTitle.set("custom_colors/font_color", game_theme.header_color)
	$ScrollContainer/ShopContainer/BubbleDecosTitle.set("custom_colors/font_color", game_theme.header_color)
	$ScrollContainer/ShopContainer/BackgroundsTitle.set("custom_colors/font_color", game_theme.header_color)
	$Wallet/Coins.set("custom_colors/font_color", game_theme.header_color)
	$Wallet/Gems.set("custom_colors/font_color", game_theme.header_color)

func set_theme_transition(theme: GameTheme):
	$Tween.interpolate_property($BackButton, "self_modulate", $BackButton.self_modulate, theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Title, "custom_colors/font_color", $Title.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($ScrollContainer/ShopContainer/UpgradesTitle, "custom_colors/font_color", $ScrollContainer/ShopContainer/UpgradesTitle.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($ScrollContainer/ShopContainer/ThemesTitle, "custom_colors/font_color", $ScrollContainer/ShopContainer/ThemesTitle.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($ScrollContainer/ShopContainer/BubbleDecosTitle, "custom_colors/font_color", $ScrollContainer/ShopContainer/BubbleDecosTitle.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($ScrollContainer/ShopContainer/BackgroundsTitle, "custom_colors/font_color", $ScrollContainer/ShopContainer/BackgroundsTitle.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Wallet/Coins, "custom_colors/font_color", $Wallet/Coins.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Wallet/Gems, "custom_colors/font_color", $Wallet/Gems.get("custom_colors/font_color"), theme.header_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	get_parent().game_theme_transition(theme)


func _on_MoreCoins_pressed():
	AdMob.show_rewarded_video()


func enable_morecoins():
	$Wallet/MoreCoins.disabled = false


func on_rewardvideo_finished(_currency, amount):
	Globals.coins += amount
	set_wallet()
	Globals.save_game()
	$Wallet/MoreCoins.disabled = true
	AdMob.load_rewarded_video()
