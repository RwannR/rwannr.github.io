extends Control

@onready var overlay = $Overlay
@onready var window_panel = $WindowPanel

func _ready():
	var close_btn = $WindowPanel/VBoxContainer/TitleBar/HBoxContainer/CloseBtn
	close_btn.pressed.connect(close_window)
	
	var reload_btn = $WindowPanel/VBoxContainer/TitleBar/HBoxContainer/ReloadBtn
	reload_btn.pressed.connect(reload_game)
	
	visible = false

func open_window():
	visible = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = true
	
	var content = $WindowPanel/VBoxContainer/ContentArea
	for child in content.get_children():
		if child.has_method("on_window_opened"):
			child.on_window_opened()

func close_window():
	visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = false

func reload_game():
	var content = $WindowPanel/VBoxContainer/ContentArea
	for child in content.get_children():
		if child.has_method("_pick_random_mails"):
			child._pick_random_mails()
		elif child.has_method("_reset"):
			child._reset()
		elif child.has_method("_ready"):
			child._ready()

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		close_window()
		get_viewport().set_input_as_handled()
