extends CanvasLayer

const BannerFontUtil := preload("res://elements/ui/banner_font_util.gd")

const FONT_MIN := 14
const FONT_MAX := 120

@onready var defeat_panel := $MarginContainer/Control/PanelContainer as PanelContainer
@onready var caption_label := $MarginContainer/Control/PanelContainer/CaptionLabel
@onready var animation_player := $AnimationPlayer


func _ready() -> void:
	hide()
	if animation_player:
		animation_player.stop()
	if defeat_panel:
		defeat_panel.resized.connect(_on_defeat_panel_resized)
	if caption_label:
		caption_label.text = "Поражение"


func _on_defeat_panel_resized() -> void:
	_apply_defeat_font_fit()


func _apply_defeat_font_fit() -> void:
	if caption_label and defeat_panel:
		BannerFontUtil.fit_label_to_panel(caption_label, defeat_panel, FONT_MIN, FONT_MAX)


func show_overlay() -> void:
	show()
	if animation_player:
		animation_player.play("show_overlay")
	await get_tree().process_frame
	_apply_defeat_font_fit()


func _on_button_pressed() -> void:
	if animation_player:
		animation_player.stop()
	hide()
	Globals.reset_to_first_level()
	Events.location_changed.emit(Events.LOCATIONS.GAME)

