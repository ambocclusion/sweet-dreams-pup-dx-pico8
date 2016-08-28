pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/timer.lua


-- creates and runs timers
-- also supports pausing and resuming
-- full info: http://www.lexaloffle.com/bbs/?tid=3202

-- Contributors: BenWiley4000

local timers = {}
local last_time = nil

function init_timers ()
	last_time = time()
end

function add_timer (name,
		length, step_fn, end_fn,
		start_paused)
	local timer = {
		length=length,
		elapsed=0,
		active=not start_paused,
		step_fn=step_fn,
		end_fn=end_fn
	}
	timers[name] = timer
	return timer
end

function update_timers ()
	local t = time()
	local dt = t - last_time
	last_time = t
	for name,timer in pairs(timers) do
		if timer.active then
			timer.elapsed += dt
			local elapsed = timer.elapsed
			local length = timer.length
			if elapsed < length then
				if timer.step_fn then
					timer.step_fn(dt,elapsed,length,timer)
				end  
		else
				timer.active = false
				if timer.end_fn then
					timer.end_fn(dt,elapsed,length,timer)
				end
			end
		end
	end
end

function pause_timer (name)
	local timer = timers[name]
	if (timer) timer.active = false
end

function resume_timer (name)
	local timer = timers[name]
	if (timer) timer.active = true
end

function restart_timer (name, start_paused)
	local timer = timers[name]
	if (not timer) return
	timer.elapsed = 0
	timer.active = not start_paused
end


-- end /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/timer.lua


-- /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/sweetdreams_gameplay.lua


pkup_cont=0
time_to_play=180.0
game_timer={}

function setup_actors()

	plr = create_actor(32,92,2,2)
	plr.speed=2
	plr.maxspeed=4
	plr.flip=true
	add(plr.type,"player")
	add(plr.type,"health")
	add(plr.type,"jumpable")
	add(plr.type,"ghost_collision")
	-- idle anim
	idle=plr.anims[1]
	idle.speed=8
	run=create_anim(plr)
	run.start=10
	run.frames=3
	run.speed=8

	local camera = create_actor(0,0,0,0)
	add(camera.type,"camera")
	camera.speed=.25
	camera.maxspeed=.25

	create_ghosts()
	create_pills()
end

function create_pills()
	for x=0,128,1 do 
		for y=0,128,1 do 
			if(fget(mget(x,y),3)) then
				pill=create_actor(x*8,y*8,1,1)
				pill.sp=64
				pill.yoffset=-4
				pill.maxspeed=8
				add(pill.ignoretypes,"ghost")
				pill.anims[1].start=64
				pill.anims[1].frames=6
				pill.anims[1].reverse=true
				mset(x,y,0)
			end
		end
	end
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

function manage_ghostspawner(a)

end

function game_loop()

end

function draw_ui()
	rectfill(actor[2].x + 0, actor[2].y + 0, actor[2].x + 128, actor[2].y + 16,6)
	print("pills "..pkup_cont,actor[2].x + 8, actor[2].y + 6,0)
	print("time "..flr(gametimer.length-gametimer.elapsed),actor[2].x + 72, actor[2].y + 6,0)
end

function init_sweetdreams()
	music(1)
	init_timers()
	gametimer=add_timer("gametimer", time_to_play)
end


-- end /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/sweetdreams_gameplay.lua


-- /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/ghost_logic.lua


ghost_detect_dist=48

function create_ghosts()
	sfx(2,0)
	sfx(1,1)
	for x=0,128,1 do 
		for y=0,128,1 do 
			if(fget(mget(x,y),4)) then
				create_ghost(x*8,y*8)
				mset(x,y,0)
			end
		end
	end
	
end

function create_ghost(x,y)
	ghost=create_actor(x,y,2,2)
	add(ghost.type, "ghost")
	ghost.speed=1
	ghost.maxspeed=.5
	ghost.yoffset=-8
	ghost.state="idle"
	ghost.idlepoints={}
	add(ghost.idlepoints,ghost.x - 64)
	add(ghost.idlepoints,ghost.x + 64)
	ghost.chasedist=92
	ghost.movingto=1
	ghost.anims[1]=create_anim(ghost)
	idleanim=ghost.anims[1]
	idleanim.start=42
	idleanim.speed=6
	idleanim.frames=3
	ghost.anims[2]=create_anim(ghost)
	attackanim=ghost.anims[2]
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
	actor[1].velx=(actor[1].x-col.x)*.75
	if(actor[1].velx > actor[1].maxspeed*3) actor[1].velx=actor[1].maxspeed*2
	if(actor[1].velx < -actor[1].maxspeed*3) actor[1].velx=-actor[1].maxspeed*2
	actor[1].vely=-12
end

function ghost_logic(a)

	a1,a2=solid_actor(a,a.velx,a.vely)

	if(a2!=nil) then
		for t in all(a2.type) do
			if(t=="player")	ghost_collide(a)
		end
	end

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


-- end /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/ghost_logic.lua


-- /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/engine.lua


-- print queue
printq = {}
function printFromQ()
	for i,m in pairs(printq) do
		print(m,actor[2].x, actor[2].y + (32 + (8 * (i - 1))))
	end
	printq = {}
end
function addToPrintQ(message)
	add(printq, message)
end

-- start engine
actor={}
debug=true
caninput=true
gravity=2
gamemode="game"

function create_actor(x,y,sizex,sizey)
	a={}
	a.x=x
	a.y=y
	a.spw=sizex
	a.sph=sizey
	a.sp=0
	a.dx=0
	a.dy=0
	a.velx=0
	a.vely=0
	a.speed=1
	a.maxspeed=1
	a.maxhealth=6
	a.curhealth=a.maxhealth
	a.type={"actor"}
	a.ignoretypes={}
	a.flip=false
	a.bsx=0
	a.bsy=0
	a.xoffset=0
	a.yoffset=0
	a.anims={}
	a.curranim=1
	create_anim(a)
	add(actor,a)
	
	return a
end

function draw_actor(a)

	--if(a.x<actor[2].x+160 and a.x>actor[2].x-32
	--	and a.y >actor[2].y-32 and a.y<actor[2].y+160)then
	--		if (a.dx > 0) then a.flip=true end
	--		if (a.dx < 0) then a.flip=false end
	--		spr(a.sp,a.x,a.y,a.spw,a.sph, a.flip) end
	if (a.dx > 0) then a.flip=true end
	if (a.dx < 0) then a.flip=false end
	if(a.x<actor[2].x+160 and a.x>actor[2].x-32
			and a.y >actor[2].y-32 and a.y<actor[2].y+160)then
		anim(a,a.anims[a.curranim],a.xoffset,a.yoffset)
	end
	
end

function manage_actor(a)
	for t in all(a.type) do
		if t=="player" then player_manager(a) end
		if t=="enemy" then enemy_manager(a) end
		if t=="health" then health_manager(a) end
		if t=="actor" then adjust_velocity(a) end
		if t=="jumpable" then manage_jumper(a) end
		if t=="camera" then manage_camera(a) end
		if t=="talkable" then manage_talker(a) end
		if t=="pickup" then manage_pickup(a) end
		if t=="ghost" then ghost_logic(a) end
		if t=="ghost_spawner" then manage_ghostspawner(a) end
		if t=="ghost_collision" then manage_ghost_collision(a) end
	end
end

function manage_camera(a)
	--moveto(a, actor[1].x-64, actor[1].y-64, 1)
	if(actor[1].flip) then
		a.x+= ((actor[1].x-48) - a.x) * a.maxspeed
	else
		a.x+= ((actor[1].x-68) - a.x) * a.maxspeed
	end
	a.y=0
end

function player_manager(a)
	control_player()
end

function enemy_manager(a)
	a.dx = 0
	a.dy = 0
end

function health_manager(a)
	if a.curhealth <= 0 then
		del(actor,a)
	end
end

function adjust_velocity(a)
	--check to make sure dir is >0

	if (a.dx==0) then
		a.velx=movetowards(a.velx,0,a.speed)
	else 
		if(a.dx > 0 and a.velx < a.maxspeed) then
			a.velx+=a.speed
		elseif(a.dx < 0 and a.velx > -a.maxspeed) then
			a.velx-=a.speed
		end
	end
	
	if(a==actor[2]) then
		if (a.dy==0) then
			a.vely=movetowards(a.vely,0,a.speed)
		else 
			a.vely+=a.speed * a.dy
		end
	else
		a.vely += gravity
	end

	--if(a.velx<-a.maxspeed)a.velx=-a.maxspeed
	--if(a.velx>a.maxspeed)a.velx=a.maxspeed
	--if(a.vely<-a.maxspeed)a.vely=-a.maxspeed
	if(a.vely>a.maxspeed)a.vely=a.maxspeed

	--if not solid_area((a.x+(a.spw*4))+a.velx,(a.y+(a.sph*4))+a.vely,a.spw*4,a.sph*4)
	if not solid_a(a, a.velx, 0)
	then
		if(a.velx > 0 and a.x < 126*8) a.x+=a.velx
		if(a.velx < 0 and a.x > 4) a.x+=a.velx
	end
	if not solid_a(a, 0, a.vely)
	then
		a.y+=a.vely
	end

end

function control_player()
	actor[1].dx = 0
	actor[1].dy = 0
	if not caninput then return end
	if (btn(0)) actor[1].dx=-1
	if (btn(1)) actor[1].dx=1
	if (btn(2))	actor[1].dy=-1
	if (btn(3)) actor[1].dy=1	

	if actor[1].dx != 0 then
		actor[1].curranim=2
	else
		actor[1].curranim=1
	end
end

function add_soft_push(a, amt)
end

function manage_animation(a)
	
end

function create_anim(a)
	-- create animations and set defaults
	an={}
	an.start=0
	an.frames=4
	an.speed=7
	an.flipx=false
	an.flipy=false
	an.loop=true
	an.reset=false 
	an.step=0
	an.current=1
	an.reverse=false
	add(a.anims,an)
	return an
end

function _update()
	if(gamemode=="game") then
		update_timers()
		foreach(actor,manage_actor)
		game_loop()
	end
end

function _draw()
	cls()
	palt(0, false)
	palt(15, true)
	if(gamemode=="game") then
		rectfill(actor[2].x - 32,actor[2].y,actor[2].x + 152,actor[2].y + 120,5)
		rectfill(-128,0,-1,128,0)
		rectfill(128*8,0,170*8,128,0)
		map(0,0,0,0,128,128)
		foreach(actor,draw_actor)
		camera(actor[2].x,actor[2].y)
		draw_ui()
	end
	if(debug)printFromQ()
end

function _init()
	init_sweetdreams()
	setup_actors()
end

function debug_function()
	print("x"..actor[1].x,actor[1].x-48,actor[1].y-48,8)
	print("y"..actor[1].y,actor[1].x,actor[1].y-48, 8)
end

-- utility functions
function movetowards(num, target, speed)
	if(abs(target - num) < speed)
		then return target	end
	if(target > num)
		then return num + speed end
	if(target < num)
		then return num - speed end
end

function moveto(a, x, y, sp)
	a.dx=0
	a.dy=0
	if(a.x < x) a.dx+=sp
	if(a.x > x) a.dx-=sp
	if(a.y < y) a.dy+=sp
	if(a.y > y) a.dy-=sp

	if(a.x == x and a.y == y)	return true
	return false
end

function is_type(a, t)
	for ts in all(a.type) do
		if(ts==t)	return true
	end
	return false
end

function compare_ignore(a,a2)
	--if(a.ignoretype == {} and a2.ignoretype == {}) then return false end
	for t in all(a.ignoretypes) do
		for ty in all(a2.type) do
			if t==ty then
				return true
			end
		end
	end
	for t in all(a2.ignoretypes) do
		for ty in all(a.type) do
			if t==ty then
				return true
			end
		end
	end
	return false
end

function zspr(n,w,h,dx,dy,dz,flipx,flipy)

	sx = 8 * (n % 16)
	sy = 8 * flr(n / 16)
	sw = 8 * w
	sh = 8 * h
	dw = sw * dz
	dh = sh * dz

	sspr(sx,sy,sw,sh, dx,dy,dw,dh,flipx,flipy)

end

--collision code

function solid(x, y)

	-- grab the cell value
	val=mget(x/8, y/8)

	-- check if flag 1 is set (the
	-- orange toggle button in the 
	-- sprite editor)
	return fget(val, 1)

end

function touch_ground(a)
	-- grab the cell value
	val=mget(a.x/8, (a.y+24)/8)
	return fget(val, 2)
end

function solid_area(x,y,w,h)
	return 
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end

function solid_actor(a, dx, dy)
	for a2 in all(actor) do
		--local ignore=compare_ignore(a,a2) or compare_ignore(a2,a)
		if a2 != a then
			local x=(a.x+dx) - a2.x
			local y=(a.y+dy) - a2.y
			if ((abs(x) < ((a.spw*4)+(a2.spw*4))) and
				(abs(y) < ((a.sph*4)+(a2.sph*4))))
			then 
				local ignore=compare_ignore(a,a2)
				if ignore==true then
					return false,nil end
				-- moving together?
				-- this allows actors to
				-- overlap initially 
				-- without sticking together    
				if (dx != 0 and abs(x) <
					abs(a.x-a2.x)) then
					return true,a2 
				end

				if (dy != 0 and abs(y) <
					abs(a.y-a2.y)) then
					return true,a2 
				end

			--return true

			end
		end
	end
	return false,nil
end


-- checks both walls and actors
function solid_a(a, dx, dy)
 if solid_area((a.x+dx+(a.spw*4)),(a.y+dy+(a.sph*4)),
	a.spw*4,a.sph*4) then
	return true end
 return solid_actor(a, dx, dy)
end

function distance(sx, sy, x, y)
	xd = x-sx
	yd = y-sy
	local r = sqrt((xd*xd) + (yd*yd))
	if(r > 0) return r
	return 181
end


-- end /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/engine.lua


-- /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/animation.lua


-- Animation function that supports
-- animation speed, looping (or not looping),
-- stopping on a specific frame, flipping
-- horizontal and/or vertical, and playing
-- in reverse

-- Contributors: Scathe (@clowerweb)

function anim(a,anim,offx,offy)
 if(anim.loop!=false) then
  anim.loop=true
 end

 anim.flipx=a.flip

 anim.step=anim.step or 0

 local sta=anim.start
 local cur=anim.current or 0
 local stp=anim.step
 local spd=anim.speed
 local flx=anim.flipx
 local fly=anim.flipy
 local rst=anim.reset or 0
 local lop=anim.loop
 local rev=anim.reverse or false

 anim.step+=1
 stp=anim.step
 if(not rev) then
  if(stp%flr(30/spd)==0) cur+=1
  if(cur==anim.frames) then
   if(lop) then cur=0
   else cur-=1 end
  end
 else
  if(stp%flr(30/spd)==0) cur-=1
  if(cur<0) cur=0
 end

 anim.current=cur

 if(not offx) offx=0
 if(not offy) offy=0

 spr(sta+(cur*a.spw),a.x+offx,a.y+offy,a.spw,a.sph,flx,fly)
end -- anim


-- end /Users/Allen/Library/Application Support/pico-8/carts/jams/sweetdreams/Source/animation.lua


__gfx__
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff11fffff111fffffffffffffffffffffffffffffffffffff
f11ffff11ffffffffffffffffffffffffffffffffffffffffffffffffffffffff11ffff11fffffff199111f19991ffffffffffffffffffffffffffffffff11ff
1991ff1991fffffff11ffff111fffffffffffffffffffffff11ffff11fffffff1991ff1991ffffff119aaa199991fffff111fff111f11fffff11ffff11f1991f
19191199991fffff1991ff1999111ffff111fff11f11ffff1991ff1991f11fff19191199991fff1ff19aa9a9911ffffff1991f19991991fff199111199111991
119aaaa1991fff1f19191199991991ff1999111991191fff19191199991991ff119aaaa1991ff191191aa19a1ffff11ff19111999919991ff191aaa999911a1f
f19aa9aa11fff191119aaaa111aa991f191aaa99991191ff119aaaa1991a991ff11aa19a1111f191191aa19a1fff1991ff1aaa99911a9991ff19aa9a19911a1f
f11aa19a1ffff191f11aa19a1f1aa991119aa9a1991191fff19aa9aa1111aa91191aa19aa1aa1a911a119aaa9111a911f19aa9a11ff1aa11ff11aa11aa11a1ff
191aa19aa1111a91191aa19aa1aaaa1ff11aa11a1111a1ff111aa11aa111aa911a119aaaaaaa1a1f1aaaa1aa1aaaa1fff11aa11a111aa1fff1a119aaaaaaaa1f
1a119aaa9aaaaa1f1a119aaa9aaaa1ff1a119aaaaaaaaa1f1a119aaaaaaaa11f1aaaa1aa91aaa1ff191e1aa91aaaaa1f1a119aaaa1aaaa1ff1aaaa1aa91aaa1f
1aaaa1aa1aaaa1ff1aaaa1aa1aaaaa1f1aaaa1aaa1aaaa1f1aaaa1aa91aaaa1f191e1aaa91aaa1ff191e19919aaaaa1f1aaaa1aaa91aaaa1f191e1aaa91aaaa1
191e1aa91aaaaa1f191e1aa91aaaaa1f191e1aaa91aaaa1f191e1aaa91aaaa1ff19199911aaaaa1ff1111119aaaaaa1f191e1aaaa91aaaa1ff11e19991aaaaa1
f19199919aaaaa1ff11e19919aaaaa1f1991999919a9aa1ff11e19991aaaaa1ff1111119aaaaaa1ff119999aaaa9aa1f191e1aa991aaaaa1ff1111111aaa9aa1
f1111119aaaaaa1ff1111119aaa9aa1ff11111119aa1a1fff1111111aaa9a1fff191999aaaa1aa1f191aaa1aaaa1aa91f11111111aa9aaa1fff19aaaaaaa1aa1
f1919999aaa19a1ff1919999aaa1a1fff1911999aaa1a1fff1919999aaa1a1fff191aaa1aaa1aa1f11aaa11111111991f1919991aaa1aa1ffff11aa11111aa1f
f191a9111111a1fff191a9111111a1fff191a911111aa1fff191a911111aa1ff191aaa111119a1ff19991ffffff11991191aaa111119aa1fffff1aa91119aa1f
191991ff191991ff191991ff191991ff191991ff191991ff191991ff191991ff191991fff11991fff111fffffffff111191991fff11991ffffff1199919991ff
fffffdddddffffffffffffffffffffffffffffffffffffffffffdddddddfffffffffdddddddffffffffffdddddffffffffffffdddffffffffffffddddddfffff
ffffd66666ddfffffffffffffffffffffffffdddddfffffffffd6666666dfffffffd6666666dffffffffd66666ddffffffffdd666ddffffffffdd666666dffff
fffd66666666dffffffffddddddffffffffdd66666dfffffffd6d6666d66dfffffd666666666dffffffd66666666dffffffd6666666dffffffd666666666dfff
ffd666666666dffffffdd666666dffffffd6d6666d6dffffffdddd66ddd6dfffffd6d6666d66dfffffd666666666dfffffd666666666dfffffd6666666666dff
ffd6d6666d666dffffd666666666dfffffdddd66ddd6dfffffd6dd66dd666dffffdddd66ddd66dffffd6d6666d666dffffd6666666666dfffd66d6666d666dff
fd6ddd66ddd66dffffd6666666666dffffd6dd66dd666dfffd66d6666d666dfffd66dd66dd666dfffd6ddd66ddd66dffffd6d6666d666dfffd6ddd66ddd666df
fd66dd66dd6666dffd66666666666dfffd66d6666d666dfffd6ee6666ee666dffd6ee6666ee666dffd66dd66dd6666dffd6ddd66ddd66dfffd6ed6666de666df
fd6ee6666ee666dffd6dd6666dd666dffd6ee6666ee666dffd6ee6dd6ee666dffd6666dd666666dffd6ee6666ee666dffd6ee6666ee666dfffd6ed66de6666df
fd666d66d66666dffd66dd66dd6666dffd6666dd666666dffd6666dd666666dffd666666666666dffd666d66d66666dffd666d66d66666dfffd666dd666666df
fd6666dd666666dffd6ee6666ee666dfffd666dd66666dfffd6666dd66666dfffd666666666666dffd6666dd666666dfffd666dd666666dfffd6666666666dff
ffd66666666666dffd666dddd66666dfffd666666666dfffffd666dd66666dffffd6666666666dffffd66666666666dfffd6666666666dfffd66666666666ddd
ffd6666666666dffffd6666666666dfffffd66666666dfffffd666666666dffffd666666666666dffd66666666666ddfdd66666666666dfffd666666666666dd
ffd6666666666dfffd6d66666666d6dffffd66666666dfffffd666666666dffffd66d666dd66d6dfd6666666dd666d6dd6666666666d66ddfd666dd66666666d
fd666666666666dffd66666666dd66dffffd66666666dffffd6666666666dffffdddfdddddddfddfd666666dddd6666dd6dd6666d6ddd66dd666ddd6666d666d
fd6d66ddd666d6dfffdd6ddd66666dfffffd6d66dd6dfffffd66d66ddd66dfffffffffffffffffffdd6d66ddddd6d6ddfdddd66dfddddddfdd6ddddd66dddddd
ffddddddddddddffffffdddddddddfffffffdddddddfffffffdddddddfdddfffffffffffffffffffffdddddfffddddffffdddddffffdddffffddfffdddffddff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff11ffff11fffffffffffffffffffffffffffffff
f111222fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1991111991fffffff1111ff111ffffffffffffff
1ccc7782f111222ffffffffffffffffffffffffffffffffffffffffff11ffff11fffffffffffffffffffffff1991aa99991fffff1991a119991fffffffffffff
1ccc88821ccc7e82f111222fffffffffffffffffffffffffffffffff1991ff1991fff1ffffffffffff11ffff191aaaa19991ffff191aaaa19991ffffffffffff
f111222f1ccc88821ccc7882ffffffffffffffffffffffffffffffff19191199991f191ff11ffff11f191ffff19aa91a1991fffff19aa91a1991ffffffffffff
fffffffff111222f1ccc8882ffffffffffffffffffffffffffffffff119aaaa1991f191f19911119911191ff191aa19aa11fff1f191aa19aa11fffffffffffff
fffffffffffffffff111222ffffffffffffffffffffffffffffffffff19aa9aa111f191f119aaa99991191ff1a119aaaaa1ff1911a119aaaaa1fff1fffffffff
fffddffffddddddffddddddffffffffffffffffffffffffffffffffff11aa19a1111aa1ff19aaaa19911aa1f1aaaaaaaa1a1f1911aaaaaaaaaa1f191ffffffff
ffffffffffffffffffffffffffffffffffffffffffffeffffffffdff191aa19aaaaaaa1ff19aa91a111aaaa119a11aaa91aa1a9119a1aaaa1aaa1191ffffffff
fffffffffffffffffffffffffffffffffffcfffffffffeffffffffdf1a119aaa9aaaaaa1191aa19aaaaaaaa1f1a11aa919aaaa1ff1a11aaa1aaaaa91ffffffff
fffffffffffffffffaffffffffbfffffffffcffffeffffeffffdfffd1aaaaaaa1aaaaaa11a119aaaa9aaaaa1f11999919aaaaa1ff1a11991aaaaaa1fffffffff
8ffffffff9ffffffffaffffffffbfffffcfffcffffefffefdfffdffd1911aaa91aaaaaa11aaaaaaa91a9aaa1ff111119aaaaaaa1ff19911aaaaaaaa1ffffffff
8ffffffff9ffffffffaffffffffbfffffcfffcffffefffefdfffdffdf19999919aa1aa1f1911aaaa91a1aa1ff191999aaaaaaaa1f191199aaaaaaaa1ffffffff
fffffffffffffffffaffffffffbfffffffffcffffeffffeffffdfffdf1111119aaa19a1ff19999991aa19a1ff191aaaaaaa1aaa1f191aaa1aaa1aaa1ffffffff
fffffffffffffffffffffffffffffffffffcfffffffffeffffffffdff191a91aa11aa1fff11111119a1aa1fff191a911111aaa1ff191a91f111aaa1fffffffff
ffffffffffffffffffffffffffffffffffffffffffffeffffffffdff19199111191991ff19199911111991ff191991ff191991ff191991ff191991ffffffffff
ffffffffffffffffffffffffffffffffff000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffff0000fffffffffffffffffffff00000eeeeee0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff00eeee00ffffffffffffffffff0eeeeeeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0eeeeeeee0ffffff000ffffff000eeeeeeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeeeee000ff0eee0fff00ee0eeeeeeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeeeee0ee0f0eee00f0eeeee00eeeeeeeee0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeee0eeeeee0ee00eee0e00eeeeee00eeee00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeee00eeeee0ee00eee0eee0eee0000eee00000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00eeee0eeee0ee0ee0ee0eee0ee0ee0eeee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00eeeee00ee0ee0ee0ee0eee0e0eee0eeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000eeeeee00eee0ee0ee0e00eeeee00eeeee0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff00eeeee0eeeeeeeeee0eee0eee0ee0eeee0ffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0ee0eeeee0eeeeeeee0eeee0ee0eee0eeee00ffffffff0000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eee00eeee0eeee0eee0ee000eeeeee0eeee00fffffff000eee000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eee00eeeee0eee0ee0ee0eee0eeee0eeeee00ffffff00eeeeeee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeee0eeee0ee0eee0eeeeee0eee00eeee000f0000f0eeeeeeeee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00eeeeeeeee0ee0ee0eeeeee0ee00000ee00000000000eeeeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00eeeeeeeee00000000eee00000ee000000ee00eee00eeeeeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000eeeeeee0000eeee0000eeee0eeee00eeeee0eeee0eeeeeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f000eeeee00eeeeeeee00eeeee0eeeee0eeeee0eeee0eeee00eeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0ee000000eee00eeee0eeeeeee0eeee0eeeeee0eeee0ee0000eee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeee00ee000eeee0eeeeeee0e0ee0eeeeee0eeee0eeeeee00000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeee0eee00eee0eeeeeeee0e00ee0eeeeeeeeeee0eeeeee000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeeee0eeeeeee0eee00ee0ee00ee0eee0eeeeeee0eeeeeeee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeeee0eeeee00eee0ee00eee0eee0eee0eeee0eee0eeeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00ee000eeee0eeeee00eeeee00eeeeeee0eee0eeee0eee00eeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0eee000eee0ee0eeee0eee000eeeeeee0eeee0ee0eeee0e0000eee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0eee00eeee0eee0eeee0e0eee0ee0eee0eeeee00eeeeee0e00eeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0ee00eeeee0eee0eeee0eeeee0ee0eee0eeeee00eeeeee0eeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0eeeeeeeee0eee00eee0eeee0eee0ee00eeeee00eeeeee0eeeeeee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000eeeeeee0eeee00000eee00eee0eee000eee000eeeee0eeeeeee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeeee0eeee00eee000000000ee000000000000eee0eeeeeee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeeee00eee0eeeeeee000000000000eeeeeeee0000000eeee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0eeeeeee000000eeeeeeeee00eee000000eeeeeeeeee00f0000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00eeeee00000eee0000eeee0eeeee00eee0eeeeeeeeee00ff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000000eeeee000eeee0eeeee0eeeee0ee000eeee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f000000ff00eeeee00eeeee0eeeee0eeeee0eee000eee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffff00eee0eeeeee00eeeee0eeeee0eee00eeee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffff00eeeeeeeeee0eeeee0eeeeee0eeeeeeeee00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffff00eeeeeeee00eeeee0eeeee0eee0eeeee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffff00eeeee00000eeeee00eeee0eeee000000fffffffffff111111111111111111111111fffffffff15555555555555fffffffffffffffffffffffff
ffffffffffff00eeeeee000eeeeeeeeee00eeeee0000ffffffffffff122222222222222d22222222fffffffff15111111111115fffffffffffffffffffffffff
ffffffffffff00eeeeee000eeeeeeeeee00eeeee0fffffffffffffff122222222222222d00000000fffffffff15111111111615fffffffffffffffffffffffff
fffffffffffff00eeeeee000eeeeeeee000eeeee0fffffffffffffff121111222111122d55555555fffffffff15141211111115fffffffffffffffffffffffff
fffffffffffff00eeeeee0000eeeee000f0eeee00fffffffffffffff12122d222122d22d55555555fffffffff15111111111615fffffffffffffffffffffffff
ffffffffffffff00eeeee00f00000000ff00eee00fffffffffffffff12122d222122d22d55555555fffffffff15141111111115fffffffffffffffffffffffff
ffffffffffffff00eeee00fff00000fffff00000ffffffffffffffff12122d222122d22d55555555fffffffff15111111611115fffffffffffffffffffffffff
fffffffffffffff000000fffffffffffffff000fffffffffffffffff12122d222122d22d55555555fffffffff15111111111115fffffffffffffffffffffffff
ff2288ffffffffffffffff1221fffffffefffffffffdfeffffffffff12122d222122d22d2222222200000000f15111111111115fffffffffffffffffffffffff
f261678fffffffffffffff1661ffffffe7ebbaffffcbe6efffffffff12122d222122d22ddd2ddd2d00000000f1533ddddddddd5fffffffffffffffffffffffff
26667178fffffffffffff167761fffffeeeb3b3ffc6cde3fffffffff121ddd2221ddd22dd222d22200000000f15555555555b55fffffffffffffffffffffffff
26661772ffffffffffff16767761ffff3e3bbbafffceddcfffffffff12111d222111d22d22d222d211111111fffff1000001ffffffffffffffffffffffffffff
21621172fffffffffff1677676761fff3333b3bff3e6e6ccffffffff121111222111122d2ddd2ddd11111111f15555555555555fffffffffffffffffffffffff
26666662ffffffffff167676767761ff33b33b3ff3de3bcfffffffff122222222222222ddddddddd11111111f150000051555b5fffffffffffffffffffffffff
f266162fffffffffff166666666661fff333b3fffdb3c3efffffffff122222222222222d2222222211111111f15555555555555fffffffffffffffffffffffff
ff2222ffffffffffff111111111111fff33333ffff3d333fffffffff122222222222222d5555555511111111f00000000000000fffffffffffffffffffffffff
11111111f555fffffffff2ee1e2fffff2222222fffffffffffffffff122222222222222d51111111111111111111111fff2222fffff00fffffffffff55555555
999999995575ffffffff2e7e17e2ffff4444449ffff6ffffffffffff122222222219a22d122222222222222222222221f211112f44444444ffffffff55d222d5
4444444416775fffffff27ee2ee2ffff4444449ff6ffbffeffffffff12222222219a7a2d12ddddddddddddddddddd221f266612f41111114ffffffff552dee25
44444444111765ffffff27eeeee2fffff44449ffffbe363fffffffff122222222149a92d12d0111111d1111111111221f2dee12f4dd6d614ffffffff552d2e25
00000000fff16755ffff2eeeeee2fffff44449ff3fb3b33bffffffff122222221114922d12d000161111111111111221f2dde12f4dee6614ffffffff552d2e25
22222222ffff1675fffff2eeee2ffffff22222ffbb63bebbff4444ff122222221111122d12d001111111111111111221f2ded12f4deed614ffffffff552d2e25
22222222ffff1611fffff2e2222fffff4444499ffb3b3b6ff2848e2f122222222111222d12d000111116111111111221f122221f44444444ffffffff551dde15
00000000ffff111fffff2eee2222fffff22222ffff33333f228884e2122222222222222d12d000001111111111160221ff1111ff11111111ffffffff55511155
11111111111111111111111111111111881111888222222222222228122222222222222d12d000001111111d11110221f33333333333333f1100110055555555
19999999999999991444999999944441818228182888888888888882122222222222222d12d000011611111111100221f31111111111113f0100110055555555
14444444444444441000000000000001182112812888888888888882122222222222222d12dddddddd5555ddddddd221f36dd66ddd6dd13f0000110055555555
14444444444444441444444444444441121221212888888888888882121111222111122d122222222222222222222221f3d6dee6ded6d13f0000010022222222
1000000000000000141111111111114112121121188888888888888112122d222122d22d122222222222222222222221f3de6ee66eed613f10000000e2e2e2e2
1222122222212221141444444444414112122221188888888888888112122d222122d22d12d000001111111110000221f3ddeeee6eed613f1100000022222222
1222122222212221141449444494414118211281188888888888888112122d222122d22d12d000011111111000100221f33333333333333f11001000dddddddd
1444100000014441141441977914414118221281288888888888888212122d222122d22d12d001001111111110000221f11111111111111f1100110022222222
1001222222221001141444111144414118222281211111111111111212122d222122d22d12d0000111111111010002211111111155555555de6edddd22222222
1221000000001221141444444444414118222281888888888888888812122d222122d22d12d0000010110110000002212222222255555555ddeddddd00000000
14412222222214411400000000000041182222818888888888888888121ddd2221ddd22d12d000001001000000000221dddddddd555555552222222222222222
1441dddddddd1441144444444444444118222281222222222222222212111d222111d22d12d000000000000000000221111111115555555522222222ddeddddd
1441dddddddd14411444444444444441111111112111111111111111121111222111122d12d0000000000000000002211111dd115555555500000000de6edddd
1441ddeddded14411411111111111141182828282828282828282828122222222222222d1dddddddddddddddddddddd1111d66d15555555500000000ddeddded
1441de6ede6e14411910000000000191182828282828282828282828122222222222222d122222222222222222222221111d66d15555555511001100ddddde6e
1441ddeddded1441191edddededdd19112112212222121221122111811111111111111115111111111111111111111151111dd115555555511001100ddeddded
__gff__
0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaca
b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9
c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d9dadb000000b7b800000000d9dadb000000b7b8000000d9dadb00000000b7b80000000000d9dadb000000b7b800000000d9dadb000000b7b8000000d9dadb00000000b7b80000000000d9dadb000000b7b800000000d9dadb000000b7b8000000d9dadb00000000b7b80000000000d9dadb000000b7b800000000d9da
000000e9eaeb000000c7c800000000e9eaeb000000c7c8000000e9eaeb00000000c7c80000000000e9eaeb000000c7c800000000e9eaeb000000c7c8000000e9eaeb00000000c7c80000000000e9eaeb000000c7c800000000e9eaeb000000c7c8000000e9eaeb00000000c7c80000000000e9eaeb000000c7c800000000e9ea
000000f9fafb000000d7d800000000f9fafb000000d7d8000000f9fafb00000000d7d80000000000f9fafb000000d7d800000000f9fafb000000d7d8000000f9fafb00000000d7d80000000000f9fafb000000d7d800000000f9fafb000000d7d8000000f9fafb00000000d7d80000000000f9fafb000000d7d800000000f9fa
000000000000000000e7e800004000400040004000e7e800000000000000000020e7e80000000000000000000000e7e800204000400040004000e7e800000000000000000000e7e80000000000000000000000e7e800004000400040004000e7e800000000000000000000e7e80000000000000000000000e7e8000040004000
efefefefefefefefeff7f8efefefefefefefefefeff7f8efefefefefefefefefeff7f8efefefefefefefefefefeff7f8efefefefefefefefefeff7f8efefefefefefefefefeff7f8efefefefefefefefefefeff7f8efefefefefefefefefeff7f8efefefefefefefefefeff7f8efefefefefefefefefefeff7f8efefefefefef
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002651127511265212552126521275312653125531265412754126541255512655127551265612556126561275612655125551265512754126541255412653127531265312552126521275212651125511
0104000008031090310a0310903108031090310a0310903108031090310a0310903108031090310a0310903108031090310a0310903108031090310a0310903108031090310a0310903108031090310a03109031
010400001d1111e1111f111201112112122121231212412125131261312713128131291442a1442914428144291442a1342913428134291342a1342912428124291242a1242912428114291142a1142911428114
010400001c63628251282512724126241252312423124231292011f6062b2012b2012a2012920128201272012b2012b2012a201292012820127201272012b1012b1012b1012b1012b1012b1012b1012b1012b101
010e00001157122571165312a5021d502145011050009500015000350001500024000f5003150029500215001b50016500115000c5000b5003f5003e5003a50033500245001a5001570013700127000f7000c700
010a00002403118031300412d00200000000000000000000000000000000000355000000006500000000000000000000000150000000000000000000000000000000000000000000000000000000000000000000
010800000b647126370f6270b627106010d60110601106070f6070c6070e6070e6070d6070b607000070000700007000000000000000000000000000000000000000000000000000000000000000000000000000
011a000024625246052462524005246252e6052462528605246252400524625240052462524005246252400524625240052462524005246252400524625240052462524005246252400524025240052462524005
010d000024625246052460524005246252e605246052860524625240052460524005246252400524605240052462524005246052400524625240052460524005246252400524605240050e020240052460524005
011a0020267202d5452b5452a5452672026705267202d5452b5452a5452672024005267202d5452b5452672024005267202d5452b5452672024000267202a545285452672024000267202b5452a5452672000000
011a00000e0200e02000000000000e0200e020000000000013020130201002013020150201502000000000000e0200e02000000000000e0200e0200000000000150201502012020150201a020190200000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01024344
00 49494909
03 410b0a08
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344




