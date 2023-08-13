package states;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import away3d.controllers.ControllerBase;
import away3d.primitives.TorusGeometry;
import away3d.core.base.Geometry;
import away3d.primitives.CubeGeometry;
import away3d.materials.MaterialBase;
import game.Character;
import away3d.textures.BitmapTexture;
import flixel.FlxSprite;
import flixel.FlxBasic;
import away3d.textures.BitmapCubeTexture;
import away3d.primitives.SkyBox;
import away3d.lights.shadowmaps.DirectionalShadowMapper;
import lime.app.Application;
import lime.ui.Window;
import flixel.math.FlxAngle;
import flixel.FlxG;
import states.PlayState;
//import lime.utils.Assets;
import away3d.entities.Sprite3D;

import away3d.entities.Mesh;
import away3d.events.Asset3DEvent;
import away3d.library.assets.Asset3DType;
import away3d.lights.DirectionalLight;
import away3d.loaders.Loader3D;
import away3d.loaders.misc.AssetLoaderContext;
import away3d.loaders.parsers.OBJParser;
import away3d.loaders.parsers.DAEParser;
import away3d.materials.TextureMaterial;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.controllers.FirstPersonController;
import away3d.controllers.HoverController;
import away3d.filters.BloomFilter3D;
import away3d.filters.DepthOfFieldFilter3D;
import away3d.filters.MotionBlurFilter3D;
import away3d.utils.Cast;
import flx3D.FlxView3D;
import openfl.utils.Assets;
using StringTools;


class TestState extends MusicBeatState
{
    override public function create()
    {
        super.create();

        //var objFolderPath = "assets/models/wuhu island/";
        //var objFilePath = objFolderPath+"wuhu island.obj";
        //var objFileText = Assets.getText(objFilePath);
        var scene = new Scene3D();
        scene.loadModel("assets/models/matt/", "matt", "obj");
        
        scene.loadModel("assets/models/wuhu island/", "wuhuIsland", "obj");
        //var matt = new FlxSprite(0, 0).loadGraphic(Paths.image("matt taking a shit"));
        //var mattCube = scene.makeSpriteObject(matt, new TorusGeometry());

        //var bf = new FlxSprite(0, 0).loadGraphic(Paths.image("bf"));
        //var bfCube = scene.makeSpriteObject(bf, new CubeGeometry(5, 5, 5, 1, 1, 1, false));
        //bfCube.x += 5;

        scene.loadSkybox("assets/models/skybox/");
        //scene.loadModel("assets/models/wuhu island skybox/", "WS2_common_vr_E", "obj");
        add(scene);
    }

}



class Scene3D extends FlxView3D
{
	// Mesh
	public var meshs:Map<String, Array<Mesh>> = new Map<String, Array<Mesh>>();

	// Lighting
	public var light:DirectionalLight;
	var lightPicker:StaticLightPicker;

	// Loading
	private var _loader:Loader3D;
	private var assetLoaderContext:AssetLoaderContext = new AssetLoaderContext();
    private var texMap:Map<String, TextureMaterial>;

    public var enableDebugCam:Bool = true;
    public var controller:FirstPersonController;
	public function new(x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1)
	{
		super(x, y, width, height);

		antialiasing = true;

        #if (haxe >= "4.0.0")
        texMap = new Map();
        #else
        texMap = new Map<String, TextureMaterial>();
        #end
        

		light = new DirectionalLight();
		light.ambient = 0.1;
        light.diffuse = 0.5;
        light.ambientColor = toColor("0.31", "0.07", "0.51");
		light.z -= 10;
        

		view.scene.addChild(light);

        view.camera.lens.near = 0.1;
        view.antiAlias = 1;
		lightPicker = new StaticLightPicker([light]);
        light.shadowMapper = new DirectionalShadowMapper();
        light._castsShadows = true;
        
        controller = new FirstPersonController(view.camera, 0, 0);
        controller.fly = true;
        //view.filters3d = [new BloomFilter3D(1, 1, .75, 0.1, 3)];
        //view.filters3d = [new DepthOfFieldFilter3D(), new MotionBlurFilter3D(), new BloomFilter3D(1, 1, .75, 0.05, 4)];
	}

    public function loadModel(folder:String, name:String, fileFormat:String)
    {
        _loader = new Loader3D();
		var modelBytes = Assets.getBytes(folder+name+'.'+fileFormat);
        if (fileFormat == 'obj')
        {
            assetLoaderContext.mapUrlToData(name+".mtl", Assets.getBytes(folder+name+".mtl"));
            var mtl = Assets.getText(folder+name+".mtl"); //could just get it from bytes but who cares lol
            var mtlLines = mtl.split("\n");

            //need to redo mtl parsing separate from the obj parser because of the workaround for multi tex support

            //store current string data for when it creates the tex, map_kd is normally the last line in a material (which is when it gets made)
            var curMat = "";
            var curSpec = "";
            var curSpecCol = "";
            var curAmbCol = "";
            var curDifCol = "";
            var curAlpha = "";
            
            for (l in mtlLines)
            {
                if (l.startsWith("newmtl "))
                {
                    curMat = l.replace('newmtl ', '');
                }
                else if (l.startsWith("Ns "))
                {
                    curSpec = l.replace('Ns ', '');
                }
                else if (l.startsWith("Ks "))
                {
                    curSpecCol = l.replace('Ks ', '');
                }
                else if (l.startsWith("Ka "))
                {
                    curAmbCol = l.replace('Ka ', '');
                }
                else if (l.startsWith("Kd "))
                {
                    curDifCol = l.replace('Kd ', '');
                }
                else if (l.startsWith("d "))
                {
                    curAlpha = l.replace('d ', '');
                }
                else if (l.startsWith("map_Kd "))
                {
                    var texToLoad = l.replace('map_Kd ', '').rtrim(); //remove map_Kd from the line
                    //var texSprite = new FlxSprite().loadGraphic(folder+texToLoad);
                    //var bitData = BitmapData.fromFile(folder+texToLoad);
                    //FlxG.state.add(texSprite);
                    //trace(folder+texToLoad);
                    var bitmapTex = Cast.bitmapTexture(folder+texToLoad);
                    var tex = new TextureMaterial(bitmapTex, true, true);
                    tex.texture = bitmapTex;
                    //set values
                    tex.specular = Std.parseFloat(curSpec) * 0.001;
                    var specCol = curSpecCol.split(" "); tex.specularColor = toColor(specCol[0], specCol[1], specCol[2]);
                    var ambCol = curAmbCol.split(" "); tex.ambientColor = toColor(ambCol[0], ambCol[1], ambCol[2]);
                    var difCol = curDifCol.split(" "); tex.diffuseMethod.diffuseColor = toColor(difCol[0], difCol[1], difCol[2]); 
                    tex.alpha = Std.parseFloat(curAlpha);
                    tex.alphaThreshold = 0.5; // so transparent textures work properly
                    

                    texMap.set(curMat, tex);

                    //trace(texMap.get(curMat));
                    //texMap[curMat] = tex;

                    //trace("loading tex " + texToLoad);
                }
            }
            _loader.loadData(modelBytes, assetLoaderContext, name, new OBJParser());
        }
        else if (fileFormat == 'dae')
        {
            _loader.loadData(modelBytes, assetLoaderContext, name, new DAEParser());
        }
		
	    
		
        _loader.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetDone);
		view.scene.addChild(_loader); 
    }
    //taken from the obj parser
    public function toColor(r:String, g:String, b:String):UInt
    {
        return Std.int(Std.parseFloat(r) * 255) << 16 | Std.int(Std.parseFloat(g) * 255) << 8 | Std.int(Std.parseFloat(b) * 255);
    }

	public function onAssetDone(event:Asset3DEvent)
	{
		if (event.asset.assetType == Asset3DType.MESH)
		{
			var mesh:Mesh = cast(event.asset, Mesh);
            var matName = mesh.material.name.split('~')[0].rtrim();
            //trace(mesh.material.name);
            
            for (texName => tex in texMap)
            {
                if (texName.contains(matName) || matName.contains(texName)) //it was acting weird and it fixed it???
                {
                    mesh.material = tex; //set the tex
                    mesh.material.lightPicker = lightPicker;
                }
            }
                //trace(texName);
           
            if (texMap.exists(matName)) //randomly stopped working
            {
                
            }        

            

            //trace(event.asset.assetNamespace);
            switch(event.asset.assetNamespace)
            {
                case "matt": 
                    mesh.scale(20);
                    mesh.rotationY = -90;
                    mesh.rotationX = 90;

            }

            if (!meshs.exists(event.asset.assetNamespace))
                meshs.set(event.asset.assetNamespace, []); //make sure its empty
			meshs.get(event.asset.assetNamespace).push(mesh);
		}
	}

    public function loadSkybox(folder:String)
    {
        var cubeMap:BitmapCubeTexture = new BitmapCubeTexture
        (
            Cast.bitmapData(folder+"right.png"),
            Cast.bitmapData(folder+"left.png"),
            Cast.bitmapData(folder+"top.png"),
            Cast.bitmapData(folder+"bottom.png"),
            Cast.bitmapData(folder+"front.png"),
            Cast.bitmapData(folder+"back.png")
        );
        var skybox:SkyBox = new SkyBox(cubeMap);
        view.scene.addChild(skybox); 
    }

	override function update(elapsed:Float)
	{
        if (enableDebugCam)
            debugCamControls(elapsed);
		super.update(elapsed);
	}

	override function destroy()
	{
		super.destroy();
	}

    function debugCamControls(elapsed:Float)
    {
        /*if (FlxG.keys.pressed.LEFT)
        {
            controller.panAngle -= 30*elapsed;
        }
        if (FlxG.keys.pressed.RIGHT)
        {
            controller.panAngle += 30*elapsed;
        }
        if (FlxG.keys.pressed.UP)
        {
            controller.tiltAngle -= 30*elapsed;
        }
        if (FlxG.keys.pressed.DOWN)
        {
            controller.tiltAngle += 30*elapsed;
        }*/

        if (FlxG.mouse.deltaScreenX != 0)
            controller.panAngle += FlxG.mouse.deltaScreenX;
        if (FlxG.mouse.deltaScreenY != 0)
            controller.tiltAngle += FlxG.mouse.deltaScreenY;

        if (FlxG.keys.pressed.W)
        {
            controller.incrementWalk(100*elapsed);
        }
        if (FlxG.keys.pressed.S)
        {
            controller.incrementWalk(-100*elapsed);
        }
        if (FlxG.keys.pressed.A)
        {
            controller.incrementStrafe(-100*elapsed);
        }
        if (FlxG.keys.pressed.D)
        {
            controller.incrementStrafe(100*elapsed);
        }
        if (FlxG.keys.pressed.SPACE)
        {
            view.camera.y += elapsed*100;
        }
        if (FlxG.keys.pressed.SHIFT)
        {
            view.camera.y -= elapsed*100;
        }

        controller.update(true);

        Application.current.window.mouseLock = true;
    }

    public function makeSpriteObject(sprite:FlxSprite, geo:Geometry)
    {
        var mat = new TextureMaterial(Cast.bitmapTexture(sprite.updateFramePixels()));
        //var spr3D:Sprite3D = new Sprite3D(new TextureMaterial(Cast.bitmapTexture("assets/images/icons/bf-icons.png")), 128, 128);
        var mesh:Mesh = new Mesh(geo, mat);
        view.scene.addChild(mesh);
        return mesh;
    }
    public function makeSpriteBillboard(sprite:FlxSprite)
    {
        var mat = new TextureMaterial(Cast.bitmapTexture(sprite.updateFramePixels()));
        var spr3D:Sprite3D = new Sprite3D(mat, 128, 128);
        view.scene.addChild(spr3D);
        return spr3D;
    }
}