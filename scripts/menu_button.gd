extends Control

@onready var btn: Button = $Btn
@onready var confirm_dialog: PanelContainer = $ConfirmDialog
@onready var btn_yes: Button = $ConfirmDialog/MarginContainer/VBoxContainer/Buttons/BtnYes
@onready var btn_no: Button = $ConfirmDialog/MarginContainer/VBoxContainer/Buttons/BtnNo

func _ready() -> void:
	btn.pressed.connect(_on_menu_pressed)
	btn_yes.pressed.connect(_on_confirm_yes)
	btn_no.pressed.connect(_on_confirm_no)

func _on_menu_pressed():
	confirm_dialog.visible = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = true

func _on_confirm_yes():
	confirm_dialog.visible = false
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_confirm_no():
	confirm_dialog.visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = false
