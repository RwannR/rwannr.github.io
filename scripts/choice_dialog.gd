extends PanelContainer

@onready var description = $MarginContainer/VBoxContainer/Description
@onready var choice_list = $MarginContainer/VBoxContainer/ChoiceList
@onready var feedback = $MarginContainer/VBoxContainer/Feedback
@onready var close_btn = $MarginContainer/VBoxContainer/CloseBtn

var choices = []
var quest_id = ""

func _ready():
	visible = false
	close_btn.pressed.connect(_close)
	close_btn.visible = false

func show_dialog(desc, choice_array, linked_quest = "", event_data = {}):
	description.text = desc
	quest_id = linked_quest
	feedback.text = ""
	close_btn.visible = false
	
	# Filtre les choix selon la config
	choices = []
	for choice in choice_array:
		if choice.get("is_croissantage", false) and not event_data.get("croissantage_enabled", false):
			continue
		choices.append(choice)
	
	# Nettoie les anciens boutons
	for child in choice_list.get_children():
		choice_list.remove_child(child)
		child.free()
	
	# Crée les boutons
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i].label
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_choice.bind(i))
		choice_list.add_child(btn)
	
	visible = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = true

func _on_choice(index):
	var choice = choices[index]
	
	# Désactive tous les boutons
	for btn in choice_list.get_children():
		btn.disabled = true
	
	# Affiche le feedback
	feedback.text = choice.feedback

	if choice.get("is_croissantage", false):
		feedback.modulate = Color(1, 0.7, 0.2)
		GameManager.add_vigilance(choice.get("vigilance", 5))
		if quest_id != "":
			QuestManager.complete_quest(quest_id)
		_spawn_croissant_npc()
	elif choice.correct:
		feedback.modulate = Color(0.3, 1, 0.5)
		GameManager.add_vigilance(choice.get("vigilance", 10))
		if quest_id != "":
			QuestManager.complete_quest(quest_id)
	else:
		feedback.modulate = Color(1, 0.3, 0.3)
		GameManager.remove_vigilance(choice.get("vigilance", 10))
	
	close_btn.visible = true

func _spawn_croissant_npc():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Charge scène NPC
	var npc_scene = preload("res://scenes/npc.tscn")
	var npc = npc_scene.instantiate()
	
	# Place le NPC à côté du joueur
	npc.position = Vector2(player.global_position.x + 160, player.global_position.y)
	npc.npc_name = "Collègue"
	npc.message = "Hé ! C'est toi qui as envoyé le mail ? J'attends mes croissants demain matin !"
	npc.duration = 5.0
	npc.one_shot = true
	npc.scale = Vector2(2, 2)
	
	# Ajoute le NPC à la scène courante
	player.get_parent().add_child(npc)
	
func _close():
	visible = false
	close_btn.visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = false

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
