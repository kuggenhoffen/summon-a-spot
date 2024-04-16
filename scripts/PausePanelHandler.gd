extends PanelContainer
class_name PausePanelHandler

signal restart_pressed()
signal menu_pressed()
signal resume_pressed()

@onready var restart_button = $VBoxContainer/Panel2/ButtonsContainer/RestartBtn
@onready var menu_button = $VBoxContainer/Panel2/ButtonsContainer/MenuBtn
@onready var resume_button = $VBoxContainer/Panel2/ButtonsContainer/ResumeBtn
@onready var medal_showcase = $VBoxContainer/Panel6/MedalShowcase

# Called when the node enters the scene tree for the first time.
func _ready():
    restart_button.pressed.connect(on_restart_pressed)
    menu_button.pressed.connect(on_menu_pressed)
    resume_button.pressed.connect(on_resume_pressed)
    
func _process(_delta):
    if is_visible() and Input.is_action_just_pressed("ui_cancel"):
        unpause()

func visibility_changed():
    if is_visible():
        print("Grabbing focus")
        resume_button.grab_focus.call_deferred()

func on_restart_pressed():
    Utils.restart_scene(get_tree())

func on_menu_pressed():
    Utils.show_menu_scene(get_tree())

func on_resume_pressed():
    unpause()

func on_next_level_pressed():
    pass

func unpause():
    get_tree().paused = false
    hide()

func pause():
    get_tree().paused = true
    show()
    resume_button.grab_focus()

func set_level_info(level_info: LevelInfo):
    medal_showcase.set_times(level_info)