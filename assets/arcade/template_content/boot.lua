--3D demo by MICHAL MARŠÁLEK
require "system"
gpu = system.getDevice("gpu")
gamepad = system.getDevice("gamepad")
button = {a=0, b=0}
pitch = -math.pi/5
yaw = 0.0
mesh = false
idle = 100

phi = (1 + math.sqrt(5)) / 2; a = 1.5; b = 1.5 / phi; c = b / phi;
models={
	{points={{1,1,1},{-1,1,-1},{1,-1,-1},{-1,-1,1}},
	polygons={{1,2,3},{2,4,3},{1,3,4},{1,4,2}}},--tetrahedron
	{points={{-1.7,0,0},{0,0,1.7},{1.7,0,0},{0,0,-1.7},{0,1.7,0},{0,-1.7,0}},
	polygons={{1,2,5},{2,1,6},{2,3,5},{3,2,6},{3,4,5},{4,3,6},{4,1,5},{1,4,6}}},--octahedron
	{points={{-1,-1,-1},{1,-1,-1},{1,-1,1},{-1,-1,1},{-1,1,1},{-1,1,-1},{1,1,1},{1,1,-1}},
	polygons={{1,2,3,4},{1,4,5,6},{4,3,7,5},{6,5,7,8},{2,8,7,3},{1,6,8,2}}},--cube
	{points={{0,b,-a},{b,a,0},{-b,a,0},{0,b,a},{-b,a,0},{0,-b,a},{-a,0,b},{a,0,b},{0,-b,-a},{a,0,-b},{-a,0,-b},{b,-a,0},{-b,-a,0},{-b,-a,0},{-a,0,b},{-a,0,-b}},
	polygons={{3, 2, 1}, {2, 5, 4}, {7, 6, 4}, {6, 8, 4}, {10, 9, 1}, {9, 11, 1}, {13, 12, 6}, {12, 14, 9}, {16, 15, 5}, {7, 11, 14}, {8, 10, 2}, {10, 8, 12}, {3, 15, 4}, {8, 2, 4}, {16, 5, 1}, {2, 10, 1}, {13, 11, 9}, {10, 12, 9}, {7, 14, 6}, {12, 8, 6}}},--icosahedron
	{points={{c,0,1.5},{-c,0,1.5},{-b,b,b},{0,1.5,c},{b,b,b},{b,-b,b},{0,-1.5,c},{-b,-b,b},{c,0,-1.5},{-c,0,-1.5},{-b,-b,-b},{0,-1.5,-c},{b,-b,-b},{b,b,-b},{0,1.5,-c},{-b,b,-b},{1.5,c,0},{-1.5,c,0},{-1.5,-c,0},{1.5,-c,0}},
	polygons={{5,4,3,2,1},{8,7,6,1,2},{13,12,11,10,9},{16,15,14,9,10},{15,4,5,17,14},{4,15,16,18,3},{12,7,8,19,11},{7,12,13,20,6},{5,1,6,20,17},{13,9,14,17,20},{16,10,11,19,18},{8,2,3,18,19}}}--dodecahedron
}
id = 5

function processInput()
	button.a = gamepad.getButton(0) and button.a + 1 or 0
	button.b = gamepad.getButton(1) and button.b + 1 or 0
	a = button.a == 1; b = button.b == 1
	
	yaw = yaw + gamepad.getAxis(0)*math.pi/90	
	pitch = pitch + gamepad.getAxis(1)*math.pi/90
	idle = idle + 1
	if a or b or gamepad.getAxis(0) ~= 0 or gamepad.getAxis(1) ~= 0 then	
		idle = 0
	end
	if idle >= 100 then
		yaw = yaw + math.pi/720
	end
	if a then
		mesh = not mesh
	end	
	if b then
		id = id%5 + 1
	end
end

--iterates tru all polygons and draws them
function render()
	screenPoints = {}
	for i, p in ipairs(models[id].points) do
		screenPoints[i] = toScreen(p)
	end
	screenPolys = {}
	for i, poly1 in ipairs(models[id].polygons) do
		poly2 = {} --poly on screen		
		for j, pi in ipairs(poly1) do
			poly2[j] = screenPoints[pi]
		end
		dx1 = poly2[2][1] - poly2[1][1]; dy1 = poly2[2][2] - poly2[1][2]
		dx2 = poly2[2][1] - poly2[3][1]; dy2 = poly2[2][2] - poly2[3][2]
		orientation = dx2*dy1 - dx1*dy2
		if mesh or orientation > 0 then
			n = #poly2
			for i = 1,n do
				gpu.drawLine(poly2[i][1], poly2[i][2], poly2[i%n+1][1], poly2[i%n+1][2], 0)
			end
		end
	end	
end

--Calculates a location on screen from a 3D point
function toScreen(point)
	x = point[1];	y = point[2];	z = point[3]
	--Rotations:
	cosB = math.cos(yaw); sinB = math.sin(yaw)
	xx = x
	x = cosB * x - sinB * z
	z = sinB * xx + cosB * z
	cosA = math.cos(pitch); sinA = math.sin(pitch)
	yy = y
	y = cosA * y - sinA * z
	z = sinA * yy + cosA * z
	
	--Translation + projection	
	z = z + 14
	x = x/z
	y = y/z
	x = 32 + 256*x
	y = 32 - 256*y
	return {x,y,z}
end

while true do
	processInput()
	gpu.clear(1)
	render()
	system.sleep(0)
end