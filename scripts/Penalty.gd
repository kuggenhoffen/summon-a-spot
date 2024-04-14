class_name Penalty

@export var time: float = 0.0
@export var reason: String = ""

func _init(_time: float, _reason: String):
    time = _time
    reason = _reason

func _to_string():
    return reason + "(+" + str(time) + "s)"