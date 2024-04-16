class_name Utils

const level_directory: String = "res://prefabs/levels"

const medal_textures = {
    Utils.Medal.BRONZE: preload("res://textures/medal_bronze.png"),
    Utils.Medal.SILVER: preload("res://textures/medal_silver.png"),
    Utils.Medal.GOLD: preload("res://textures/medal_gold.png")
}

enum Medal {
    NONE,
    BRONZE,
    SILVER,
    GOLD
}

static func format_time(time: float) -> String:
    var seconds: int = int(time)
    var minutes: int = int(seconds / 60)
    var msecs: int = int((time - seconds) * 100)
    return str(minutes) + ":" + str(seconds % 60).pad_zeros(2) + "." + str(msecs).pad_zeros(2)

static func get_medal(time: float, level_info: LevelInfo) -> Medal:
    if time == 0 or time > get_medal_time(Medal.BRONZE, level_info):
        return Medal.NONE
    elif time > get_medal_time(Medal.SILVER, level_info):
        return Medal.BRONZE
    elif time > get_medal_time(Medal.GOLD, level_info):
        return Medal.SILVER
    return Medal.GOLD

static func get_medal_time(medal: Medal, level_info: LevelInfo) -> float:
    return level_info.medal_times[medal - 1]

static func get_level_info(level_path: String) -> Resource:
    var level = ResourceLoader.load(level_path)
    for node_index in range(level.get_state().get_node_count()):
        if level.get_state().get_node_name(node_index) == "Level":
            for prop_index in range(level.get_state().get_node_property_count(node_index)):
                if level.get_state().get_node_property_name(node_index, prop_index) == "metadata/level_info":
                    return level.get_state().get_node_property_value(node_index, prop_index)
    return null
    
static func get_level_path(level_filename: String) -> String:
    return level_directory + "/" + level_filename

static func get_levels() -> Array[LevelInfo]:
    var levels: Array[LevelInfo] = []
    var temp_levels = DirAccess.get_files_at(level_directory)
    for level_filename in temp_levels:
        var level_path: String = get_level_path(level_filename.trim_suffix(".remap"))
        var level_info = get_level_info(level_path)
        if level_info == null:
            continue
        level_info.level_path = level_path
        levels.append(level_info)
    return levels

static func restart_scene(tree: SceneTree) -> void:
    var restart: Callable = func _restart_scene():
        tree.reload_current_scene()
        tree.set_pause(false)
    restart.call_deferred()

static func show_menu_scene(tree: SceneTree) -> void:
    var show_menu: Callable = func _show_menu_scene():
        tree.change_scene_to_file("res://scenes/title.tscn")
        tree.set_pause(false)
    show_menu.call_deferred()

static func load_next_or_menu(tree: SceneTree, current_level: LevelInfo):
    var load_next: Callable =  func():
        #tree.set_pause(false)
        var levels = get_levels()
        var next_level_index = levels.find(current_level) + 1
        if next_level_index < levels.size():
            var next_level = levels[next_level_index]
            tree.change_scene_to_file(next_level.level_path)
        else:
            show_menu_scene(tree)
        tree.set_pause(false)
    load_next.call_deferred()


static func set_setting(setting: String, value: Variant) -> void:
    var config = ConfigFile.new()
    config.load("user://settings.cfg")
    config.set_value("settings", setting, value)
    config.save("user://settings.cfg")

static func get_setting(setting: String, default_value: Variant) -> Variant:
    var config = ConfigFile.new()
    if not config.load("user://settings.cfg") == OK:
        return default_value
    return config.get_value("settings", setting, default_value)
