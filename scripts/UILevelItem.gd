extends Button
class_name UILevelItem

@export var level_name_label: Label = null

var level_name: String = ""
var medals: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    if level_name_label:
        level_name_label.text = level_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
