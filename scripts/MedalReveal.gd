extends TextureRect
class_name MedalReveal


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func reveal(time: float = 0.0, medal: Utils.Medal = Utils.Medal.NONE, callback: Callable = Callable()) -> void:
    set_modulate(Color.BLACK)
    if medal != Utils.Medal.NONE:
        texture = Utils.medal_textures[medal]
        var tween = create_tween()
        print("Revealing medal ", medal, " in ", time, " seconds")
        tween.tween_property(self, "modulate", Color.WHITE, time)
        tween.tween_callback(callback)
