extends PanelContainer

@onready var title_label: Label = $MarginContainer/VBoxContainer/Title
@onready var content_label: Label = $MarginContainer/VBoxContainer/Content
@onready var close_btn: Button = $MarginContainer/VBoxContainer/Button

func _ready() -> void:
	close_btn.pressed.connect(_close)
	visible = false

func show_tip(title, content) -> void:
	title_label.text = title
	content_label.text = content
	visible = true

func _close() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"): # on peut fermer avec E
		_close()
		get_viewport().set_input_as_handled() # empêche le déclenchement d'une action
