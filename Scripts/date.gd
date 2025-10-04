extends Node2D

func _ready():
    var day_progress = 0
    var month_progress = 0
    var year_progress = 0
    var path = "user://date.dat"

    if FileAccess.file_exists(path):
        var file = FileAccess.open(path, FileAccess.READ)
        day_progress = file.get_var()
        month_progress = file.get_var()
        year_progress = file.get_var()
        file.close()

    var month = 11 + month_progress
    var day = 25 + day_progress
    var year = 1987 + year_progress

    while true:
        var changed = false
        match month:
            1,3,5,7,8,10,12:
                if day > 31:
                    day -= 31
                    month += 1
                    changed = true
            4,6,9,11:
                if day > 30:
                    day -= 30
                    month += 1
                    changed = true
            2:
                var max_day = 28
                if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
                    max_day = 29
                if day > max_day:
                    day -= max_day
                    month += 1
                    changed = true
        if month > 12:
            month -= 12
            year += 1
            changed = true
        if not changed:
            break

    var label = get_node("Menu/6") if has_node("Menu/6") else null
    if label:
        label.text = "Date: %d/%d/%d" % [month, day, year]
    else:
        print("Label node not found!")


    day_progress = day - 25
    month_progress = month - 11
    year_progress = year - 1987
    var file = FileAccess.open(path, FileAccess.WRITE)
    file.store_var(day_progress)
    file.store_var(month_progress)
    file.store_var(year_progress)
    file.store_var(year)
    file.store_var(month)
    file.store_var(year_progress)
    file.close()
