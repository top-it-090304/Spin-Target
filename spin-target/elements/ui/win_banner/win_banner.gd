extends Control

const BannerFontUtil := preload("res://elements/ui/banner_font_util.gd")

const FONT_MIN := 14
const FONT_MAX := 120

@onready var banner_panel := $Panel as PanelContainer
@onready var banner_label := $Panel/Label


func _ready() -> void:
	hide()
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
	var is_boss := Globals.current_level == Globals.LEVEL_COUNT - 1
	if banner_label:
		banner_label.text = "Победа" if is_boss else "Пройдено"
	show()
	await get_tree().process_frame
	_apply_banner_font_fit()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0)
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	hide()
	Globals.go_to_next_level()

