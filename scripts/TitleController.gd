extends Node3D

const level_directory: String = "res://prefabs/levels"
const level_item_ui_prefab: PackedScene = preload("res://prefabs/ui/level_item.tscn")

@onready var level_select: Control = $LevelSelect
@export var level_select_focus: Control = null
@onready var level_select_container: Control = $LevelSelect/Panel/ScrollContainer/LevelSelectContainer
@onready var main_screen: Control = $Main/StartMenu
@onready var main_screen_focus: Control = $Main/StartMenu/StartMenuContainer/StartBtn
@onready var options_screen: Control = $Main/OptionsContainer
@onready var options_screen_master_slider: Control = $Main/OptionsContainer/MarginContainer/HBoxContainer2/MasterSlider

# Called when the node enters the scene tree for the first time.
func _ready():
    show_main_screen()
    populate_levels()
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Utils.get_setting("audio/master_volume_db", -5))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_start_btn_pressed():
    show_level_select()


func _on_options_btn_pressed():
    show_options_screen()

func _on_exit_btn_pressed():
    get_tree().quit()


func _on_level_select_back_btn_pressed():
    show_main_screen()


func show_main_screen():
    main_screen.show()
    options_screen.hide()
    level_select.hide()
    main_screen_focus.grab_focus()

func show_level_select():
    level_select.show()
    main_screen.hide()
    options_screen.hide()
    level_select_focus.grab_focus()

func show_options_screen():
    options_screen.show()
    main_screen.hide()
    level_select.hide()
    options_screen_master_slider.grab_focus()
    options_screen_master_slider.set_value_no_signal(Utils.get_setting("audio/master_volume_db", -5))
    

func populate_levels():
    var scores = ScoreHandler.load_scores()
    var levels: Array[LevelInfo] = Utils.get_levels()
    var first_item: Control = null
    for level_info in levels:
        var level_item = level_item_ui_prefab.instantiate()
        level_select_container.add_child(level_item)
        var level_time: float = scores.get(level_info.level_name, 0)
        level_item.set_level_data(level_time, level_info)
        level_item.pressed.connect(on_level_item_pressed.bind(level_info.level_path))
        if first_item == null:
            first_item = level_item
    level_select_focus = first_item

func on_level_item_pressed(level_path: String):
    get_tree().change_scene_to_file(level_path)


func _on_options_back_btn_pressed():
    show_main_screen()


func _on_master_slider_value_changed(value: float):
    print("Value changed: ", value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
    Utils.set_setting("audio/master_volume_db", value)
