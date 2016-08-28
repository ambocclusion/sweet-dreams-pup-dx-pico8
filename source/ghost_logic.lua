ghost_detect_dist=48

function create_ghosts()
	sfx(2,0)
	sfx(1,1)
	ghosts={}
	ghosts[1]=create_actor(128,92,2,2)
	add(ghosts[1].type, "ghost")
	ghosts[1].speed=1
	ghosts[1].maxspeed=.5
	ghosts[1].state="idle"
	ghosts[1].idlepoints={}
	add(ghosts[1].idlepoints,ghosts[1].x - 64)
	add(ghosts[1].idlepoints,ghosts[1].x + 64)
	ghosts[1].chasedist=92
	ghosts[1].movingto=1
	ghosts[1].anims[1]=create_anim(ghosts[1])
	idleanim=ghosts[1].anims[1]
	idleanim.start=42
	idleanim.speed=6
	idleanim.frames=3
	ghosts[1].anims[2]=create_anim(ghosts[1])
	attackanim=ghosts[1].anims[2]
	attackanim.start=32
	attackanim.frames=5
end

function manage_ghost_collision(a)
	a1,a2=solid_actor(a,a.velx,a.vely)

	if(a2!=nil) then
		for t in all(a2.type) do
			if(t=="ghost")	ghost_collide(a2)
		end
	end
end

function ghost_collide(col)
	actor[1].velx=(actor[1].x-col.x)*.5
	actor[1].vely=-12
end

function ghost_logic(a)
	if(a.state=="idle") ghost_idle_state(a)
	if(a.state=="chasing") ghost_chasing_state(a)
	if(a.state=="returning") ghost_returning_state(a)
end

function ghost_idle_state(a)
	a.curranim=1
	a.maxspeed=.5
	if(moveto(a,a.idlepoints[a.movingto],a.y,a.maxspeed))	iter_idlepoint(a)
	if(distance(a.x, a.y, actor[1].x, actor[1].y) < ghost_detect_dist)	a.state="chasing"
end

function ghost_chasing_state(a)
	a.curranim=2
	a.maxspeed=1.5
	moveto(a,actor[1].x,actor[1].y, 1)
	if(distance(a.x,a.y,actor[1].x,actor[1].y) >= 72)	a.state="returning"
end

function ghost_returning_state(a)
	a.curranim=1
	a.maxspeed=.5
	if(moveto(a,a.idlepoints[a.movingto], a.y,1))	a.state="idle"
end

function iter_idlepoint(a)
	a.movingto+=1
	if(a.movingto > #a.idlepoints)	a.movingto=1
end