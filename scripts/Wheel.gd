extends VehicleWheel3D
class_name Wheel

signal on_popped()

var area: Area3D = null
var popped: bool = false
var popped_steering_effect: float = 0.0
var popped_steering_target: float = 0.0
var popped_steering_timer: float = 0.0
var max_steering_angle: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    area = find_child("WheelArea")
    area.connect("area_entered", on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _physics_process(delta):
    if popped and use_as_steering:
        if popped_steering_timer <= 0:
            popped_steering_timer = randf_range(0.5, 1)
            popped_steering_target = randf_range(-max_steering_angle, max_steering_angle)
        else:
            popped_steering_timer -= delta
        popped_steering_effect = lerp(popped_steering_effect, popped_steering_target, 0.1)
        steering = clamp(get_steering() + popped_steering_effect, -max_steering_angle, max_steering_angle)
        print("Steering effect ", steering)

func on_area_entered(other: Node3D) -> void:
    if other is Nails:
        if not popped:
            popped = true
            print("Nails entered")
            on_popped.emit()
            set_suspension_rest_length(0.05)

