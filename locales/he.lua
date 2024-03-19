local Translations = {
    error = {
        canceled = 'בוטח',
        bled_out = '...דיממת',
        impossible = '...פעולה בלתי אפשרית',
        no_player = 'אין שחקן בקרבת מקום',
        no_firstaid = 'אתה צריך ערכת עזרה ראשונה',
        no_bandage = 'אתה צריך תחבושות',
        beds_taken = '...המיטות תפוסות',
        possessions_taken = '...כל הרכוש שלך נלקח',
        not_enough_money = '...אין עליך מספיק כסף',
        cant_help = '...אינך יכול לעזור לאדם הזה',
        not_ems = 'אתה לא מד"א או לא רשום',
        not_online = 'שחקן לא מחובר'
    },
    success = {
        revived = 'החיית שחקן',
        healthy_player = 'שחקן בריא',
        helped_player = 'עזרת לאדם',
        wounds_healed = '!הפצעים שלך נרפאו',
        being_helped = '...עוזרים לך'
    },
    info = {
        civ_died = 'אזרח נפטר',
        civ_down = 'אזרח נפל',
        civ_call = 'קריאה מאזרח',
        self_death = 'עצמם או NPC',
        wep_unknown = 'לא ידוע',
        respawn_txt = 'חזור לחיים בעוד: ~r~%{deathtime}~s~ שניות',
        respawn_revive = 'לחץ והחזק [~r~E~s~] למשך %{holdtime} כדי לחזור לחיים במחיר של $~r~%{cost}~s~', 
        bleed_out = 'אתה תמות מחוסר דם בעוד: ~r~%{time}~s~ שניות',
        bleed_out_help = 'אתה תמות מחוסר דם בעוד: ~r~%{time}~s~ שניות, אפשר לעזור לך',
        request_help = 'לחץ [~r~G~s~] כדי לבקש עזרה',
        help_requested = 'מד"א הותראו',
        amb_plate = 'אמבו',  -- Should only be 4 characters long due to the last 4 being a random 4 digits
        heli_plate = 'חיים', -- Should only be 4 characters long due to the last 4 being a random 4 digits
        status = 'בדיקת מצב',
        is_status = 'הוא %{status}',
        healthy = '!אתה בריא לגמרי שוב',
        safe = 'בטוח בבית חולים',
        pb_hospital = 'בית חולים פילבוקס',
        paleto_hospital = 'בית חולים פלאטו', -- Paleto
        pain_message = 'ה %{limb} שלך מרגישה %{severity}', 
        many_places = '...כואב לך בהרבה מקומות',
        bleed_alert = 'אתה %{bleedstate}',
        ems_alert = 'התראת מד"א - %{text}',
        mr = 'אדון',
        mrs = 'גברת',
        dr_needed = 'רופא דרוש ב %{hospital}',
        ems_report = 'דוח מד"א',
        message_sent = 'הודעה שתשלח',
        check_health = 'בדוק את בריאות השחקנים',
        heal_player = 'לרפא שחקן',
        revive_player = 'להחיות שחקן',
        revive_player_a = 'החייאה שחקן או את עצמך (אדמין בלבד)',
        player_id = 'מזהה שחקן (יכול להיות ריק)',
        pain_level = 'הגדר את רמת הכאב שלך או של שחקן (אדמין בלבד)',
        kill = 'תהרוג שחקן או את עצמך (אדמין בלבד)',
        heal_player_a = 'רפא שחקן או את עצמך (אדמין בלבד)',
    },
    mail = {
        subject = 'עלות בית חולים',
        message = '%{gender} %{lastname} היקרים, <br /><br />בזאת קיבלת אימייל עם עלויות הביקור האחרון בבית החולים.<br />העלויות הסופיות הפכו ל: <strong>$%{costs} </strong><br /><br />אנו מאחלים לך החלמה מהירה!'
    },
    states = {
        irritated = 'מגורה',
        quite_painful = 'די כואב',
        painful = 'כואב',
        really_painful = 'ממש כואב',
        little_bleed = '...מדמם טיפה',
        bleed = 'מדמם..''
        lot_bleed = '...מדמם הרבה',
        big_bleed = '...מדמם המון',
    },
    menu = {
        amb_vehicles = 'רכבי אמבולנסים',
        status = 'מצב בריאותי',
        close = '⬅ סגור תפריט',
    },
    text = {
        pstash_button = '[E] - מחסן אישי',
        pstash = 'מחסן אישי',
        onduty_button = '[E] - עלה לתפקיד',
        offduty_button = '[E] - רד מתפקיד',
        duty = 'בתפקיד / לא בתפקיד',
        armory_button = '[E] - נשקיה',
        armory = 'Armory',
        veh_button = '[E] - קח / אחסן רכב',
        heli_button = '[E] - קח / אחסן הליקופטר',
        elevator_roof = '[E] - קח מעלית לגג',
        elevator_main = '[E] - קח מעלית למטה',
        bed_out = '[E] - כדי לצאת מהמיטה..',
        call_doc = '[E] - קרא לרופא',
        call = 'קרא',
        check_in = '[E] הרשם',
        check = 'הרשמה',
        lie_bed = '[E] - כדי לשכב במיטה'
    },
    body = {
        head = 'ראש',
        neck = 'צוואר',
        spine = 'עמוד שדרה',
        upper_body = 'פלג גוף עליון',
        lower_body = 'פלג גוף תחתון',
        left_arm = 'זרוע שמאל',
        left_hand = 'יד שמאל',
        left_fingers = 'אצבעות שמאל',
        left_leg = 'רגל שמאל',
        left_foot = 'כף רגל שמאל',
        right_arm = 'זרוע שמאל',
        right_hand = 'יד ימין',
        right_fingers = 'אצבעות ימין',
        right_leg = 'רגל ימין',
        right_foot = 'כף רגל ימים',
    },
    progress = {
        ifaks = '...לוקח איפקס',
        bandage = '...משתמש בתחבושות',
        painkillers = '...לוקח משככי כאבים',
        revive = '...מחיאה אדם',
        healing = '...מחיאה פצעים',
        checking_in = '...נרשם',
    },
    logs = {
        death_log_title = '%{playername} (%{playerid}) מת',
        death_log_message = '%{killername} הרג את %{playername} עם **%{weaponlabel}** (%{weaponname})',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
