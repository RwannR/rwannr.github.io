extends CharacterBody2D

@export var npc_name = "Collègue"
@export var message = "Salut ! Comment ça va ?"
@export var duration = 3.0
@export var one_shot = false
@export var completes_quest = ""
@export var event_id = ""

var already_spoken = false
var player_nearby = false

@onready var speech_bubble: PanelContainer = $SpeechBubble
@onready var message_label: Label = $SpeechBubble/MarginContainer/Message
@onready var speech_timer: Timer = $SpeechTimer
@onready var detection_zone: Area2D = $DetectionZone

func _ready():
	speech_bubble.visible = false
	speech_timer.timeout.connect(_on_timer_timeout)
	detection_zone.body_entered.connect(_on_player_entered)
	detection_zone.body_exited.connect(_on_player_exited)
	
	if one_shot and npc_name in GameManager.triggered_npcs:
		already_spoken = true
	
	if event_id == "visitor":
		if GameManager.f0_event_triggered and GameManager.f0_event_type == "visitor":
			visible = true
			$DetectionZone/CollisionShape2D.disabled = false
		else:
			visible = false
			$DetectionZone/CollisionShape2D.disabled = true
	   
		GameManager.f0_event_changed.connect(_on_f0_event)

func _on_f0_event(event_type):
	if event_type == "visitor" and event_id == "visitor":
		var mascot_nodes = get_tree().get_nodes_in_group("mascot")
		if mascot_nodes.size() > 0:
			mascot_nodes[0].speak("Attention ! Un visiteur vient d'arriver. Allez l'accueillir !", 4.0, false)
		
		visible = true
		$DetectionZone/CollisionShape2D.disabled = false
		already_spoken = false
		if npc_name in GameManager.triggered_npcs:
			GameManager.triggered_npcs.erase(npc_name)

func _on_player_entered(body) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if one_shot && already_spoken:
			return
		already_spoken = true
		
		if one_shot:
			GameManager.triggered_npcs.append(npc_name)
		
		if event_id != "":
			_trigger_event()
			if event_id == "visitor":
				await get_tree().create_timer(10.0).timeout
				GameManager.reset_f0_event()
		else:
			_speak()
			if completes_quest != "":
				QuestManager.complete_quest(completes_quest)

func _on_player_exited(body) -> void:
	if body.is_in_group("player"):
		player_nearby = false
	
func _speak() -> void:
	message_label.text = message
	speech_bubble.visible = true
	speech_timer.start(duration)

func _on_timer_timeout() -> void:
	speech_bubble.visible = false
	
func _trigger_event():
	var file = FileAccess.open("res://data/events.json", FileAccess.READ)
	if not file:
		return
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result != OK:
		return
	
	var events = json.data
	if not events.has(event_id):
		return
	
	var event = events[event_id]
	var nodes = get_tree().get_nodes_in_group("choice_dialog")
	if nodes.size() > 0:
		nodes[0].show_dialog(event.description, event.choices, event.quest_id, event)
