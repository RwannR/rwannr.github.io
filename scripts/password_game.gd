extends VBoxContainer

@onready var password_input = $PasswordInput
@onready var show_password = $ShowPassword
@onready var strength_bar = $StrengthBar
@onready var strength_label = $StrengthLabel
@onready var criteria_list = $CriteriaList
@onready var blacklist_warning = $BlacklistWarning
@onready var validate_btn = $ValidateBtn
@onready var result_label = $Result

var blacklist = [
	"password", "password123", "motdepasse", "motdepasse123",
	"123456", "123456789", "qwerty", "azerty", "admin",
	"letmein", "welcome", "master", "login", "abc123",
	"111111", "000000", "1234567890"
]

var criteria = {
	"length_8": {"label": "Au moins 8 caractères", "met": false},
	"length_12": {"label": "Au moins 12 caractères (recommandé)", "met": false},
	"uppercase": {"label": "Au moins une majuscule", "met": false},
	"lowercase": {"label": "Au moins une minuscule", "met": false},
	"digit": {"label": "Au moins un chiffre", "met": false},
	"symbol": {"label": "Au moins un caractère spécial (!@#$...)", "met": false},
}

func _ready():
	password_input.text_changed.connect(_on_password_changed)
	show_password.toggled.connect(_on_toggle_show)
	validate_btn.pressed.connect(_on_validate)
	_build_criteria_labels()
	_update_display("")

func on_window_opened():
	if QuestManager.get_quest("q_password").get("status", "") == "completed":
		visible = false
		var video_panel = get_parent().get_node("VideoPanel")
		if video_panel:
			video_panel.show_replay_button("password")
	else:
		visible = true

func _build_criteria_labels():
	for key in criteria:
		var label = Label.new()
		label.name = key
		label.text = "✗ " + criteria[key].label
		criteria_list.add_child(label)

func _on_toggle_show(toggled):
	password_input.secret = not toggled

func _on_password_changed(new_text):
	_update_display(new_text)

func _update_display(password):
	# Vérifie chaque critère
	criteria.length_8.met = password.length() >= 8
	criteria.length_12.met = password.length() >= 12
	criteria.uppercase.met = false
	criteria.lowercase.met = false
	criteria.digit.met = false
	criteria.symbol.met = false
	
	for c in password:
		if c >= "A" and c <= "Z":
			criteria.uppercase.met = true
		elif c >= "a" and c <= "z":
			criteria.lowercase.met = true
		elif c >= "0" and c <= "9":
			criteria.digit.met = true
		else:
			criteria.symbol.met = true
	
	# Met à jour les labels
	for key in criteria:
		var label = criteria_list.get_node(key)
		if criteria[key].met:
			label.text = "✓ " + criteria[key].label
			label.modulate = Color(0.3, 0.9, 0.3)
		else:
			label.text = "✗ " + criteria[key].label
			label.modulate = Color(0.9, 0.3, 0.3)
	
	# Calcule le score de force
	var score = 0
	if criteria.length_8.met:
		score += 20
	if criteria.length_12.met:
		score += 15
	if criteria.uppercase.met:
		score += 15
	if criteria.lowercase.met:
		score += 15
	if criteria.digit.met:
		score += 15
	if criteria.symbol.met:
		score += 20
	
	strength_bar.value = score
	
	# Label de force
	if score < 30:
		strength_label.text = "Force : Très faible"
		strength_label.modulate = Color(0.9, 0.2, 0.2)
	elif score < 50:
		strength_label.text = "Force : Faible"
		strength_label.modulate = Color(0.9, 0.5, 0.2)
	elif score < 70:
		strength_label.text = "Force : Moyen"
		strength_label.modulate = Color(0.9, 0.9, 0.2)
	elif score < 90:
		strength_label.text = "Force : Fort"
		strength_label.modulate = Color(0.3, 0.9, 0.3)
	else:
		strength_label.text = "Force : Excellent"
		strength_label.modulate = Color(0.2, 1.0, 0.5)
	
	# Vérification blacklist
	if password.to_lower() in blacklist:
		blacklist_warning.text = "⚠ Ce mot de passe est dans la liste des mots de passe compromis !"
		blacklist_warning.modulate = Color(1, 0.3, 0.3)
	else:
		blacklist_warning.text = ""

func _on_validate():
	var password = password_input.text
	
	if password.to_lower() in blacklist:
		result_label.text = "Mot de passe refusé : il fait partie des mots de passe les plus piratés."
		result_label.modulate = Color(1, 0.3, 0.3)
		GameManager.remove_vigilance(5)
		return
	
	if strength_bar.value < 70:
		result_label.text = "Mot de passe trop faible. Renforcez-le avant de valider."
		result_label.modulate = Color(1, 0.5, 0.2)
		GameManager.remove_vigilance(5)
		return
	
	result_label.text = "Excellent ! Votre mot de passe est sécurisé."
	result_label.modulate = Color(0.3, 1, 0.5)
	validate_btn.disabled = true
	GameManager.add_vigilance(15)
	QuestManager.complete_quest("q_password")
	
	await get_tree().create_timer(2).timeout
	_show_training_video("password")

func _reset():
	password_input.text = ""
	validate_btn.disabled = false
	result_label.text = ""
	_update_display("")

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
