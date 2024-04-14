extends Area3D
class_name Goal

const REQUIRED_TIME_WITHIN_AREA_SECONDS: float = 3.0

signal player_in_goal_area(time_left: float)
signal player_left_goal_area()

@export var collision_shape: CollisionShape3D = null

var player_body: Node3D = null
var time_left_until_finish: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    body_entered.connect(on_body_entered)
    body_exited.connect(on_body_exited)


func _physics_process(delta):
    if player_body:
        if check_wheel_overlaps(player_body):
            time_left_until_finish -= delta
            player_in_goal_area.emit(time_left_until_finish)
        elif time_left_until_finish < REQUIRED_TIME_WITHIN_AREA_SECONDS:
            time_left_until_finish = REQUIRED_TIME_WITHIN_AREA_SECONDS
            player_left_goal_area.emit()
            

func check_wheel_overlaps(body: Node3D):
    for child in body.get_children():
        if child is VehicleWheel3D:
            var wheel_area: Area3D = child.find_child("WheelArea")
            if not overlaps_area(wheel_area):
                return false
    return true


func on_body_entered(body: Node3D):
    print("Body entered, ", body.name)
    if body.is_in_group("player"):
        player_body = body


func on_body_exited(body: Node3D):
    if body.is_in_group("player"):
        player_body = null

