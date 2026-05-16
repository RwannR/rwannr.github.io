extends PanelContainer

@onready var quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList
@onready var description: Label = $MarginContainer/VBoxContainer/Description

func _ready():
	QuestManager.quest_updated.connect(_on_quest_changed)
	QuestManager.quest_completed.connect(_on_quest_changed)
	_refresh()

func _on_quest_changed(_quest_id):
	_refresh()

func _refresh():
	# Supprimer les anciennes entrées
	for child in quest_list.get_children():
		child.queue_free()
	
	# Ajouter les quêtes actives
	var active = QuestManager.get_active_quests()
	for quest in active:
		var btn = Button.new()
		btn.text = "→ " + quest.title
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_quest_clicked.bind(quest.id))
		quest_list.add_child(btn)
	
	# Ajouter les quêtes complétées
	var completed = QuestManager.get_completed_quests()
	for quest in completed:
		var btn = Button.new()
		btn.text = "✓ " + quest.title
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.modulate = Color(0.5, 0.5, 0.5)
		btn.pressed.connect(_on_quest_clicked.bind(quest.id))
		quest_list.add_child(btn)

func _on_quest_clicked(quest_id):
	var quest = QuestManager.get_quest(quest_id)
	if quest:
		description.text = quest.description
