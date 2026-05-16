extends Node
class_name QuestDependent

@export var required_quest = ""


func _ready() -> void:
	if required_quest == "":
		return
	
	_check_visibility()
	QuestManager.quest_updated.connect(_on_quest_changed)
	QuestManager.quest_completed.connect(_on_quest_changed)

func _check_visibility():
	if required_quest == "":
		get_parent().visible = true
		return
	
	var quest = QuestManager.get_quest(required_quest)
	if quest.is_empty():
		get_parent().visible = false
		return
	
	var status = quest.get("status", "locked")
	if status == "active" || status == "completed":
		get_parent().visible = true
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT
	else:
		get_parent().visible = false
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED

func _on_quest_changed(_quest_id):
	_check_visibility()
