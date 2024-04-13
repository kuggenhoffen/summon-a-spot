extends Node3D

const level_path: String = "res://prefabs/levels"
const level_item_ui_prefab: PackedScene = preload("res://prefabs/ui/level_item.tscn")

@export var level_select: Control = null
@export var level_select_focus: Control = null
@export var main_screen: Control = null
@export var main_screen_focus: Control = null
@export var level_select_container: Control = null

# Called when the node enters the scene tree for the first time.
func _ready():
    show_main_screen()
    populate_levels()

func get_level_name(level_file: String) -> String:
    var level = ResourceLoader.load(level_path + "/" + level_file)
    for node_index in range(level.get_state().get_node_count()):
        if level.get_state().get_node_name(node_index) == "Level":
            for prop_index in range(level.get_state().get_node_property_count(node_index)):
                if level.get_state().get_node_property_name(node_index, prop_index) == "metadata/level_name":
                    return level.get_state().get_node_property_value(node_index, prop_index)
    return level_file

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_start_btn_pressed():
    show_level_select()


func _on_options_btn_pressed():
    pass # Replace with function body.

func _on_exit_btn_pressed():
    get_tree().quit()


func _on_level_select_back_btn_pressed():
    show_main_screen()


func show_main_screen():
    main_screen.show()
    level_select.hide()
    main_screen_focus.grab_focus()

func show_level_select():
    level_select.show()
    main_screen.hide()
    level_select_focus.grab_focus()

func populate_levels():
    var temp_levels = DirAccess.get_files_at(level_path)
    for level_file in temp_levels:
        var level_item = level_item_ui_prefab.instantiate()
        level_item.level_name = get_level_name(level_file)
        level_select_container.add_child(level_item)
    level_select_focus = level_select_container.get_child(0)