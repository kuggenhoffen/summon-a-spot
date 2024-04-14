extends Area3D
class_name DeathPlane

# Called when the node enters the scene tree for the first time.
func _ready():
    body_entered.connect(on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func on_body_entered(body: Node3D):
    print("Death plane hit, ", body)
    if body is VehicleController:
        body.death_plane_hit()
