extends Sprite2D

const MALE_FIRST_NAMES = ["Liam","Noah","Aiden","Lucas","Ethan","Mason","Logan","James","Benjamin","Henry"]
const FEMALE_FIRST_NAMES = ["Emma","Olivia","Sophia","Mia","Isabella","Amelia","Harper","Ella","Charlotte","Avery"]
const LAST_NAMES = ["Anderson","Johnson","Thompson","Martinez","Clark","Robinson","Walker","Hall","Young","Allen","Wright","King","Scott","Green","Adams","Baker","Nelson","Carter","Mitchell","Perez"]
const US_STATES = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]

var dateday = 0
var datemonth = 0
var dateyear = 0
var name1 = []
var name2 = []
var id = ""
var exp_date = ""
var dob = ""
var issue = ""
var gender = 0
var id_badge
var license

func _ready():
    add_to_group("document_generator")
    var file = FileAccess.open("user://date.dat", FileAccess.READ)
    file.get_var(); file.get_var(); file.get_var()
    dateyear = file.get_var()
    datemonth = file.get_var()
    dateday = file.get_var()
    file.close()
    generate()

func generate():
    # Get the sprite index from the animation controller
    var char_node = get_parent().get_node("Char")
    var sprite_index = 0
    
    if char_node and char_node.has_method("get_current_sprite_index"):
        sprite_index = char_node.get_current_sprite_index()
    
    # Determine gender based on sprite index
    # Sprites 0-1 are male
    # Sprites 2-3 are female
    gender = 0 if sprite_index <= 1 else 1
    
    name1 = generate_name(gender)
    name2 = generate_name(randi_range(0, 1))
    exp_date = generate_date(dateyear, dateyear + 5, true)
    dob = generate_date(dateyear - 58, dateyear - 18, false)
    issue = generate_date(dateyear - 4, dateyear, false)
    id = generate_id()
    set_character_sprite(sprite_index)
    display()

func set_character_sprite(sprite_index: int):
    var characters = get_parent().get_node("Char/Characters")
    # Set the character frame to match the sprite index (0-3)
    characters.frame = sprite_index

func generate_id():
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789"
    var result = ""
    for i in range(8):
        result += chars[randi() % chars.length()]
    return result

func generate_name(is_male: int):
    var first = MALE_FIRST_NAMES[randi() % MALE_FIRST_NAMES.size()] if is_male == 0 else FEMALE_FIRST_NAMES[randi() % FEMALE_FIRST_NAMES.size()]
    return [first, LAST_NAMES[randi() % LAST_NAMES.size()]]

func generate_date(year_min: int, year_max: int, after: bool = true):
    var year = randi_range(year_min, year_max)
    var month = randi_range(1, 12)
    var max_day = 31 if month in [1,3,5,7,8,10,12] else (29 if month == 2 and ((year % 4 == 0 and year % 100 != 0) or year % 400 == 0) else 28)
    var start_day = 1
    if after and year == dateyear and month == datemonth:
        start_day = dateday + 1
    elif not after and year == dateyear and month == datemonth:
        max_day = dateday - 1
    if start_day > max_day:
        start_day = max_day
    return str(month) + "/" + str(randi_range(start_day, max_day)) + "/" + str(year)

func display():
    randomize()
    var font := load("res://Fonts/" + str(randi_range(1,4)) + ".ttf") as Font
    var font1 := load("res://Fonts/" + str(randi_range(1,4)) + ".ttf") as Font

    id_badge = get_parent().get_node("Documents/IdBadge")
    license = get_parent().get_node("Documents/License")

    id_badge.get_node("State").text = "California"
    id_badge.get_node("ID").text = "ID: " + id
    id_badge.get_node("Dob").text = "DOB: " + dob
    id_badge.get_node("Exp").text = "EXP: " + exp_date
    id_badge.get_node("Fn").text = "LN: " + name1[1]
    id_badge.get_node("Ln").text = "FN: " + name1[0]
    id_badge.get_node("Name Sig").text = name1[0] + name1[1]
    id_badge.get_node("Name Sig").add_theme_font_override("font", font)
    id_badge.get_node("Profile Picture").frame = get_parent().get_node("Char/Characters").frame

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

    if randi_range(0,2) == 2:
        sabotage()

func sabotage():
    randomize()
    var font := load("res://Fonts/" + str(randi_range(1,4)) + ".ttf") as Font

    match randi_range(0,13):
        0: id_badge.get_node("State").text = US_STATES[randi() % LAST_NAMES.size()]
        1: id_badge.get_node("ID").text = "ID: " + generate_id()
        2: id_badge.get_node("Dob").text = "DOB: " + generate_date(dateyear - 58, dateyear - 18, false)
        3: id_badge.get_node("Exp").text = "EXP: " + generate_date(dateyear - 3, dateyear, false)
        4:
            name1 = generate_name(randi_range(0,1))[0]
            name2 = generate_name(randi_range(0,1))[1]
            id_badge.get_node("Ln").text = "LN: " + name1
            id_badge.get_node("Fn").text = "FN: " + name2
            id_badge.get_node("Name Sig").text = name1 + name2
        5: id_badge.get_node("Name Sig").add_theme_font_override("font", font)
        6: id_badge.get_node("IdGold").visible = false
        7:
            if randi_range(1,2) == 1:
                id_badge.get_node("IdStamp").frame = randi_range(1, id_badge.get_node("IdStamp").sprite_frames.get_frame_count("default") - 1)
            else:
                id_badge.get_node("IdStamp").scale = Vector2(0.5, 0.5)
                id_badge.get_node("IdStamp").position = Vector2(92.0, 38.8)
        8: license.get_node("State").text = US_STATES[randi() % LAST_NAMES.size()] + " Department of Justice"
        9:
            var r = randi_range(1,3)
            if r in [1,2]:
                license.get_node("Stamp").frame = randi_range(1, license.get_node("Stamp").sprite_frames.get_frame_count("default") - 1)
            else:
                license.get_node("Stamp").scale = Vector2(0.9, 0.9)
        10: license.get_node("Doj Name").text = generate_name(randi_range(0,1))[0] + " " + generate_name(randi_range(0,1))[1]
        11: license.get_node("Issue").text = "Issue Date: " + generate_date(dateyear, dateyear + 1, true)
        12: license.get_node("Exp").text = "EXP: " + generate_date(dateyear - 3, dateyear, false)
        13:
            while get_parent().get_node("Char/Characters").frame == id_badge.get_node("Profile Picture").frame:
                id_badge.get_node("Profile Picture").frame = randi_range(0, 3)
