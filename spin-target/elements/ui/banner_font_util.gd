extends Object


## Подбирает размер шрифта метки, чтобы однострочный текст помещался во внутреннюю область панели (с учётом content_margin стиля).
static func fit_label_to_panel(label: Label, panel: PanelContainer, min_px: int, max_px: int) -> void:
	if not label or not panel or label.text.is_empty():
		return
	var inner := _panel_inner_size(panel)
	if inner.x < 4.0 or inner.y < 4.0:
		return
	var font: Font = label.get_theme_font(&"font")
	if font == null:
		return
	var text := label.text
	var chosen := min_px
	for s in range(max_px, min_px - 1, -1):
		var ts: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, s)
		if ts.x <= inner.x + 0.5 and ts.y <= inner.y + 0.5:
			chosen = s
			break
	label.add_theme_font_size_override(&"font_size", chosen)


static func _panel_inner_size(panel: PanelContainer) -> Vector2:
	var sz := panel.size
	var sb: StyleBox = panel.get_theme_stylebox(&"panel", &"PanelContainer")
	if sb == null:
		sb = panel.get_theme_stylebox(&"panel")
	if sb:
		return Vector2(
			sz.x - sb.get_content_margin(SIDE_LEFT) - sb.get_content_margin(SIDE_RIGHT),
			sz.y - sb.get_content_margin(SIDE_TOP) - sb.get_content_margin(SIDE_BOTTOM)
		)
	return sz
