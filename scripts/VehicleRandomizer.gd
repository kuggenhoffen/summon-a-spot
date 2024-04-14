extends Node

@export var bodies : Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
    for body in bodies:
        body.visible = false
    bodies.pick_random().visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
