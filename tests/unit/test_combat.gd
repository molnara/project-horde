extends RefCounted

const F = preload("res://tests/support/gameplay_fixture.gd")

func cases() -> Array[Dictionary]:
	var result := F.cases_for("combat", ["health", "invalid_damage"], ["res://scripts/combat/health.gd"])
	result.append_array(F.cases_for("combat", ["registry_death", "targeting", "weapon_readiness", "contact", "feedback"],
		["res://scenes/enemy.tscn", "res://scenes/arena.tscn", "res://scripts/combat/health.gd", "res://scripts/run/live_registry.gd", "res://scripts/combat/automatic_weapon.gd", "res://scripts/combat/attack_feedback.gd"]))
	return result

func health(ctx) -> void:
	var d = ctx.definitions()
	var before := F.snapshot(d)
	var player = F.health(ctx, d.player.max_health)
	var first = F.health(ctx, d.enemy.max_health)
	var second = F.health(ctx, d.enemy.max_health)
	var changes := F.observe(ctx, first, "health_changed")
	var deaths := F.observe(ctx, first, "died")
	ctx.check(player.current_health == 100 and first.current_health == 30 and second.current_health == 30, "fresh independent full health")
	ctx.check(F.invoke(ctx, first, "apply_damage", [10]) == 10 and first.current_health == 20, "nonlethal applied damage")
	ctx.check(changes == [[20, 30]] and deaths.is_empty(), "nonlethal signals synchronous")
	ctx.check(second.current_health == 30 and player.current_health == 100, "damage isolated")
	ctx.check(F.invoke(ctx, first, "apply_damage", [999]) == 20 and first.current_health == 0, "excess clamps to zero; returns actual loss")
	ctx.check(deaths.size() == 1 and not F.invoke(ctx, first, "is_alive"), "death emitted once immediately")
	ctx.check(F.invoke(ctx, first, "apply_damage", [10]) == 0 and deaths.size() == 1, "dead health cannot take further damage or die twice")
	ctx.check(F.snapshot(d) == before, "health never changes shared definitions")
	ctx.done()

func invalid_damage(ctx) -> void:
	var health = F.health(ctx, 100)
	ctx.check(health.has_signal("diagnostic"), "invalid damage exposes application diagnostic")
	if health.has_signal("diagnostic"):
		ctx.connect_callback(Signal(health, "diagnostic"), ctx.application_diagnostic)
	var changed := F.observe(ctx, health, "health_changed")
	for amount in [0, -1, 1.5, NAN, INF, "10", true, null]:
		ctx.check(F.invoke(ctx, health, "apply_damage", [amount]) == 0 and health.current_health == 100, "invalid damage rejected without mutation: " + str(amount))
	ctx.check(changed.is_empty(), "invalid damage emits no health changes")
	ctx.done()

func registry_death(ctx) -> void:
	var d = ctx.definitions()
	var before := F.snapshot(d)
	var registry = F.registry(ctx)
	var first = F.enemy(ctx, d, 4, Vector3.ZERO)
	var second = F.enemy(ctx, d, 2, Vector3(1, 0, 0))
	F.invoke(ctx, registry, "add", [first, 4])
	F.invoke(ctx, registry, "add", [second, 2])
	ctx.check(F.invoke(ctx, registry, "living_in_spawn_order") == [second, first], "snapshot in spawn-ID order")
	F.invoke(ctx, first.health, "apply_damage", [30])
	ctx.check(not F.invoke(ctx, registry, "living_in_spawn_order").has(first), "synchronous removal precedes deferred scene deletion")
	var old_position: Vector3 = first.position
	var arena = F.arena(ctx, d)
	F.invoke(ctx, first, "step", [1.0, Vector3(10, 0, 0), arena])
	ctx.check(first.position == old_position, "dead actor cannot pursue")
	var victim = F.health(ctx, 100)
	F.invoke(ctx, first, "step_contact", [10.0, old_position, victim])
	ctx.check(victim.current_health == 100, "dead actor cannot contact")
	F.invoke(ctx, registry, "remove", [second])
	ctx.check(F.invoke(ctx, registry, "living_in_spawn_order").is_empty(), "departed actor excluded")
	ctx.check(F.snapshot(d) == before, "actor health/movement keep resources immutable")
	d.enemy.max_health = 200
	d.enemy.contact_damage = 99
	ctx.check(second.health.max_health == 30 and second.health.current_health == 30, "configured actor keeps copied health despite later authoring changes")
	F.invoke(ctx, second, "step_contact", [0.0, second.position, victim])
	ctx.check(victim.current_health == 90, "configured contact damage is a runtime snapshot of original tuning")
	await Engine.get_main_loop().process_frame
	ctx.check(not is_instance_valid(first), "dead enemy scene disposed by next update")
	ctx.done()

func targeting(ctx) -> void:
	var d = ctx.definitions()
	var first = F.enemy(ctx, d, 1, Vector3(3, 100, 0))
	var second = F.enemy(ctx, d, 2, Vector3(2, -100, 0))
	var weapon = F.weapon(ctx, d)
	var hits := F.observe(ctx, weapon, "attacked")
	F.invoke(ctx, weapon, "step", [0.0, Vector3.ZERO, [first, second]])
	ctx.check(first.health.current_health == 30 and second.health.current_health == 20 and hits == [[2, 10]], "only nearest XZ target takes configured damage")
	first.position = Vector3(2, 999, 0)
	F.invoke(ctx, weapon, "step", [0.6, Vector3.ZERO, [second, first]])
	ctx.check(first.health.current_health == 20 and second.health.current_health == 20 and hits[-1] == [1, 10], "equal XZ distances choose earliest ID regardless of list order")
	for x in [3.999755859375, 4.0, 4.000244140625]:
		var target = F.enemy(ctx, d, 10, Vector3(x, 1000, 0))
		var fresh = F.weapon(ctx, d)
		F.invoke(ctx, fresh, "step", [0.0, Vector3.ZERO, [target]])
		ctx.check(target.health.current_health == (20 if x <= 4 else 30), "exact/inside/outside range, no epsilon")
	F.invoke(ctx, first.health, "apply_damage", [30])
	second.position = Vector3(9, 0, 0)
	var hits_before: int = hits.size()
	F.invoke(ctx, weapon, "step", [2.0, Vector3.ZERO, [first, second]])
	ctx.check(hits.size() == hits_before, "dead and departed targets are reassessed/excluded")
	ctx.done()

func weapon_readiness(ctx) -> void:
	var d = ctx.definitions()
	d.weapon.attack_interval = 0.5
	d.enemy.max_health = 1000
	var target = F.enemy(ctx, d, 0, Vector3(1, 0, 0))
	var weapon = F.weapon(ctx, d)
	var hits := F.observe(ctx, weapon, "attacked")
	ctx.check(weapon.next_attack_at == 0.0, "fresh ready weapon")
	F.invoke(ctx, weapon, "step", [4.0, Vector3.ZERO, []])
	ctx.check(weapon.next_attack_at == 0.0 and hits.is_empty(), "no target preserves readiness")
	F.invoke(ctx, weapon, "step", [4.0, Vector3.ZERO, [target]])
	ctx.check(hits.size() == 1 and weapon.next_attack_at == 4.5, "ready target attacks immediately; deadline from actual hit")
	var before_attack := 4.5 - pow(2.0, -50.0)
	ctx.check(before_attack < 4.5, "binary predecessor is actually before weapon deadline")
	F.invoke(ctx, weapon, "step", [before_attack, Vector3.ZERO, [target]])
	ctx.check(hits.size() == 1, "representable just-before deadline never attacks early")
	F.invoke(ctx, weapon, "step", [4.5, Vector3.ZERO, [target]])
	ctx.check(hits.size() == 2, "exact deadline attacks")
	F.invoke(ctx, weapon, "step", [20.0, Vector3.ZERO, [target]])
	ctx.check(hits.size() == 3 and weapon.next_attack_at == 20.5, "long step attacks once without burst")
	# Waiting with real actor components must not regenerate.
	var damaged: int = target.health.current_health
	var arena = F.arena(ctx, d)
	F.invoke(ctx, target, "step", [20.0, target.position, arena])
	ctx.check(target.health.current_health == damaged, "no regeneration during damage-free wait")
	ctx.done()

func contact(ctx) -> void:
	var d = ctx.definitions()
	d.enemy.contact_distance = 1.0
	var victim = F.health(ctx, 100)
	var enemy = F.enemy(ctx, d, 0, Vector3(1, 100, 0))
	ctx.check(enemy.next_contact_at == 0.0, "enemy ready on spawn")
	F.invoke(ctx, enemy, "step_contact", [0.0, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 90 and enemy.next_contact_at == 1.0, "first contact inclusive, XZ only")
	F.invoke(ctx, enemy, "step_contact", [0.5, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 90, "persistent overlap does not bypass cooldown")
	enemy.position.x = 1.000244140625
	F.invoke(ctx, enemy, "step_contact", [0.75, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 90 and enemy.next_contact_at == 1.0, "separation causes no damage/reset")
	enemy.position.x = 0.999755859375
	# This engine rounds the long decimal literal to 1.0. Binary arithmetic
	# constructs the actual double predecessor without weakening the comparison.
	var before_contact := 1.0 - pow(2.0, -53.0)
	ctx.check(before_contact < 1.0, "binary predecessor is actually before contact deadline")
	F.invoke(ctx, enemy, "step_contact", [before_contact, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 90 and enemy.next_contact_at == 1.0, "re-entry before deadline cannot reset/bypass")
	F.invoke(ctx, enemy, "step_contact", [1.0, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 80 and enemy.next_contact_at == 2.0, "exact readiness attacks")
	var second = F.enemy(ctx, d, 1, Vector3.ZERO)
	F.invoke(ctx, second, "step_contact", [1.5, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 70 and second.next_contact_at == 2.5 and enemy.next_contact_at == 2.0, "independent contact deadlines")
	enemy.position.x = 2.0
	F.invoke(ctx, enemy, "step_contact", [10.0, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 70 and enemy.next_contact_at == 2.0, "no-contact leaves overdue attacker ready")
	enemy.position.x = 0.0
	F.invoke(ctx, enemy, "step_contact", [10.0, Vector3.ZERO, victim])
	ctx.check(victim.current_health == 60 and enemy.next_contact_at == 11.0, "long gap delivers only one ready hit")
	ctx.done()

func feedback(ctx) -> void:
	var d = ctx.definitions()
	d.weapon.feedback_duration = 0.125
	var target = F.enemy(ctx, d, 7, Vector3(1, 0, 0))
	var feedback = F.instance(ctx, "res://scripts/combat/attack_feedback.gd")
	F.invoke(ctx, feedback, "configure", [d.weapon])
	var before: int = target.health.current_health
	var visual = target.get_node("Visual")
	var original_color: Color = visual.material_override.albedo_color
	F.invoke(ctx, feedback, "show_attack", [1.0, Vector3.ZERO, target])
	ctx.check(feedback.visible and feedback.target_spawn_id == 7 and feedback.expires_at == 1.125, "actual feedback identifies affected target, absolute expiry")
	ctx.check(feedback.get_node("Line").visible and visual.material_override.albedo_color != original_color, "actual line and affected enemy material flash are visible")
	F.invoke(ctx, feedback, "present", [1.0])
	ctx.check(feedback.visible, "feedback does not age by another delta in attack step")
	var before_expiry := 1.125 - pow(2.0, -52.0)
	ctx.check(before_expiry < 1.125, "binary predecessor is actually before feedback expiry")
	F.invoke(ctx, feedback, "present", [before_expiry])
	ctx.check(feedback.visible, "visible just before expiry")
	F.invoke(ctx, feedback, "present", [1.125])
	ctx.check(not feedback.visible and target.health.current_health == before, "expires at exact completion deadline; no feedback damage")
	ctx.check(not feedback.get_node("Line").visible and visual.material_override.albedo_color == original_color, "expiry hides actual line and restores actual target material")
	ctx.done()
