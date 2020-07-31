extends Control
class_name MainMenu

signal play_pressed
signal settings_pressed
signal shop_pressed


func _ready():
	rect_pivot_offset = rect_size * 0.5
	set_game_theme(Globals.get_current_theme())


func _on_PlayButton_pressed():
	$PlayButton.disabled = true
	emit_signal("play_pressed")


func _on_ShopButton_pressed():
	$ShopButton.disabled = true
	emit_signal("shop_pressed")


func _on_SettingsButton_pressed():
	$SettingsButton.disabled = true
	emit_signal("settings_pressed")


func _on_AchievementsButton_pressed():
	GPGS.show_achievements()


func _on_LeaderboardsButton_pressed():
	GPGS.show_all_leaderboards()


func _on_YouTubeButton_pressed():
	OS.shell_open("https://www.youtube.com/channel/UC8G5egJVXHMoi-21vIJhKZg")


func _on_DiscordButton_pressed():
	OS.shell_open("https://invite.gg/alterity")


func _on_TwitterButton_pressed():
	OS.shell_open("https://twitter.com/alt3r3d")


func set_game_theme(_theme: GameTheme):
	$PlayButton.self_modulate = _theme.play_button_back
	$PlayButton/Front.self_modulate = _theme.play_button_front
	$Title.self_modulate = _theme.title_back
	$Title/TitleFront.self_modulate = _theme.title_front
	$ShopButton.self_modulate = _theme.button_color
	$SettingsButton.self_modulate = _theme.button_color
	$AchievementsButton.self_modulate = _theme.button_color
	$LeaderboardsButton.self_modulate = _theme.button_color
	$Label.set("custom_colors/font_color", _theme.header_color)
	$Label2.set("custom_colors/font_color", _theme.paragraph_color)
