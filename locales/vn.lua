local Translations = {
    error = {
        canceled = 'Hủy bỏ',
        bled_out = 'Bạn đang bị chảy máu...',
        impossible = 'Hành động không thể...',
        no_player = 'Không có ai gần bạn',
        no_firstaid = 'Bạn cần bộ sơ cứu',
        no_bandage = 'Bạn cần băng gạc',
        beds_taken = 'Giường đã có người...',
        possessions_taken = 'Tất cả tài sản của bạn đã bị mất...',
        not_enough_money = 'Bạn không có đủ tiền...',
        cant_help = 'Bạn không thể cứu người này...',
        not_ems = 'Bạn không phải Bác sĩ',
        not_online = 'Người chơi không trực tuyến'
    },
    success = {
        revived = 'Bạn đã hồi sinh một người',
        healthy_player = 'Người chơi vẫn khỏe mạnh',
        helped_player = 'Bạn đã cứu người',
        wounds_healed = 'Vết thương của bạn đã lành',
        being_helped = 'Bạn đang được chữa...'
    },
    info = {
        civ_died = 'Công dân chết',
        civ_down = 'Công dân bị ngất',
        civ_call = 'Công dân gọi',
        self_death = 'Tự sát hoặc NPC',
        wep_unknown = 'Vô danh',
        respawn_txt = 'CHỜ BÁC SĨ : ~r~%{deathtime}~s~ GIÂY',
        respawn_revive = 'GIỮ [~r~E~s~] VỀ BỆNH VIỆN(MẤT HẾT ~r~ITEM~s~) or /115 [~r~ID~s~] GỌI BÁC SĨ',
        bleed_out = 'BẠN SẼ BỊ MẤT MÁU TỚI CHẾT TRONG VÒNG: ~r~{time}~s~ GIÂY, /115 ĐỂ GỌI BÁC SĨ',
        bleed_out_help = 'BẠN SẼ BỊ MẤT MÁU TỚI CHẾT TRONG VÒNG: ~r~{time}~s~ GIÂY, /115 ĐỂ GỌI BÁC SĨ',
        request_help = 'ẤN [~r~G~s~] or /911e ĐỂ GỬI YÊU CẦU TRỢ GIÚP',
        help_requested = 'BÁC SĨ ĐÃ NHẬN ĐƯỢC THÔNG BÁO',
        amb_plate = 'AMBU', -- Should only be 4 characters long due to the last 4 being a random 4 digits
        heli_plate = 'LIFE',  -- Should only be 4 characters long due to the last 4 being a random 4 digits
        status = 'Kiểm tra trạng thái',
        is_staus = 'Bị %{status}',
        healthy = 'Bạn đã được chữa lành!',
        safe = 'Hospital Safe',
        pb_hospital = 'Bệnh Viện',
        pain_message = ' %{limb} đang bị %{severity}',
        many_places = 'Bạn bị đau nghiêm trọng...',
        bleed_alert = 'Bạn bị %{bleedstate}',
        ems_alert = '%{text} - Gọi Cấp Cứu',
        mr = 'Ông',
        mrs = 'Bà.',
        dr_needed = 'Yêu cầu Bác sĩ trợ giúp',
        ems_report = 'Báo cáo bác sĩ',
        message_sent = 'Tin nhắn sẽ được gửi',
        check_health = 'Kiểm tra tình trạng sức khỏe',
        heal_player = 'Hồi máu',
        revive_player = 'Hồi sinh',
        revive_player_a = 'Hồi sinh bản thân hoặc ngươi chơi (Chỉ Admin)',
        player_id = 'ID người chơi (có thể để trống)',
        pain_level = 'Đặt mức độ bị thương cho chính bản thân hoặc người chơi (Chỉ Admin)',
        kill = 'Giết người chơi hoặc bản thân (Chỉ Admin)',
        heal_player_a = 'Hồi máu cho bản thân hoặc ngươi chơi (Chỉ Admin)',
    },
    mail = {
        sender = 'Bệnh Viện',
        subject = 'Thoanh toán',
        message = 'Kính gửi %{gender} %{lastname}, <br /><br />Hereby Bạn đã nhận được một email với hóa dơn bệnh viện .<br />Hóa đơn bạn phải trả là: <strong>$%{costs}</strong><br /><br />Chúng tôi chúc bạn có sức khỏe dồi dào!'
    },
    states = {
        irritated = 'Nhức',
        quite_painful = 'Hơi đau',
        painful = 'Đau',
        really_painful = 'Đau nghiêm trọng',
        little_bleed = 'Mất máu ít...',
        bleed = 'Đang mất máu...',
        lot_bleed = 'Mất máu nhiều...',
        big_bleed = 'Mất máu nghiêm trọng...',
    },
    menu = {
        amb_vehicles = 'Xe cứu thương',
        status = 'Trạng thái Sức khỏe',
        close = '⬅ Đóng Menu',
    },
    text = {
        pstash_button = '~g~E~w~ - Kho chung',
        pstash = 'Kho chung',
        onduty_button = '~g~E~w~ - Vào ca',
        offduty_button = '~r~E~w~ - Tan ca',
        duty = 'Vào/Tan ca',
        armory_button = '~g~E~w~ - Kho',
        armory = 'Kho',
        veh_button = '~g~E~w~ - Phương tiện',
        heli_button = '~g~E~w~ - Trực thăng',
        elevator_roof = '~g~E~w~ - Lên sân thượng',
        elevator_main = '~g~E~w~ - Đi xuống',
        bed_out = '~g~E~w~ - Rời khỏi giường..',
        call_doc = '~g~E~w~ -Gọi Bác sĩ',
        call = 'Gọi',
        check_in = '~g~E~w~ - Nhập viện',
        check = 'Nhập viện',
        lie_bed = '~g~E~w~ - Nằm xuống giường'
    },
    body = {
        head = 'Đầu',
        neck = 'Cổ',
        spine = 'Xương sống',
        upper_body = 'Thân trên',
        lower_body = 'Thân dưới',
        left_arm = 'Cánh tay trái',
        left_hand = 'Bàn tay trái',
        left_fingers = 'Ngón tay trái',
        left_leg = 'Chân trái',
        left_foot = 'Bàn chân trái',
        right_arm = 'Cánh tay phải',
        right_hand = 'Bàn tay phải',
        right_fingers = 'Ngón tay phải',
        right_leg = 'Chân phải',
        right_foot = 'Bàn chân phải',
    },
    progress = {
        ifaks = 'Taking ifaks',
        bandage = 'Sử dụng Băng gạc',
        painkillers = 'Uống thuốc giảm đau',
        revive = 'Đang cứu sống',
        healing = 'Điều trị vết thương',
        checking_in = 'Đang nhập viện',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) đã chết",
        death_log_message = "%{killername} đã giết %{playername} bằng một **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'vn' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
