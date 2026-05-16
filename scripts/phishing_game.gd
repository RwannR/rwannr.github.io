extends VBoxContainer

@onready var mail_list = $MailScroll/MailList
@onready var validate_btn = $ValidateBtn
@onready var result_label = $Result

var all_mails = []
var config = {}
var current_mails = []
var player_answers = {}

func _ready():
	_load_data()
	validate_btn.pressed.connect(_on_validate)
	_pick_random_mails()

func on_window_opened():
	if QuestManager.get_quest("q2").get("status", "") == "completed":
		visible = false
		var video_panel = get_parent().get_node("VideoPanel")
		if video_panel:
			video_panel.show_replay_button("phishing")
	else:
		visible = true

func _load_data():
	var file = FileAccess.open("res://data/phishing_mails.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		file.close()
		if parse_result == OK:
			config = json.data.config
			all_mails = json.data.mails

func _pick_random_mails():
	result_label.text = ""
	validate_btn.disabled = false
	player_answers.clear()
	
	# Nettoie la liste
	for child in mail_list.get_children():
		mail_list.remove_child(child)
		child.free()
	
	# Sépare légitimes et phishing
	var legit = []
	var phishing = []
	for mail in all_mails:
		if mail.is_legit:
			legit.append(mail)
		else:
			phishing.append(mail)
	
	legit.shuffle()
	phishing.shuffle()
	
	# Choisis le nombre de phishing
	var nb_total = config.mails_per_round
	var nb_phishing = randi_range(config.min_phishing, config.max_phishing)
	var nb_legit = nb_total - nb_phishing
	
	current_mails = []
	for i in range(mini(nb_phishing, phishing.size())):
		current_mails.append(phishing[i])
	for i in range(mini(nb_legit, legit.size())):
		current_mails.append(legit[i])
	current_mails.shuffle()
	
	# Crée l'UI pour chaque mail
	for i in range(current_mails.size()):
		var mail = current_mails[i]
		_create_mail_row(i, mail)

func _create_mail_row(index, mail):
	var panel = PanelContainer.new()
	var hbox = HBoxContainer.new()
	panel.add_child(hbox)

	# Info du mail
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var from_label = Label.new()
	from_label.text = "De : " + mail.from
	info.add_child(from_label)

	var subject_label = Label.new()
	subject_label.text = "Objet : " + mail.subject
	info.add_child(subject_label)

	var body_label = Label.new()
	body_label.text = mail.body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.add_child(body_label)

	hbox.add_child(info)

	# Boutons de choix
	var btn_box = VBoxContainer.new()

	var btn_legit = Button.new()
	btn_legit.text = "Légitime"
	btn_box.add_child(btn_legit)

	var btn_phishing = Button.new()
	btn_phishing.text = "Phishing"
	btn_box.add_child(btn_phishing)

	btn_legit.pressed.connect(_on_choice.bind(index, true, btn_legit, btn_phishing))
	btn_phishing.pressed.connect(_on_choice.bind(index, false, btn_legit, btn_phishing))

	hbox.add_child(btn_box)
	mail_list.add_child(panel)

func _on_choice(index, marked_legit, btn_legit, btn_phishing):
	player_answers[index] = marked_legit
	if btn_legit and btn_phishing:
		btn_legit.modulate = Color(1, 1, 1) if marked_legit else Color(0.5, 0.5, 0.5)
		btn_phishing.modulate = Color(0.5, 0.5, 0.5) if marked_legit else Color(1, 1, 1)

func _on_validate():
	if player_answers.size() < current_mails.size():
		result_label.text = "Vous n'avez pas répondu à tous les mails !"
		return
	
	validate_btn.disabled = true
	
	var correct = 0
	var total = current_mails.size()
	
	for i in range(total):
		var mail = current_mails[i]
		var player_said_legit = player_answers[i]
		if player_said_legit == mail.is_legit:
			correct += 1
	
	var score_text = "Résultat : %d/%d correct" % [correct, total]
	
	if correct == total:
		score_text += "\nParfait ! Vous savez repérer les phishing !"
		QuestManager.complete_quest("q2")
		GameManager.add_vigilance(15)
		
		await get_tree().create_timer(2).timeout
		_show_training_video("phishing")
	else:
		score_text += "\nCertains mails étaient mal identifiés. Réessayez !"
		GameManager.remove_vigilance(5)
		await get_tree().create_timer(3.0).timeout
		_pick_random_mails()
	
	result_label.text = score_text

func _show_training_video(video_id):
	var video_panel = get_parent().get_node("VideoPanel")
	if video_panel:
		visible = false
		video_panel.show_video(video_id)
		video_panel.video_closed.connect(_on_video_closed, CONNECT_ONE_SHOT)

func _on_video_closed():
	visible = true
	var browser = get_tree().get_nodes_in_group("browser_window")
	if browser.size() > 0:
		browser[0].close_window()
