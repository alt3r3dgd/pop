extends Node
class_name Gpgs, "res://Sprites/play_games.png"

export (bool) var show_popups := false
export (bool) var enable_save_games := false

signal sign_in_success(account_id)
signal sign_in_failed(error_code)
signal sign_out_success
signal sign_out_failed
signal achievement_unlocked(achievement)
signal achievement_unlocking_failed(achievement)
signal achievement_incremented(achievement)
signal achievement_incrementing_failed(achievement)
signal achievement_revealed(achievement)
signal achievement_revealing_failed(achievement)
signal leaderboard_score_submitted(leaderboard_id)
signal leaderboard_score_submitting_failed(leaderboard_id)

var _services


func _enter_tree() -> void:
	if not init():
		print("GPGS Java Singleton not found")


func init() -> bool:
	if Engine.has_singleton("PlayGameServices"):
		_services = Engine.get_singleton("PlayGameServices")
		_services.init(get_instance_id(), show_popups, enable_save_games)
		return true
	return false


func sign_in() -> void:
	if _services != null:
		_services.sign_in()


func sign_out() -> void:
	if _services != null:
		_services.sign_out()


func unlock_achievement(id: String) -> void:
	if _services != null:
		_services.unlock_achievement(id)


func increment_achievement(id: String, step: int) -> void:
	if _services != null:
		_services.increment_achievement(id, step)


func reveal_achievement(id: String) -> void:
	if _services != null:
		_services.reveal_achievement(id)


func show_achievements() -> void:
	if _services != null:
		_services.show_achievements()


func submit_leaderboard_score(id: String, score: int) -> void:
	if _services != null:
		_services.submit_leaderboard_score(id, score)


func show_leaderboard(id: String) -> void:
	if _services != null:
		_services.show_leaderboard(id)


func show_all_leaderboards() -> void:
	if _services != null:
		_services.show_all_leaderboards()


func _on_sign_in_success(account_id: String) -> void:
	emit_signal("sign_in_success", account_id)


func _on_sign_in_failed(error_code: int) -> void:
	emit_signal("sign_in_failed", error_code)


func _on_sign_out_success() -> void:
	emit_signal("sign_out_success")


func _on_sign_out_failed() -> void:
	emit_signal("sign_out_failed")


func _on_achievement_unlocked(achievement: String) -> void:
	emit_signal("achievement_unlocked", achievement)


func _on_achievement_unlocking_failed(achievement: String) -> void:
	emit_signal("achievement_unlocking_failed", achievement)


func _on_achievement_incremented(achievement: String) -> void:
	emit_signal("achievement_incremented", achievement)


func _on_achievement_incrementing_failed(achievement: String) -> void:
	emit_signal("achievement_incrementing_failed", achievement)


func _on_achievement_revealed(achievement: String) -> void:
	emit_signal("achievement_revealed", achievement)


func _on_achievement_revealing_failed(achievement: String) -> void:
	emit_signal("achievement_revealing_failed", achievement)


func _on_leaderboard_score_submitted(leaderboard_id: String) -> void:
	emit_signal("leaderboard_score_submitted", leaderboard_id)


func _on_leaderboard_score_submitting_failed(leaderboard_id: String) -> void:
	emit_signal("leaderboard_score_submitting_failed", leaderboard_id)
