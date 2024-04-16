extends Node

@export var bodies : Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
    show_randomized_body()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func show_randomized_body():
    for body in bodies:
        body.visible = false
    var body = bodies.pick_random()
    body.visible = true
    var uv_offset: float = 1.0 / randi_range(0, 15)
    for child in body.get_children():
        if child is MeshInstance3D:
            child.set_instance_shader_parameter("uv1_offset", Vector3(0, uv_offset, 0))
