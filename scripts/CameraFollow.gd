extends Camera3D
class_name CameraFollow

const LERP_SPEED: float = 2.0

@export var target: Node3D = null
@export var target_offset: Vector3 = Vector3.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if target:
        var target_position: Vector3 = target.global_position + target_offset
        global_position = global_position.lerp(target_position, LERP_SPEED * delta)
    