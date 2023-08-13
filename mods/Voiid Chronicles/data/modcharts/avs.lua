--this is probably the most stupid thing ive done for a joke song
function createPost()

    setActorVisible(false, 'boyfriend')
    setActorVisible(false, 'dad')
    setActorVisible(false, 'girlfriend')

    addHaxeLibrary('ObjectContainer3D', 'away3d.containers')
    addHaxeLibrary('Math')
    addHaxeLibrary('CubeGeometry', 'away3d.primitives')
    addHaxeLibrary('TorusGeometry', 'away3d.primitives')
    addHaxeLibrary('DepthOfFieldFilter3D', 'away3d.filters')
    addHaxeLibrary('MotionBlurFilter3D', 'away3d.filters')
    addHaxeLibrary('BloomFilter3D', 'away3d.filters')
    runHaxeCode([[
        var scene = new Scene3D();
        game.variables["scene"] = scene;
        scene.loadModel("assets/models/matt/", "matt", "obj");
        scene.loadModel("assets/models/wuhu island/", "wuhuIsland", "obj");
        scene.loadSkybox("assets/models/skybox/");

        scene.light.x -= 10;
        scene.light.z = 0;

        var bf = new FlxSprite(0, 0).loadGraphic(Paths.image("bf"));
        var bfCube = scene.makeSpriteObject(bf, new CubeGeometry(3, 3, 3, 1, 1, 1, false));
        bfCube.x -= 430;
        bfCube.z -= 216;
        bfCube.y += 20;
        bfCube.y += 1.5;
        game.variables["bfCube"] = bfCube;

        game.add(scene);
        scene.enableDebugCam = false;
        scene.scrollFactor.set(0, 0);
        var camPos = new ObjectContainer3D();
        game.variables["camPos"] = camPos;
        camPos.x -= 430;
        camPos.z -= 220;
        camPos.y += 20;

        var controller = new HoverController(scene.view.camera, camPos, 90, 10, 15);
        game.variables["controller"] = controller;

        scene.view.filters3d = [new MotionBlurFilter3D(), new BloomFilter3D(3, 3, .75, 1, 4)];
        
    ]])
end
local mattRotX = 90
local mattRotY = -45
local mattRotZ = 0
local bfRotX = 0
local bfRotY = 0
local bfRotZ = 0
local camPosZ = -220
local targetCamPosZ = -220 
function update(elapsed)
    mattRotX = lerp(mattRotX, 90, elapsed*10)
    mattRotY = lerp(mattRotY, -90, elapsed*10)
    mattRotZ = lerp(mattRotZ, 0, elapsed*10)
    bfRotX = lerp(bfRotX, 0, elapsed*10)
    bfRotY = lerp(bfRotY, 0, elapsed*10)
    bfRotZ = lerp(bfRotZ, 0, elapsed*10)

    camPosZ = lerp(camPosZ, targetCamPosZ, elapsed*4)
    runHaxeCode([[
        var elapsed = ]]..elapsed..[[;
        game.variables["controller"].update();
        game.variables["controller"].panAngle += 20*elapsed;
        if (game.curStep > 64) 
        {
            game.variables["controller"].panAngle += 20*elapsed;
            game.variables["controller"].tiltAngle = 15 + 8*Math.sin(Conductor.songPosition*0.002);
            game.variables["controller"].distance = 12 + 8*Math.sin(Conductor.songPosition*0.0015);
        }
        game.variables["camPos"].z = ]]..camPosZ..[[;
        var scene = game.variables["scene"];

        if (scene.meshs.exists("matt"))
        {
            var meshs = scene.meshs.get("matt");
            for (m in meshs)
            {
                m.x = -430;
                m.z = -224;
                m.y = 20;
                m.scaleX = 6;
                m.scaleY = 6;
                m.scaleZ = 6;
                m.rotationX = ]]..mattRotX..[[;
                m.rotationY = ]]..mattRotY..[[;
                m.rotationZ = ]]..mattRotZ..[[;
            }
        }
        var bfCube = game.variables["bfCube"];
        bfCube.rotationX = ]]..bfRotX..[[;
        bfCube.rotationY = ]]..bfRotY..[[;
        bfCube.rotationZ = ]]..bfRotZ..[[;
    ]])
end
local rotDataStuffX = {45, 0, 0, 45}
local rotDataStuffY = {180, 0, 0, 180}
local rotDataStuffZ = {0, 45, -45, 0}
function playerTwoSing(data, time, t)
    data = getSingDirectionID(data)
    mattRotX = mattRotX + rotDataStuffX[data+1]
    mattRotY = mattRotY + rotDataStuffY[data+1]
    mattRotZ = mattRotZ + rotDataStuffZ[data+1]
end
function playerTwoSingHeld(data, time, t)
    playerTwoSing(data, time, t)
end
function playerOneSing(data, time, t)
    data = getSingDirectionID(data)
    bfRotX = bfRotX + rotDataStuffX[data+1]
    bfRotY = bfRotY + rotDataStuffY[data+1]
    bfRotZ = bfRotZ + rotDataStuffZ[data+1]
end
function playerOneSingHeld(data, time, t)
    playerOneSing(data, time, t)
end

function lerp(a, b, ratio)
	return a + ratio * (b - a);
end

function playerOneTurn()
    targetCamPosZ = -216
end
function playerTwoTurn()
    targetCamPosZ = -224
end