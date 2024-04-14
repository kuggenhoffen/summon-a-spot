extends HBoxContainer
class_name MedalShowcaseUI

@onready var bronze_time: Label = $BronzeTime
@onready var silver_time: Label = $SilverTime
@onready var gold_time: Label = $GoldTime

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func set_times(level_info: LevelInfo):
    bronze_time.text = Utils.format_time(Utils.get_medal_time(Utils.Medal.BRONZE, level_info))
    silver_time.text = Utils.format_time(Utils.get_medal_time(Utils.Medal.SILVER, level_info))
    gold_time.text = Utils.format_time(Utils.get_medal_time(Utils.Medal.GOLD, level_info))