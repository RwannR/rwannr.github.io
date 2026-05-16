extends Area2D

@export var accepted_items: Array[String] = []
@export var zone_name = ""
@export var success_message = ""
@export var wrong_item_message = "Cet objet ne va pas ici."
@export var no_item_message = "Vous n'avez rien à déposer ici."
@export var completes_quest = ""

var already_delivered = false

func interact():
	if already_delivered:
		return
	
	if GameManager.inventory.is_empty():
		_speak(no_item_message)
		return
	
	for item_id in accepted_items:
		if GameManager.has_item(item_id):
			already_delivered = true
			GameManager.remove_item(item_id)
			_speak(success_message)
			GameManager.add_vigilance(15)
			
			if completes_quest != "":
				QuestManager.complete_quest(completes_quest)
			return
	
	_speak(wrong_item_message)

func _speak(text):
	var mascot_nodes = get_tree().get_nodes_in_group("mascot")
	if mascot_nodes.size() > 0:
		mascot_nodes[0].speak(text, 3.0, false)
