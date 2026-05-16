extends PanelContainer

@onready var item_row: HBoxContainer = $MarginContainer/ItemRow

func _ready() -> void:
	GameManager.inventory_changed.connect(_refresh)
	_refresh()

func _refresh():
	for child in item_row.get_children():
		item_row.remove_child(child)
		child.free()
	
	if GameManager.inventory.is_empty():
		visible = false
		return
	
	visible = true
	
	for item in GameManager.inventory:
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(40, 40)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.tooltip_text = item.name
		
		if item.icon != "" && FileAccess.file_exists(item.icon):
			icon.texture = load(item.icon)
		else:
			# Placeholder gris si pas d'icône
			var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.4, 0.4, 0.45))
			icon.texture = ImageTexture.create_from_image(img)
		
		item_row.add_child(icon)
