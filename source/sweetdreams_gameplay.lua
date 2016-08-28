pkup_cont=0
time_to_play=180.0
game_timer={}

function setup_actors()

	plr = create_actor(64,60,2,2)
	plr.speed=1
	plr.maxspeed=2
	plr.dx=1
	add(plr.type,"player")
	add(plr.type,"health")
	add(plr.type,"jumpable")
	-- idle anim
	idle=plr.anims[1]
	idle.speed=4
	run=create_anim(plr)
	run.start=10
	run.frames=3
	run.speed=4

	local camera = create_actor(0,0,0,0)
	add(camera.type,"camera")
	camera.speed=1
	camera.maxspeed=2

	create_ghosts()
end

function create_ghosts()

	sfx(2,0)
	sfx(1,1)
	ghosts={}
	ghosts[1]=create_actor(128,62,2,2)
	ghosts[1].anims[1]=create_anim(ghosts[1])
	idleanim=ghosts[1].anims[1]
	idleanim.start=42
	idleanim.speed=3
	idleanim.frames=3

end

function create_ghost_spawners()
end

function manage_jumper(a)
	if(btn(4) and touch_ground(a)) then
		a.vely=-14
		sfx(5, 0)
	end
end

function manage_pickup(a)
	pkup_cont+=1
end

function manage_ghost(a)

end

function manage_ghostspawner(a)

end

function game_loop()

end

function draw_ui()
	rectfill(actor[2].x + 0, actor[2].y + 0, actor[2].x + 128, actor[2].y + 16,6)
	print("pills "..pkup_cont,actor[2].x + 8, actor[2].y + 6,0)
	print("time "..gametimer.elapsed,actor[2].x + 72, actor[2].y + 6,0)
end

function init_sweetdreams()
	init_timers()
	gametimer=add_timer("gametimer", time_to_play)
end