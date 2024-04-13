extends VehicleBody3D
class_name VehicleController

const ACCEL_FORCE_FORWARD: float = 50
const ACCEL_FORCE_BACKWARD: float = 25
const BRAKE_FORCE: float = 1
const STEER_SPEED: float = 1.5
const CENTERING_SPEED: float = 1.5
const ENGINE_SPEED: float = 2
const REVERSE_SWITCH_DURATION_SECONDS: float = 0.25
const MAX_STEERING_ANGLE: float = deg_to_rad(30)

var forward_input: float = 0
var backward_input: float = 0
var steer_input: float = 0

var engine: float = 0
var steer: float = 0
var braking: bool = false
var reverse: bool = false
var reverse_timer: float = 0.0

var wheels: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.
    freeze = false
    for child in get_children():
        if child is Wheel:
            wheels.append(child)
            child.on_popped.connect(on_wheel_popped.bind(child))
            child.max_steering_angle = MAX_STEERING_ANGLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    forward_input = Input.get_action_strength("forward")
    steer_input = Input.get_action_strength("left") - Input.get_action_strength("right")
    backward_input = Input.get_action_strength("backward")
    if Input.is_action_just_pressed("escape"):
        get_tree().quit()


func _physics_process(delta):
    var brake_amount: float = 0.0
    var engine_force_amount = 0.0
    if steer_input != 0.0:
        steer = steer + (steer_input * STEER_SPEED * delta)
    else:
        # Centering force
        var dir = sign(steer)
        if steer > 0.0:
            steer = steer - (CENTERING_SPEED * delta)
        elif steer < 0.0:
            steer = steer + (CENTERING_SPEED * delta)
        if dir != sign(steer):
            steer = 0.0
    steer = clamp(steer, -MAX_STEERING_ANGLE, MAX_STEERING_ANGLE)
    
    var local_velocity: Vector3 = get_linear_velocity() * global_basis
    if not reverse:
        # Going forward
        if forward_input != 0.0:
            engine = engine + (forward_input * ENGINE_SPEED * delta)
        else:
            engine = engine - (2.0 * ENGINE_SPEED * delta)
            if engine < 0.0:
                engine = 0.0
        engine = clamp(engine, -1.0, 1.0)
        engine_force_amount = engine * ACCEL_FORCE_FORWARD
        brake_amount = backward_input
        if local_velocity.y < 0.1 and brake_amount > 0.0:
            reverse_timer += delta
            if reverse_timer > REVERSE_SWITCH_DURATION_SECONDS:
                reverse = true
                reverse_timer = 0.0
        else:
            reverse_timer = 0.0
    else:
        # Going backward
        if backward_input != 0.0:
            engine = engine - (backward_input * ENGINE_SPEED * delta) * ACCEL_FORCE_BACKWARD
        else:
            engine = engine - (2.0 * ENGINE_SPEED * delta) * ACCEL_FORCE_BACKWARD
            if engine < 0.0:
                engine = 0.0
        engine = clamp(engine, -1.0, 1.0)
        engine_force_amount = engine * ACCEL_FORCE_BACKWARD
        brake_amount = forward_input
        if local_velocity.y > -0.1 and brake_amount > 0.0:
            reverse_timer += delta
            if reverse_timer > REVERSE_SWITCH_DURATION_SECONDS:
                reverse = false
                reverse_timer = 0.0
        else:
            reverse_timer = 0.0

    # Apply steering
    set_steering(steer)
    set_engine_force(engine_force_amount)
    set_brake(brake_amount * BRAKE_FORCE)

func on_wheel_popped(wheel: Wheel):
    print("Wheel popped: ", wheel.position)
    apply_impulse(Vector3.UP * 20.0, wheel.global_position - global_position)