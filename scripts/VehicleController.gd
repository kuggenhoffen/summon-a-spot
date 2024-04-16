extends VehicleBody3D
class_name VehicleController

signal tire_popped()
signal collateral_damage(penalty: Penalty)
signal fell_off()

const ACCEL_FORCE_FORWARD: float = 65
const ACCEL_FORCE_BACKWARD: float = 25
const BRAKE_FORCE: float = 2.5
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
var last_linear_velocity: Vector3 = Vector3.ZERO
var pop_count: int = 0

@onready var engine_audio: AudioStreamPlayer3D = $EngineAudioPlayer
@onready var crash_audio: AudioStreamPlayer3D = $CrashAudioPlayer
@onready var pop_audio: AudioStreamPlayer3D = $PopAudioPlayer
@onready var screech_audio: AudioStreamPlayer3D = $TireScreechAudioPlayer
@onready var dragging_audio: AudioStreamPlayer3D = $DraggingAudioPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
    for child in get_children():
        if child is Wheel:
            wheels.append(child)
            child.popped.connect(on_tire_popped.bind(child))
            child.max_steering_angle = MAX_STEERING_ANGLE
    screech_audio.set_volume_db(-80)
    dragging_audio.set_volume_db(-80)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    forward_input = Input.get_action_strength("forward")
    steer_input = Input.get_action_strength("left") - Input.get_action_strength("right")
    backward_input = Input.get_action_strength("backward")
    if screech_audio.playing == freeze:
        screech_audio.playing = !freeze
    if engine_audio.playing == freeze:
        engine_audio.playing = !freeze

func _physics_process(delta):
    update_audio()
    var linear_velocity_change: Vector3 = get_linear_velocity() - last_linear_velocity
    #print("Last linear velocity: ", last_linear_velocity.length())
    if linear_velocity_change.length() > 0.3:
        for b in get_colliding_bodies():
            if b is Collateral:
                collateral_damage.emit(b.apply_penalty())
            crash_audio.play()
    last_linear_velocity = get_linear_velocity()
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

func on_tire_popped(wheel: Wheel):
    apply_impulse(Vector3.UP * 20.0, wheel.global_position - global_position)
    tire_popped.emit()
    pop_audio.play()
    if not dragging_audio.playing:
        dragging_audio.play()
    pop_count += 1


func death_plane_hit():
    fell_off.emit()

func update_audio():
    var wheel_speed: float = 0.0
    var count: int = 0
    var slipping: float = 0
    for wheel in wheels:
        if wheel.use_as_traction:
            wheel_speed += wheel.get_rpm()
            count += 1
        slipping += wheel.get_skidinfo()
    if count > 0:
        wheel_speed /= count
    slipping /= float(wheels.size())
    screech_audio.volume_db = lerp(-10, -80, clampf(inverse_lerp(0.5, 1.0, slipping), 0.0, 1.0))
    engine_audio.set_pitch_scale(lerp(0.4, 1.5, abs(wheel_speed) / 300.0))
    if pop_count > 0:
        dragging_audio.set_volume_db(lerp(-80, -5,  last_linear_velocity.length() / 4 * pop_count))