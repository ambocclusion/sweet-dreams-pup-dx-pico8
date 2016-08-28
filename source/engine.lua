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
	anim(a,a.anims[a.curranim])
	
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
		if t=="ghost" then manage_ghost(a) end
		if t=="ghost_spawner" then manage_ghostspawner(a) end
	end
end

function manage_camera(a)
	--moveto(a, actor[1].x-64, actor[1].y-64, 1)
	a.x=actor[1].x-64
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
		a.velx+=a.speed * a.dx
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

	if(a.velx<-a.maxspeed)a.velx=-a.maxspeed
	if(a.velx>a.maxspeed)a.velx=a.maxspeed
	--if(a.vely<-a.maxspeed)a.vely=-a.maxspeed
	if(a.vely>a.maxspeed)a.vely=a.maxspeed

	--if not solid_area((a.x+(a.spw*4))+a.velx,(a.y+(a.sph*4))+a.vely,a.spw*4,a.sph*4)
	if not solid_a(a, a.velx, 0)
	then
		a.x+=a.velx
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
	if (btn(2)) actor[1].dy=-1
	if (btn(3)) actor[1].dy=1

	if actor[1].dx != 0 then
		actor[1].curranim=2
	else
		actor[1].curranim=1
	end
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

function _update60()
	update_timers()
	foreach(actor,manage_actor)
	game_loop()
end

function _draw()
	cls()
	palt(15, true)
	map(0,0,0,0,128,128)
	foreach(actor,draw_actor)
	camera(actor[2].x,actor[2].y)
	draw_ui()
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
	addToPrintQ(a.x.." "..a.y .." "..(a.y+24).." "..val)
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