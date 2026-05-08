extends Control

const StatIconScene := preload("res://scens/knife_shop/stat_icon.gd")
const PIP_COUNT := 5
const EMPTY_PIP_COLOR := Color(1, 1, 1, 0.12)

@onready var preview := $MarginContainer/VBoxContainer/PreviewRow/PreviewPanel/MarginContainer/TextureRect
@onready var name_label: Label = $MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var stat_rows := [
	$MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/StatsContainer/SpeedRow,
	$MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/StatsContainer/BladeRow,
	$MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/StatsContainer/WeightRow,
	$MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/StatsContainer/BonusRow
]


func _ready() -> void:
	Events.knives_changed.connect(_on_knives_changed)
	_on_knives_changed()


func _on_knives_changed() -> void:
	if not preview:
		return
	var knife_index := Globals.current_knife_index + 1
	if knife_index < 1:
		knife_index = 1
	if knife_index > 9:
		knife_index = 9
	var texture_path := "res://assets/knife%d.png" % knife_index
	var texture := load(texture_path)
	if texture:
		preview.texture = texture
	var knife_data := Globals.get_current_knife_data()
	if name_label:
		name_label.text = String(knife_data.get("name", ""))
	if description_label:
		description_label.hide()
	var stat_data := Globals.get_knife_stat_rows(Globals.current_knife_index)
	for i in range(min(stat_rows.size(), stat_data.size())):
		_update_stat_row(stat_rows[i], stat_data[i])


func _update_stat_row(row: Node, stat_data: Dictionary) -> void:
	if not row:
		return
	var hbox := row.get_node_or_null("MarginContainer/HBoxContainer") as HBoxContainer
	if not hbox:
		return
	var accent := stat_data.get("color", Color(1, 1, 1, 1)) as Color
	var icon := _ensure_stat_icon(hbox)
	icon.kind = int(stat_data.get("kind", 0))
	icon.accent_color = accent
	_hide_old_text(hbox)
	_update_pips(hbox, int(stat_data.get("level", 1)), accent)
	row.tooltip_text = "%s: %s" % [
		String(stat_data.get("title", "")),
		String(stat_data.get("value", ""))
	]


func _ensure_stat_icon(hbox: HBoxContainer) -> Control:
	var icon := hbox.get_node_or_null("StatIcon") as Control
	if icon:
		return icon
	icon = StatIconScene.new()
	icon.name = "StatIcon"
	icon.custom_minimum_size = Vector2(30, 22)
	hbox.add_child(icon)
	hbox.move_child(icon, 0)
	return icon


func _hide_old_text(hbox: HBoxContainer) -> void:
	var old_icon := hbox.get_node_or_null("Icon")
	if old_icon:
		old_icon.hide()
	var title_label := hbox.get_node_or_null("TitleLabel") as Label
	var value_label := hbox.get_node_or_null("ValueLabel") as Label
	if title_label:
		title_label.hide()
	if value_label:
		value_label.hide()


func _update_pips(hbox: HBoxContainer, level: int, accent: Color) -> void:
	var pips := hbox.get_node_or_null("PipsContainer") as HBoxContainer
	if not pips:
		pips = HBoxContainer.new()
		pips.name = "PipsContainer"
		pips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pips.alignment = BoxContainer.ALIGNMENT_END
		pips.add_theme_constant_override("separation", 6)
		hbox.add_child(pips)
	while pips.get_child_count() < PIP_COUNT:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(28, 9)
		pips.add_child(pip)
	for i in range(pips.get_child_count()):
		var pip := pips.get_child(i) as ColorRect
		if not pip:
			continue
		pip.color = accent if i < level else EMPTY_PIP_COLOR
