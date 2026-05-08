extends Control

const BannerFontUtil := preload("res://elements/ui/banner_font_util.gd")

const FONT_MIN := 14
const FONT_MAX := 120

@onready var banner_panel := $MarginContainer/Control/BannerPanel as PanelContainer
@onready var banner_label := $MarginContainer/Control/BannerPanel/Label
@onready var stats_panel := $Panel as PanelContainer
@onready var result_row := $Panel/MarginContainer/VBoxContainer/ResultRow
@onready var animation_player := $AnimationPlayer


func _ready() -> void:
	hide()
	if animation_player:
		animation_player.stop()
	if banner_panel:
		banner_panel.resized.connect(_on_banner_panel_resized)


func _on_banner_panel_resized() -> void:
	_apply_banner_font_fit()


func _apply_banner_font_fit() -> void:
	if banner_label and banner_panel:
		BannerFontUtil.fit_label_to_panel(banner_label, banner_panel, FONT_MIN, FONT_MAX)


func show_banner_and_next_level() -> void:
	if not is_inside_tree():
		return
	modulate = Color(1, 1, 1, 1)
	var is_boss := Globals.current_level == Globals.LEVEL_COUNT - 1
	if banner_label:
		banner_label.text = "Победа" if is_boss else "Пройдено"
	_fill_result_cards()
	show()
	if animation_player:
		animation_player.play("show_banner")
	await get_tree().process_frame
	_apply_banner_font_fit()
	await get_tree().create_timer(2.8).timeout
	if animation_player:
		animation_player.stop()
	hide()
	Globals.go_to_next_level()


func _fill_result_cards() -> void:
	if not result_row:
		return
	var cards := Globals.get_run_result_cards()
	for i in range(result_row.get_child_count()):
		var card := result_row.get_child(i)
		var value_label := card.get_node_or_null("VBoxContainer/ValueLabel") as Label
		var title_label := card.get_node_or_null("VBoxContainer/TitleLabel") as Label
		if i >= cards.size():
			card.hide()
			continue
		card.show()
		var data := cards[i]
		if value_label:
			value_label.text = String(data.get("value", "0"))
			value_label.add_theme_color_override("font_color", data.get("color", Color.WHITE))
		if title_label:
			title_label.text = String(data.get("title", ""))
