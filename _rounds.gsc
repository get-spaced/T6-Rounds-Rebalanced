#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;

safe_replacefunc(path, name, replacement) {
  func = getfunction(path, name);

  if (!isdefined(func))
    return false;

  if (!isdefined(level.old_funcs))
    level.old_funcs = [];

  level.old_funcs[name] = func;
  replacefunc(func, replacement);

  return true;
}

main() {
  safe_replacefunc("maps/mp/zombies/_zm", "round_think", ::uncapped_round_think);
  safe_replacefunc("maps/mp/zombies/_zm", "ai_calculate_health", ::capped_zombie_health);
}

init() {
  level.max_zombie_func = ::get_round_zombie_limit;
}

get_round_zombie_limit(max_num) {
  player_count = get_players().size;

  if (player_count < 1)
    player_count = 1;

  zombies = max_num;

  if (level.round_number < 2)
    zombies = int(max_num * 0.25);
  else if (level.round_number < 3)
    zombies = int(max_num * 0.3);
  else if (level.round_number < 4)
    zombies = int(max_num * 0.5);
  else if (level.round_number < 5)
    zombies = int(max_num * 0.7);
  else if (level.round_number < 6)
    zombies = int(max_num * 0.9);

  cap = 24 * player_count;

  if (zombies > cap)
    zombies = cap;

  return zombies;
}

uncapped_round_think(restart) {
  if (!isdefined(restart))
    restart = 0;

  level endon("end_round_think");

  // level.round_number = 10;
  // level.first_round = false;
  // level.zombie_vars["zombie_spawn_delay"] = 1.2605;
  // level.zombie_move_speed = 105;

  round_one_up_func = getfunction("maps/mp/zombies/_zm", "round_one_up");
  award_grenades_func = getfunction("maps/mp/zombies/_zm", "award_grenades_for_survivors");
  revive_func = getfunction("maps/mp/zombies/_zm", "last_stand_revive");
  respawn_func = getfunction("maps/mp/zombies/_zm", "spectators_respawn");
  quickrevive_func = getfunction("maps/mp/zombies/_zm", "check_quickrevive_for_hotjoin");
  round_over_func = getfunction("maps/mp/zombies/_zm", "round_over");

  if (!restart) {
    if (isdefined(level.initial_round_wait_func))
      [[level.initial_round_wait_func]]();

    if (!isdefined(level.host_ended_game) || !level.host_ended_game) {
      players = get_players();

      foreach (player in players) {
        if (!isdefined(player.hostmigrationcontrolsfrozen) || !player.hostmigrationcontrolsfrozen)
          player freezecontrols(0);

        player maps\mp\zombies\_zm_stats::set_global_stat("rounds", level.round_number);
      }
    }
  }

  setroundsplayed(level.round_number);

  for (;;) {
    maxreward = 50 * level.round_number;

    if (maxreward > 500)
      maxreward = 500;

    level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
    level.pro_tips_start_time = gettime();
    level.zombie_last_run_time = gettime();

    if (isdefined(level.zombie_round_change_custom)) {
      [[level.zombie_round_change_custom]]();
    } else {
      level thread maps\mp\zombies\_zm_audio::change_zombie_music("round_start");
      [[round_one_up_func]]();
    }

    maps\mp\zombies\_zm_powerups::powerup_round_start();

    players = get_players();
    array_thread(players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset);

    if (!(isdefined(level.headshots_only) && level.headshots_only) && !restart)
      level thread [[award_grenades_func]]();

    bbprint("zombie_rounds", "round %d player_count %d", level.round_number, players.size);

    level.round_start_time = gettime();

    while (level.zombie_spawn_locations.size <= 0)
      wait 0.1;

    level thread [[level.round_spawn_func]]();

    level notify("start_of_round");
    recordzombieroundstart();

    players = getplayers();

    for (index = 0; index < players.size; index++) {
      zonename = players[index] get_current_zone();

      if (isdefined(zonename))
        players[index] recordzombiezone("startingZone", zonename);
    }

    if (isdefined(level.round_start_custom_func))
      [[level.round_start_custom_func]]();

    [[level.round_wait_func]]();

    level.first_round = 0;
    level notify("end_of_round");

    level thread maps\mp\zombies\_zm_audio::change_zombie_music("round_end");

    uploadstats();

    if (isdefined(level.round_end_custom_logic))
      [[level.round_end_custom_logic]]();

    players = get_players();

    if (isdefined(level.no_end_game_check) && level.no_end_game_check) {
      level thread [[revive_func]]();
      level thread [[respawn_func]]();
    } else if (players.size != 1) {
      level thread [[respawn_func]]();
    }

    players = get_players();
    array_thread(players, maps\mp\zombies\_zm_pers_upgrades_system::round_end);

    timer = level.zombie_vars["zombie_spawn_delay"];

    if (timer > 0.08)
      level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
    else if (timer < 0.08)
      level.zombie_vars["zombie_spawn_delay"] = 0.08;

    if (level.gamedifficulty == 0)
      level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    else
      level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    level.round_number++;

    setroundsplayed(level.round_number);
    matchutctime = getutc();

    players = get_players();

    foreach (player in players) {
      if (level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round)
        player maps\mp\zombies\_zm_stats::add_client_stat("weighted_rounds_played", level.round_number);

      player maps\mp\zombies\_zm_stats::set_global_stat("rounds", level.round_number);
      player maps\mp\zombies\_zm_stats::update_playing_utc_time(matchutctime);
    }

    [[quickrevive_func]]();
    level [[round_over_func]]();
    level notify("between_round_over");

    restart = 0;
  }
}

capped_zombie_health(round_number) {
  if (round_number > 30)
    round_number = 30;

  level.zombie_health = level.zombie_vars["zombie_health_start"];

  for (i = 2; i <= round_number; i++) {
    if (i < 10) {
      level.zombie_health = int(level.zombie_health + level.zombie_vars["zombie_health_increase"]);
      continue;
    }

    old_health = level.zombie_health;

    level.zombie_health += int(level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"]);

    if (level.zombie_health < old_health) {
      level.zombie_health = old_health;
      return;
    }
  }
}