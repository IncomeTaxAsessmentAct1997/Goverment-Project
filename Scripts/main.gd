extends Sprite2D
var dateday = 0
var datemonth = 0
var dateyear = 0
var name1 = []
var name2 = []
var id = ""
var exp_date = []
var dob = []
var issue = []
var male_first_names = ["Liam","Noah","Aiden","Lucas","Ethan","Mason","Logan","James","Benjamin","Henry"]
var female_first_names = ["Emma","Olivia","Sophia","Mia","Isabella","Amelia","Harper","Ella","Charlotte","Avery"]
var last_names = ["Anderson","Johnson","Thompson","Martinez","Clark","Robinson","Walker","Hall","Young","Allen","Wright","King","Scott","Green","Adams","Baker","Nelson","Carter","Mitchell","Perez"]
var font_numb1
var font_numb2
var id_badge
var license

func _ready():
    var file = FileAccess.open("user://date.dat", FileAccess.READ)
    var _a = file.get_var()
    var _b = file.get_var()
    var _c = file.get_var()
    dateyear = file.get_var()
    datemonth = file.get_var()
    dateday = file.get_var()
    file.close()
    generate()

func generate():
    name1 = generate_name(0)
    name2 = generate_name(randi_range(1,2))   
    exp_date = generate_date(dateyear, dateyear + 5, true)
    dob = generate_date(dateyear - 58, dateyear - 18, false)
    issue = generate_date(dateyear - 4, dateyear, false) 
    id = generate_id()
    display()

func generate_id():
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789"
    id = ""
    for i in range(8):
        id += chars[randi() % chars.length()]
    return id

func generate_name(is_male: int):
    var first_name = ""
    if is_male == 0:
        first_name = male_first_names[randi() % male_first_names.size()]
    else:
        first_name = female_first_names[randi() % female_first_names.size()]
   
    var last_name = last_names[randi() % last_names.size()]
    return [first_name, last_name]

func generate_date(year_min: int, year_max: int, after: bool = true):
    var year = randi_range(year_min, year_max)
    var month = randi_range(1, 12)
    var max_day = 31 if month in [1, 3, 5, 7, 8, 10, 12] else 30
    if month == 2:
        max_day = 29 if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0) else 28
    var start_day = 1
    if after and year == dateyear and month == datemonth:
        start_day = dateday + 1
    elif not after and year == dateyear and month == datemonth:
        max_day = dateday - 1
    if start_day > max_day:
        start_day = max_day
    var day = randi_range(start_day, max_day)
    return str(month) + "/" + str(day) + "/" + str(year)
    
func display():
    randomize()
    font_numb1 = str(randi_range(1,4))
    font_numb2 = str(randi_range(1,4))
    var font := load("res://Fonts/" + font_numb1 + ".ttf") as Font
    var font1 := load("res://Fonts/" + font_numb2 + ".ttf") as Font
    id_badge = get_parent().get_node("IdBadge")
    license = get_parent().get_node("License")
    
    id_badge.get_node("State").text = "California"
    id_badge.get_node("ID").text = "ID: " + id
    id_badge.get_node("Dob").text = "DOB: " + dob
    id_badge.get_node("Exp").text = "EXP: " + exp_date
    id_badge.get_node("Fn").text = "LN: " + name1[1]
    id_badge.get_node("Ln").text = "FN: " + name1[0]
    id_badge.get_node("Name Sig").text = name1[0] + name1[1]
    id_badge.get_node("Name Sig").add_theme_font_override("font", font)
    
    license.get_node("State").text = "California Department of Justice"
    license.get_node("Issue").text = "Issue Date: " + issue
    license.get_node("Exp").text = "Exp Date: " + exp_date
    license.get_node("Dob").text = "DOB: " + dob
    license.get_node("Name").text = "Issued To: " + name1[0] + " " + name1[1]
    license.get_node("Number").text = "ID NO: " + id
    license.get_node("Doj Name").text = name2[0] + " " + name2[1]
    license.get_node("Doj Sig").text = name2[0] + name2[1]
    license.get_node("Name Sig").text = name1[0] + name1[1]
    license.get_node("Name Sig").add_theme_font_override("font", font)
    license.get_node("Doj Sig").add_theme_font_override("font", font1)
    
    if randi_range(1,3) == 3:
        sabotage()

func sabotage():
    randomize()
    var us_states = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
    var font_numb3 = str(randi_range(1,4))
    while font_numb3 == font_numb1 or font_numb3 == font_numb2:
        font_numb3 = str(randi_range(1,4))
    var font := load("res://Fonts/" + font_numb3 + ".ttf") as Font

    match randi_range(0,11):
        0:
            id_badge.get_node("State").text = us_states[randi() % last_names.size()]
        1:
            id_badge.get_node("ID").text = "ID: " + generate_id()
        2: 
            id_badge.get_node("Dob").text = "DOB: " + generate_date(dateyear - 58, dateyear - 18, false)
        3:
            id_badge.get_node("Exp").text = "EXP: " + generate_date(dateyear, dateyear + 5, true)
        4:
            name1 = generate_name(randi_range(0,1))[0]
            name2 = generate_name(randi_range(0,1))[1]
            id_badge.get_node("Fn").text = "LN: " + name1
            id_badge.get_node("Ln").text = "FN: " + name2
            id_badge.get_node("Name Sig").text = name1 + name2
        5:
            id_badge.get_node("Name Sig").add_theme_font_override("font", font)
        6:
            id_badge.get_node("IdGold").visible = false
        7:
            if randi_range(1,2) == 1:
                id_badge.get_node("IdStamp").frame = randi_range(1, id_badge.get_node("IdStamp").sprite_frames.get_frame_count("default") - 1)
            else:
                id_badge.get_node("IdStamp").scale = Vector2(0.5, 0.5)
                id_badge.get_node("IdStamp").position = Vector2(92.0, 38.8)
        8:
            license.get_node("State").text = us_states[randi() % last_names.size()] + " Department of Justice"
        9:
            var random = randi_range(1,3)
            if random in [1,2]:
                license.get_node("Stamp").frame = randi_range(1, license.get_node("Stamp").sprite_frames.get_frame_count("default") - 1)
            else:
                license.get_node("Stamp").scale = Vector2(0.9, 0.9)
        10:
            var temp_name = generate_name(randi_range(0,1))
            license.get_node("Doj Name").text = temp_name[0] + " " + temp_name[1]
        11:
            license.get_node("Issue").text = "Issue Date: " + generate_date(dateyear, dateyear + 1, true)
