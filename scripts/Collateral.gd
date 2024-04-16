extends PhysicsBody3D
class_name Collateral

@export var penalty_time: float
@export var penalty_reason: String
var penalty_applied: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func apply_penalty() -> Penalty:
    if penalty_applied:
        return null
    penalty_applied = true
    return Penalty.new(penalty_time, penalty_reason)
