class_name ScoreHandler

const SCORE_FILE: String = "user://data.json"

static func load_scores() -> Dictionary:
    var score_data: Dictionary = {}
    var file = FileAccess.open(SCORE_FILE, FileAccess.READ)
    if file != null:
        var json_data = file.get_as_text()
        var json_reader = JSON.new()
        var error = json_reader.parse(json_data)
        if error == OK:
            score_data = json_reader.data
    return score_data

static func save_scores(scores: Dictionary) -> void:
    var file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)
    if file != null:
        var json = JSON.stringify(scores)
        file.store_string(json)

static func update_score(level_info: LevelInfo, time: float):
    var score_data: Dictionary = load_scores()
    var old_time: int = score_data.get(level_info.level_name, 0)
    if old_time == 0 or time < old_time:
        score_data[level_info.level_name] = time
    save_scores(score_data)
    