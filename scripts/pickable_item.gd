extends Area2D

@export var item_id = ""
@export var item_name = ""
@export var item_description = ""
@export var item_icon_path = ""

func _ready():
	if item_id in GameManager.picked_items:
		queue_free()

func interact():
	if GameManager.has_item(item_id):
		return
	
	GameManager.picked_items.append(item_id)
	GameManager.add_item(item_id, item_name, item_description, item_icon_path)
	
	var mascot_nodes = get_tree().get_nodes_in_group("mascot")
	if mascot_nodes.size() > 0:
		mascot_nodes[0].speak("Vous avez ramassé: " + item_name, 2.0, false)
	
	queue_free()
