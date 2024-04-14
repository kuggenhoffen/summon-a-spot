extends Button
class_name UILevelItem


@onready var level_name_label: Label = $PanelContainer/HBoxContainer/LevelLabel
@onready var level_medal: TextureRect = $PanelContainer/HBoxContainer/Medal
@onready var level_medal_showcase: MedalShowcaseUI = $PanelContainer/HBoxContainer/MedalShowcase

var level_name: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func set_level_data(finish_time: float, level_info: LevelInfo):
    level_name_label.text = level_info.level_name
    var medal: Utils.Medal = Utils.Medal.NONE
    level_name_label.text += "    " + Utils.format_time(finish_time)
    medal = Utils.get_medal(finish_time, level_info)
    level_medal.reveal(0, medal)
    level_medal_showcase.set_times(level_info)