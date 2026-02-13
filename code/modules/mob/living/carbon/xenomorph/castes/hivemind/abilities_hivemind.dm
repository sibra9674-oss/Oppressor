//List of Hivemind resin structure images
GLOBAL_LIST_INIT(hivemind_resin_images_list, list(
	RESIN_WALL = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_WALL),
	RESIN_WALL_BULLET = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_WALL_BULLET),
	RESIN_WALL_FIRE = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_WALL_FIRE),
	RESIN_WALL_HARDY = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_WALL_HARDY),
	STICKY_RESIN = image('icons/Xeno/actions/construction.dmi', icon_state = STICKY_RESIN),
	RESIN_DOOR = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_DOOR),
	ALIEN_NEST = image('icons/Xeno/actions/construction.dmi', icon_state = ALIEN_NEST),
	GROWTH_WALL = image('icons/Xeno/actions/construction.dmi', icon_state = GROWTH_WALL),
	GROWTH_DOOR = image('icons/Xeno/actions/construction.dmi', icon_state = GROWTH_DOOR)
))

/datum/action/ability/xeno_action/sow/hivemind
	cooldown_duration = 70 SECONDS

/datum/action/ability/xeno_action/return_to_core
	name = "Return to Core"
	desc = "Teleport back to your core."
	action_icon_state = "lay_hivemind"
	action_icon = 'icons/Xeno/actions/hivemind.dmi'
	use_state_flags = ABILITY_USE_CLOSEDTURF

/datum/action/ability/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)
	return ..()

/datum/action/ability/activable/xeno/secrete_resin/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/sow/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/place_acidwell/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/place_jelly_pod/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/change_form
	name = "Change form"
	desc = "Change from your incorporeal form to your physical on and vice-versa."
	action_icon_state = "manifest"
	action_icon = 'icons/Xeno/actions/hivemind.dmi'
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM,
	)
	use_state_flags = ABILITY_USE_CLOSEDTURF

/datum/action/ability/xeno_action/change_form/action_activate()
	xeno_owner.change_form()

/datum/action/ability/activable/xeno/command_minions
	name = "Command minions"
	desc = "Command all minions, ordering them to converge on this location. Rightclick to change minion behaviour."
	action_icon_state = "minion_agressive"
	action_icon = 'icons/Xeno/actions/general.dmi'
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RALLY_MINION,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_MINION_BEHAVIOUR,
	)
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	cooldown_duration = 60 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED
	///If minions should be agressive
	var/minions_agressive = TRUE

/datum/action/ability/activable/xeno/command_minions/update_button_icon()
	action_icon_state = minions_agressive ? "minion_agressive" : "minion_passive"
	return ..()

/datum/action/ability/activable/xeno/command_minions/use_ability(atom/target)
	var/turf_targeted = get_turf(target)
	if(!turf_targeted)
		return
	new /obj/effect/ai_node/goal(turf_targeted, owner)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/command_minions/alternate_action_activate()
	minions_agressive = !minions_agressive
	SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, minions_agressive)
	update_button_icon()

/datum/action/ability/activable/xeno/psychic_cure/queen_give_heal/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/transfer_plasma/hivemind
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/ability/activable/xeno/transfer_plasma/hivemind/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/pheromones/hivemind/can_use_action(silent = FALSE, override_flags)
	if (owner.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/watch_xeno/hivemind/can_use_action(silent = FALSE, override_flags)
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_HIVEMIND_MANIFESTATION))
		return FALSE
	return ..()

/datum/action/ability/xeno_action/watch_xeno/hivemind/on_list_xeno_selection(datum/source, mob/living/carbon/xenomorph/selected_xeno)
	if(!can_use_action())
		return
	var/mob/living/carbon/xenomorph/hivemind/hivemind = source
	hivemind.jump(selected_xeno)

/datum/action/ability/xeno_action/teleport
	name = "Teleport"
	desc = "Pick a location on the map and instantly manifest there if possible."
	action_icon_state = "resync"
	action_icon = 'icons/Xeno/actions/hivemind.dmi'
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMISG_XENOMORPH_HIVEMIND_TELEPORT,
	)
	use_state_flags = ABILITY_USE_CLOSEDTURF
	///Is the map being shown to the player right now?
	var/showing_map = FALSE

/datum/action/ability/xeno_action/teleport/action_activate()
	var/atom/movable/screen/minimap/shown_map = SSminimaps.fetch_minimap_object(owner.z, MINIMAP_FLAG_XENO)

	if(showing_map) // The map is open on their screen, close it
		owner.client?.screen -= shown_map
		shown_map.UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		showing_map = FALSE
		return

	owner.client?.screen += shown_map
	showing_map = TRUE
	var/list/polled_coords = shown_map.get_coords_from_click(owner)
	owner.client?.screen -= shown_map
	showing_map = FALSE
	if(!polled_coords)
		shown_map.UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		return
	var/turf/turf_to_teleport_to = locate(polled_coords[1], polled_coords[2], owner.z)
	if(!turf_to_teleport_to)
		return

	if(!xeno_owner.check_weeds(turf_to_teleport_to, TRUE))
		owner.balloon_alert(owner, "No weeds in selected location")
		return
	if(!(xeno_owner.status_flags & INCORPOREAL) && isxenohivemind(xeno_owner))
		var/mob/living/carbon/xenomorph/hivemind/hivemind_owner = xeno_owner
		hivemind_owner.start_teleport(turf_to_teleport_to)
		return
	xeno_owner.abstract_move(turf_to_teleport_to)

// ***************************************
// *********** Secrete Resin
// ***************************************
/datum/action/ability/activable/xeno/secrete_resin/hivemind
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating,
		/turf/closed/wall/resin/regenerating/bulletproof,
		/turf/closed/wall/resin/regenerating/fireproof,
		/turf/closed/wall/resin/regenerating/hardy,
		/obj/alien/resin/sticky,
		/obj/structure/mineral_door/resin,
		/obj/structure/bed/nest,
		/obj/alien/resin/resin_growth,
		/obj/alien/resin/resin_growth/door,
	)

/datum/action/ability/activable/xeno/secrete_resin/hivemind/action_activate()
	if(xeno_owner.selected_ability != src)
		return ..()
	var/resin_choice = show_radial_menu(owner, owner, GLOB.hivemind_resin_images_list, radius = 48)
	if(!resin_choice)
		return
	var/i = GLOB.hivemind_resin_images_list.Find(resin_choice)
	xeno_owner.selected_resin = buildable_structures[i]
	var/atom/A = xeno_owner.selected_resin
	xeno_owner.balloon_alert(xeno_owner, initial(A.name))
	update_button_icon()

/datum/action/ability/activable/xeno/secrete_resin/hivemind/get_wait()
	. = ..()
	switch(xeno_owner.selected_resin)
		if(/obj/alien/resin/resin_growth)
			return 0
		if(/obj/alien/resin/resin_growth/door)
			return 0

// ***************************************
// *********** Psy Gain
// ***************************************
/datum/action/ability/xeno_action/psy_gain/hivemind
	name = "Psy Gain"
	desc = "Gives your hive 100 psy points, if marines are on the ground."
	action_icon_state = "psy_gain"
	action_icon = 'icons/Xeno/actions/hivemind.dmi'
	cooldown_duration = 200 SECONDS

/datum/action/ability/xeno_action/psy_gain/hivemind/action_activate()
	if(length_char(GLOB.humans_by_zlevel["2"]) > 0.2 * length_char(GLOB.alive_human_list))
		SSpoints.add_psy_points("[xeno_owner.hivenumber]", 100)
		GLOB.round_statistics.psypoints_from_hivemind += 100
	succeed_activate()
	add_cooldown()

/datum/action/ability/xeno_action/hive_message/sector_broadcast
	name = "Hivemind Voice"
	desc = "Транслирует волю Улья всем существам в текущем секторе."
	action_icon_state = "queen_order"
	action_icon = 'icons/Xeno/actions/general.dmi'
	ability_cost = 400
	cooldown_duration = 240 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_QUEEN_HIVE_MESSAGE,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/hive_message/sector_broadcast/action_activate()
	var/input = stripped_multiline_input(xeno_owner, "Максимальная длина: [MAX_BROADCAST_LEN]", "Голоса в голове", "", MAX_BROADCAST_LEN, TRUE)
	input = capitalize(trim(replacetext(input, "\n", " ")))
	if(!input)
		return

	var/filter_result = is_ic_filtered(input)
	if(filter_result)
		to_chat(xeno_owner, span_warning("That announcement contained a word prohibited in IC chat!"))
		return FALSE
	if(NON_ASCII_CHECK(input))
		to_chat(xeno_owner, span_warning("That announcement contained characters prohibited in IC chat!"))
		return FALSE

	log_game("[key_name(xeno_owner)] has messaged the sector with: \"[input]\"")

	var/queens_word = HUD_ANNOUNCEMENT_FORMATTING("Приказ Разума Улья", input, CENTER_ALIGN_TEXT)
	var/sound/queen_sound = sound(SFX_QUEEN, channel = CHANNEL_ANNOUNCEMENTS)
	var/sound/king_sound = sound('sound/voice/alien/xenos_roaring.ogg', channel = CHANNEL_ANNOUNCEMENTS)

	var/my_z = xeno_owner.z

	// Рассылка ВСЕМ игрокам в секторе (Z-уровень)
	for(var/mob/M in world)
		if(M.z == my_z && M.client)
			// Все (и люди, и ксеносы) получают стандартный алерт
			to_chat(M, assemble_alert(
				title = "Вы слышите голос в вашем разуме",
				subtitle = "Голос [xeno_owner.name]",
				message = input,
				color_override = "purple"
			))

			// Ксеноморфы дополнительно получают текст на экран и звук
			if(isxeno(M))
				var/mob/living/carbon/xenomorph/X = M
				switch(xeno_owner.caste_base_type)
					if(/datum/xeno_caste/queen, /datum/xeno_caste/shrike)
						SEND_SOUND(X, queen_sound)
					if(/datum/xeno_caste/king)
						SEND_SOUND(X, king_sound)
				X.play_screen_text(queens_word, /atom/movable/screen/text/screen_text/queen_order)

	succeed_activate()
	add_cooldown()
