local Translations = {
    error = {
        canceled = 'Annullato',
        bled_out = 'Sei dissanguato...',
        impossible = 'Azione impossibile...',
        no_player = 'Nessun giocatore nelle vicinanze',
        no_firstaid = 'Hai bisogno di un kit di pronto soccorso',
        no_bandage = 'Hai bisogno di una benda',
        beds_taken = 'I letti sono occupati...',
        possessions_taken = 'Hai perso i tuoi effetti personali...',
        not_enough_money = 'Non hai abbastanza soldi...',
        cant_help = 'Non puoi aiutare questa persona...',
        not_ems = 'Non sei EMS o non sei in servizio',
        not_online = 'Giocatore offline',
        not_dead = 'There is no dead player nearby!'
    },
    success = {
        revived = 'Hai rianimato una persona',
        healthy_player = 'Il giocatore è in salute',
        helped_player = 'Hai aiutato una persona',
        wounds_healed = 'Le tue ferite sono state guarite!',
        being_helped = 'Ti stanno aiutando...'
    },
    info = {
        civ_died = 'Civile morto',
        civ_down = 'Civile ferito',
        civ_call = 'Richiesta di intervento',
        self_death = 'Se stesso o un NPC',
        wep_unknown = 'Sconosciuto',
        respawn_txt = 'RESPAWN TRA: ~r~%{deathtime}~s~ SECONDI',
        respawn_revive = 'PREMI [~r~E~s~] PER %{holdtime} SECONDI PER IL RESPAWN AL COSTO DI $~r~%{cost}~s~',
        bleed_out = 'MORIRAI DISSANGUATO TRA: ~r~%{time}~s~ SECONDI',
        bleed_out_help = 'MORIRAI DISSANGUATO TRA: ~r~%{time}~s~ SECONDI, PUOI ESSERE AIUTATO',
        request_help = 'PREMI [~r~G~s~] PER RICHIEDERE AIUTO',
        help_requested = 'IL PERSONALE EMS È STATO AVVISATO',
        amb_plate = 'AMBU', -- Deve essere lungo al massimo 4 caratteri poiché gli ultimi 4 sono 4 cifre casuali
        heli_plate = 'LIFE',  -- Deve essere lungo al massimo 4 caratteri poiché gli ultimi 4 sono 4 cifre casuali
        status = 'Verifica stato',
        is_staus = 'È %{status}',
        healthy = 'Sei di completamente in salute!',
        safe = 'Hospital Safe',
        pb_hospital = 'Pillbox Hospital',
        pain_message = 'Hai %{limb} e ti senti %{severity}',
        many_places = 'Hai dolori in molti posti...',
        bleed_alert = 'Sei %{bleedstate}',
        ems_alert = 'EMS Alert - %{text}',
        mr = 'Sig.',
        mrs = 'Sig.ra',
        dr_needed = 'È richiesto un medico al Pillbox Hospital',
        ems_report = 'EMS Report',
        message_sent = 'Messaggio inviato',
        check_health = 'Controlla la salute di un giocatore',
        heal_player = 'Guarisci giocatore',
        revive_player = 'Rianima giocatore',
        revive_player_a = 'Rianima un giocatore o te stesso (Solo Admin)',
        player_id = 'ID Giocatore (può essere vuoto)',
        pain_level = 'Imposta il tuo o un livello di dolore di un giocatore (Solo Admin)',
        kill = 'Uccidi un giocatore o te stesso (Solo Admin)',
        heal_player_a = 'Cura un giocatore o te stesso (Solo Admin)',
    },
    mail = {
        sender = 'Pillbox Hospital',
        subject = 'Spese ospedaliere',
        message = 'Salve %{gender} %{lastname}, <br /><br />Con la presente hai ricevuto un\'e-mail con i costi dell\'ultima visita in ospedale.<br />I costi totali sono: <strong>$%{costs}</strong><br /><br />Le auguriamo una pronta guarigione!'
    },
    states = {
        irritated = 'irritato',
        quite_painful = 'abbastanza doloroso',
        painful = 'doloroso',
        really_painful = 'davvero doloroso',
        little_bleed = 'sanguindo un po\'...',
        bleed = 'sanguindo...',
        lot_bleed = 'sanguindo molto...',
        big_bleed = 'sanguindo tantissimo...',
    },
    menu = {
        amb_vehicles = 'Veicoli EMS',
        status = 'Stato',
        close = '⬅ Chiudi Menù',
    },
    text = {
        pstash_button = '[E] - Inventario Personale',
        pstash = 'Inventario Personale',
        onduty_button = '[E] - Vai in servizio',
        offduty_button = '[E] - Vai fuori servizio',
        duty = 'Entra/Esci dal Servizio',
        armory_button = '[E] - Farmacia',
        armory = 'Farmacia',
        veh_button = '[E] - Prendi / Deposita Veicolo',
        heli_button = '[E] - Prendi / Deposita Velivolo',
        elevator_roof = '[E] - Prendi l\'ascensore fino al tetto',
        elevator_main = '[E] - Prendi l\'ascensore fino al piano',
        bed_out = '[E] - Per alzarti dal letto..',
        call_doc = '[E] - Chiama un dottore',
        call = 'Chiama',
        check_in = '[E] Check in',
        check = 'Check In',
        lie_bed = '[E] - Sdraiarsi sul letto'
    },
    body = {
        head = 'Testa',
        neck = 'Collo',
        spine = 'Dorso',
        upper_body = 'Torace',
        lower_body = 'Bacino',
        left_arm = 'Braccio sinistro',
        left_hand = 'Mano sinistra',
        left_fingers = 'Dita sinistra',
        left_leg = 'Gamba sinistra',
        left_foot = 'Piede sinistro',
        right_arm = 'Braccio destro',
        right_hand = 'Mano destra',
        right_fingers = 'Dita destra',
        right_leg = 'Gamba destra',
        right_foot = 'Piede destro',
    },
    progress = {
        ifaks = 'Assumendo iFaks...',
        bandage = 'Usando una benda...',
        painkillers = 'Assumendo antidolorifici...',
        revive = 'Rianimazione...',
        healing = 'Guarendo ferite...',
        checking_in = 'Check-in...',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) è morto",
        death_log_message = "%{killername} ha ucciso %{playername} con **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'it' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
