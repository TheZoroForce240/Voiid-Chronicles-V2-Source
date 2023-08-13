package shaders;

import flixel.math.FlxAngle;
import flixel.FlxG;
import flixel.system.FlxAssets;

using StringTools;

class Shaders
{
    public static function newEffect(?name:String = "3d"):Dynamic
    {
        switch(name.toLowerCase())
        {
            case "3d":
                return new ThreeDEffect();
        }

        return new ThreeDEffect();
    }
}

class ShaderEffect
{
    public function update(elapsed:Float)
    {
        // nothing yet
    }
}

class ThreeDEffect extends ShaderEffect
{
    public var shader(default,null):ThreeDShader = new ThreeDShader();

    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.uTime.value[0] += elapsed;
    }

    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }
    
    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }
    
    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
}

class ThreeDShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;
        
        float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = texture2D(bitmap, uv);
    }')

    public function new()
    {
       super();
    }
}


class ColorFillEffect extends ShaderEffect
{
    public var shader(default,null):ColorFillShader = new ColorFillShader();
    public var red:Float = 0.0;
    public var green:Float = 0.0;
    public var blue:Float = 0.0;
    public var fade:Float = 1.0;
	public function new():Void
    {
        shader.red.value = [red];
        shader.green.value = [green];
        shader.blue.value = [blue];
        shader.fade.value = [fade];
    }
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.red.value = [red];
        shader.green.value = [green];
        shader.blue.value = [blue];
        shader.fade.value = [fade];
    }
}

class ColorFillShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float red;
        uniform float green;
        uniform float blue;
        uniform float fade;
        
        void main()
        {
            vec4 spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            vec4 col = vec4(red/255,green/255,blue/255, spritecolor.a);
            vec3 finalCol = mix(col.rgb*spritecolor.a, spritecolor.rgb, fade);
        
            gl_FragColor = vec4( finalCol.r, finalCol.g, finalCol.b, spritecolor.a );
        }
    ')

    public function new()
    {
       super();
    }
}

class ColorOverrideEffect extends ShaderEffect
{
    public var shader(default,null):ColorOverrideShader = new ColorOverrideShader();
    public var red:Float = 0.0;
    public var green:Float = 0.0;
    public var blue:Float = 0.0;
	public function new():Void
    {
        shader.red.value = [red];
        shader.green.value = [green];
        shader.blue.value = [blue];
    }
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.red.value = [red];
        shader.green.value = [green];
        shader.blue.value = [blue];
    }
}

class ColorOverrideShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float red;
        uniform float green;
        uniform float blue;
        
        void main()
        {
            vec4 spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);

            spritecolor.r *= red;
            spritecolor.g *= green;
            spritecolor.b *= blue;
        
            gl_FragColor = spritecolor;
        }
    ')

    public function new()
    {
       super();
    }
}

class ChromAbEffect extends ShaderEffect
{
	public var shader(default,null):ChromAbShader = new ChromAbShader();
	public var strength:Float = 0.0;

	public function new():Void
	{
		shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
	}
}

class ChromAbShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 col = flixel_texture2D(bitmap, uv);
			col.r = flixel_texture2D(bitmap, vec2(uv.x+strength, uv.y)).r;
			col.b = flixel_texture2D(bitmap, vec2(uv.x-strength, uv.y)).b;

			col = col * (1.0 - strength * 0.5);

			gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}

class ChromAbBlueSwapEffect extends ShaderEffect
{
	public var shader(default,null):ChromAbBlueSwapShader = new ChromAbBlueSwapShader();
	public var strength:Float = 0.0;

	public function new():Void
	{
		shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
	}
}

class ChromAbBlueSwapShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 col = flixel_texture2D(bitmap, uv);
			col.r = flixel_texture2D(bitmap, vec2(uv.x+strength, uv.y)).r;
			col.g = flixel_texture2D(bitmap, vec2(uv.x-strength, uv.y)).g;

			col = col * (1.0 - strength * 0.5);

			gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}

class GreyscaleEffect extends ShaderEffect
{
	public var shader(default,null):GreyscaleShader = new GreyscaleShader();
	public var strength:Float = 0.0;

	public function new():Void
	{
		shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
	}
}

class GreyscaleShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 col = flixel_texture2D(bitmap, uv);
			float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); //https://en.wikipedia.org/wiki/Grayscale
			gl_FragColor = mix(col, vec4(grey,grey,grey, col.a), strength);
		}')
	public function new()
	{
		super();
	}
}

class SobelEffect extends ShaderEffect
{
	public var shader(default,null):SobelShader = new SobelShader();
	public var strength:Float = 1.0;
    public var intensity:Float = 1.0;

	public function new():Void
	{
		shader.strength.value = [0];
        shader.intensity.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
        shader.intensity.value[0] = intensity;
	}
}

class SobelShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;
        uniform float intensity;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 col = flixel_texture2D(bitmap, uv);
            vec2 resFactor = (1/openfl_TextureSize.xy)*intensity;

            if (strength <= 0)
            {
                gl_FragColor = col;
                return;
            }

            //https://en.wikipedia.org/wiki/Sobel_operator
            //adsjklalskdfjhaslkdfhaslkdfhj

            vec4 topLeft = flixel_texture2D(bitmap, vec2(uv.x-resFactor.x, uv.y-resFactor.y));
            vec4 topMiddle = flixel_texture2D(bitmap, vec2(uv.x, uv.y-resFactor.y));
            vec4 topRight = flixel_texture2D(bitmap, vec2(uv.x+resFactor.x, uv.y-resFactor.y));

            vec4 midLeft = flixel_texture2D(bitmap, vec2(uv.x-resFactor.x, uv.y));
            vec4 midRight = flixel_texture2D(bitmap, vec2(uv.x+resFactor.x, uv.y));

            vec4 bottomLeft = flixel_texture2D(bitmap, vec2(uv.x-resFactor.x, uv.y+resFactor.y));
            vec4 bottomMiddle = flixel_texture2D(bitmap, vec2(uv.x, uv.y+resFactor.y));
            vec4 bottomRight = flixel_texture2D(bitmap, vec2(uv.x+resFactor.x, uv.y+resFactor.y));

            vec4 Gx = (topLeft) + (2*midLeft) + (bottomLeft) - (topRight) - (2*midRight) - (bottomRight);
            vec4 Gy = (topLeft) + (2*topMiddle) + (topRight) - (bottomLeft) - (2*bottomMiddle) - (bottomRight);
            vec4 G = sqrt((Gx*Gx) + (Gy*Gy));
			
			gl_FragColor = mix(col, G, strength);
		}')
	public function new()
	{
		super();
	}
}


class MosaicEffect extends ShaderEffect
{
	public var shader(default,null):MosaicShader = new MosaicShader();
	public var strength:Float = 0.0;

	public function new():Void
	{
		shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
	}
}

class MosaicShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;

		void main()
		{
            if (strength == 0.0)
            {
                gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
                return;
            }

			vec2 blocks = openfl_TextureSize / vec2(strength,strength);
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')
	public function new()
	{
		super();
	}
}

class BlurEffect extends ShaderEffect
{
	public var shader(default,null):BlurShader = new BlurShader();
	public var strength:Float = 0.0;
    public var strengthY:Float = 0.0;
    public var vertical:Bool = false;

	public function new():Void
	{
		shader.strength.value = [0];
        shader.strengthY.value = [0];
        //shader.vertical.value[0] = vertical;
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
        shader.strengthY.value[0] = strengthY;
        //shader.vertical.value = [vertical];
	}
}

class BlurShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;
        uniform float strengthY;
        //uniform bool vertical;

		void main()
		{
            //https://github.com/Jam3/glsl-fast-gaussian-blur/blob/master/5.glsl

            vec4 color = vec4(0.0,0.0,0.0,0.0);
            vec2 uv = openfl_TextureCoordv;
            vec2 resolution = vec2(1280.0,720.0);
            vec2 direction = vec2(strength, strengthY);
            //if (vertical)
            //{
            //    direction = vec2(0.0, 1.0);
            //}
            vec2 off1 = vec2(1.3333333333333333, 1.3333333333333333) * direction;
            color += flixel_texture2D(bitmap, uv) * 0.29411764705882354;
            color += flixel_texture2D(bitmap, uv + (off1 / resolution)) * 0.35294117647058826;
            color += flixel_texture2D(bitmap, uv - (off1 / resolution)) * 0.35294117647058826;
            
			gl_FragColor = color;
		}')
	public function new()
	{
		super();
	}
}

class BetterBlurEffect extends ShaderEffect
{
	public var shader(default,null):BetterBlurShader = new BetterBlurShader();
	public var loops:Float = 16.0;
    public var quality:Float = 5.0;
    public var strength:Float = 0.0;

	public function new():Void
	{
		shader.loops.value = [0];
        shader.quality.value = [0];
        shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.loops.value[0] = loops;
        shader.quality.value[0] = quality;
        shader.strength.value[0] = strength;
        //shader.vertical.value = [vertical];
	}
}

class BetterBlurShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		//https://www.shadertoy.com/view/Xltfzj
        //https://xorshaders.weebly.com/tutorials/blur-shaders-5-part-2

		uniform float strength;
        uniform float loops;
        uniform float quality;
        float Pi = 6.28318530718; // Pi*2

		void main()
		{
            vec2 uv = openfl_TextureCoordv;
            vec4 color = flixel_texture2D(bitmap, uv);
            vec2 resolution = vec2(1280.0,720.0);
            
            vec2 rad = strength/openfl_TextureSize;

            for( float d=0.0; d<Pi; d+=Pi/loops)
            {
                for(float i=1.0/quality; i<=1.0; i+=1.0/quality)
                {
                    color += flixel_texture2D( bitmap, uv+vec2(cos(d),sin(d))*rad*i);		
                }
            }
            
            color /= quality * loops - 15.0;
			gl_FragColor = color;
		}')
	public function new()
	{
		super();
	}
}




class BloomEffect extends ShaderEffect
{
    public var shader:BloomShader = new BloomShader();
    public var effect:Float = 5;
    public var strength:Float = 0.2;
    public var contrast:Float = 1.0;
    public var brightness:Float = 0.0;
    public function new(){
        shader.effect.value = [effect];
        shader.strength.value = [strength];
        shader.iResolution.value = [FlxG.width,FlxG.height];
        shader.contrast.value = [contrast];
        shader.brightness.value = [brightness];
    }

    override public function update(elapsed:Float){
        shader.effect.value = [effect];
        shader.strength.value = [strength];
        shader.iResolution.value = [FlxG.width,FlxG.height];
        shader.contrast.value = [contrast];
        shader.brightness.value = [brightness];
    }
}

class BloomShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform float effect;
    uniform float strength;


    uniform float contrast;
    uniform float brightness;

    uniform vec2 iResolution;

    void main()
    {
        vec2 uv = openfl_TextureCoordv;


		vec4 color = flixel_texture2D(bitmap,uv);
        //float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));

        //vec4 newColor = vec4(color.rgb * brightness * strength * color.a, color.a);

        //got some stuff from here: https://github.com/amilajack/gaussian-blur/blob/master/src/9.glsl
        //this also helped to understand: https://learnopengl.com/Advanced-Lighting/Bloom


        color.rgb *= contrast;
        color.rgb += vec3(brightness,brightness,brightness);

        if (effect <= 0)
        {
            gl_FragColor = color;
            return;
        }


        vec2 off1 = vec2(1.3846153846) * effect;
        vec2 off2 = vec2(3.2307692308) * effect;

        color += flixel_texture2D(bitmap, uv) * 0.2270270270 * strength;
        color += flixel_texture2D(bitmap, uv + (off1 / iResolution)) * 0.3162162162 * strength;
        color += flixel_texture2D(bitmap, uv - (off1 / iResolution)) * 0.3162162162 * strength;
        color += flixel_texture2D(bitmap, uv + (off2 / iResolution)) * 0.0702702703 * strength;
        color += flixel_texture2D(bitmap, uv - (off2 / iResolution)) * 0.0702702703 * strength;

		gl_FragColor = color;
    }')
    public function new()
        {
          super();
        } 
}



class VignetteEffect extends ShaderEffect
{
	public var shader(default,null):VignetteShader = new VignetteShader();
	public var strength:Float = 1.0;
    public var size:Float = 0.0;
    public var red:Float = 0.0;
    public var green:Float = 0.0;
    public var blue:Float = 0.0;

	public function new():Void
	{
		shader.strength.value = [0];
        shader.size.value = [0];
        shader.red.value = [red];
        shader.green.value = [green];
        shader.blue.value = [blue];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
        shader.size.value[0] = size;
        shader.red.value = [red];
        shader.green.value = [green];
        shader.blue.value = [blue];
	}
}

class VignetteShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;
        uniform float size;

        uniform float red;
        uniform float green;
        uniform float blue;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 col = flixel_texture2D(bitmap, uv);

            //modified from this
            //https://www.shadertoy.com/view/lsKSWR

            uv = uv * (1.0 - uv.yx);
            float vig = uv.x*uv.y * strength; 
            vig = pow(vig, size);

            vig = 0.0-vig+1.0;

            vec3 vigCol = vec3(vig,vig,vig);
            vigCol.r = vigCol.r * (red/255);
            vigCol.g = vigCol.g * (green/255);
            vigCol.b = vigCol.b * (blue/255);
            col.rgb += vigCol;
            col.a += vig;

			gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}

class BarrelBlurEffect extends ShaderEffect
{
	public var shader(default,null):BarrelBlurShader = new BarrelBlurShader();
    public var barrel:Float = 2.0;
	public var zoom:Float = 5.0;
    public var doChroma:Bool = false;
    var iTime:Float = 0.0;

    public var angle:Float = 0.0;

    public var x:Float = 0.0;
    public var y:Float = 0.0;

	public function new():Void
	{
		shader.barrel.value = [barrel];
        shader.zoom.value = [zoom];
        shader.doChroma.value = [doChroma];
        shader.angle.value = [angle];
        shader.iTime.value = [0.0];
        shader.x.value = [x];
        shader.y.value = [y];
	}

	override public function update(elapsed:Float):Void
	{
		shader.barrel.value = [barrel];
        shader.zoom.value = [zoom];
        shader.doChroma.value = [doChroma];
        shader.angle.value = [angle];
        iTime += elapsed;
        shader.iTime.value = [iTime];
        shader.x.value = [x];
        shader.y.value = [y];
	}
}

class BarrelBlurShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
        uniform float barrel;
        uniform float zoom;
        uniform bool doChroma;
        uniform float angle;
        uniform float iTime;

        uniform float x;
        uniform float y;

        //edited version of this
        //https://www.shadertoy.com/view/td2XDz

        vec2 remap( vec2 t, vec2 a, vec2 b ) {
            return clamp( (t - a) / (b - a), 0.0, 1.0 );
        }

        vec4 spectrum_offset_rgb( float t )
        {
            if (!doChroma)
                return vec4(1.0,1.0,1.0,1.0); //turn off chroma
            float t0 = 3.0 * t - 1.5;
            vec3 ret = clamp( vec3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
            return vec4(ret.r,ret.g,ret.b, 1.0);
        }

        vec2 brownConradyDistortion(vec2 uv, float dist)
        {
            uv = uv * 2.0 - 1.0;
            float barrelDistortion1 = 0.1 * dist; // K1 in text books
            float barrelDistortion2 = -0.025 * dist; // K2 in text books

            float r2 = dot(uv,uv);
            uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
            
            return uv * 0.5 + 0.5;
        }

        vec2 distort( vec2 uv, float t, vec2 min_distort, vec2 max_distort )
        {
            vec2 dist = mix( min_distort, max_distort, t );
            return brownConradyDistortion( uv, 75.0 * dist.x );
        }

        float nrand( vec2 n )
        {
            return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
        }

        vec4 render( vec2 uv )
        {
            uv.x += x;
            uv.y += y;
            
            //funny mirroring shit
            if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0)
                uv.x = (0.0-uv.x)+1.0;
            if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0)
                uv.y = (0.0-uv.y)+1.0;



            return flixel_texture2D( bitmap, vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0))) );
        }

        void main()
        {	
            vec2 iResolution = vec2(1280,720);
            //rotation bullshit
            vec2 center = vec2(0.5,0.5);
            vec2 uv = openfl_TextureCoordv.xy;
            


            //uv = uv.xy - center; //move uv center point from center to top left

            mat2 translation = mat2(
                0, 0,
                0, 0 );


            mat2 scaling = mat2(
                zoom, 0.0,
                0.0, zoom );

            //uv = uv * scaling;

            float angInRad = radians(angle);
            mat2 rotation = mat2(
                cos(angInRad), -sin(angInRad),
                sin(angInRad), cos(angInRad) );

            //used to stretch back into 16:9
            //0.5625 is from 9/16
            mat2 aspectRatioShit = mat2(
                0.5625, 0.0,
                0.0, 1.0 );

            vec2 fragCoordShit = iResolution*openfl_TextureCoordv.xy;
            uv = ( fragCoordShit - .5*iResolution.xy ) / iResolution.y;
            uv = uv * scaling;
            uv = (aspectRatioShit) * (rotation * uv);
            uv = uv.xy + center; //move back to center
            
            const float MAX_DIST_PX = 50.0;
            float max_distort_px = MAX_DIST_PX * barrel;
            vec2 max_distort = vec2(max_distort_px) / iResolution.xy;
            vec2 min_distort = 0.5 * max_distort;
            
            vec2 oversiz = distort( vec2(1.0), 1.0, min_distort, max_distort );
            uv = mix(uv,remap( uv, 1.0-oversiz, oversiz ),0.0);
            
            const int num_iter = 7;
            const float stepsiz = 1.0 / (float(num_iter)-1.0);
            float rnd = nrand( uv + fract(iTime) );
            float t = rnd*stepsiz;
            
            vec4 sumcol = vec4(0.0);
            vec3 sumw = vec3(0.0);
            for ( int i=0; i<num_iter; ++i )
            {
                vec4 w = spectrum_offset_rgb( t );
                sumw += w.rgb;
                vec2 uvd = distort(uv, t, min_distort, max_distort);
                sumcol += w * render( uvd );
                t += stepsiz;
            }
            sumcol.rgb /= sumw;
            
            vec3 outcol = sumcol.rgb;
            outcol =  outcol;
            outcol += rnd/255.0;
            
            gl_FragColor = vec4( outcol, sumcol.a / num_iter);
        }

        ')
	public function new()
	{
		super();
	}
}
//same thingy just copied so i can use it in scripts
/**
 * Cool Shader by ShadowMario that changes RGB based on HSV.
 */
 class ColorSwapEffect extends ShaderEffect 
 {
	public var shader(default, null):ColorSwap.ColorSwapShader = new ColorSwap.ColorSwapShader();
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;

	private function set_hue(value:Float) {
		hue = value;
		shader.uTime.value[0] = hue;
		return hue;
	}

	private function set_saturation(value:Float) {
		saturation = value;
		shader.uTime.value[1] = saturation;
		return saturation;
	}

	private function set_brightness(value:Float) {
		brightness = value;
		shader.uTime.value[2] = brightness;
		return brightness;
	}

	public function new()
	{
		shader.uTime.value = [0, 0, 0];
		shader.awesomeOutline.value = [false];
	}
}


class HeatEffect extends ShaderEffect
{
	public var shader(default,null):HeatShader = new HeatShader();
    public var strength:Float = 1.0;
    var iTime:Float = 0.0;


	public function new():Void
	{
        shader.strength.value = [strength];
        shader.iTime.value = [0.0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value = [strength];
        iTime += elapsed;
        shader.iTime.value = [iTime];
	}
}

class HeatShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
        uniform float strength;
        uniform float iTime;
        
        float rand(vec2 n) { return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);}
        float noise(vec2 n) 
        {
            const vec2 d = vec2(0.0, 1.0);
            vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
            return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
        }

        //https://www.shadertoy.com/view/XsVSRd 
        //edited version of this
        //partially using a version in the comments that doesnt use a texture and uses noise instead
            
        void main()
        {	
            
            vec2 uv = openfl_TextureCoordv.xy;
            vec2 offsetUV = vec4(noise(vec2(uv.x,uv.y+(iTime*0.1)) * vec2(50))).xy;
            offsetUV -= vec2(.5,.5);
            offsetUV *= 2.;
            offsetUV *= 0.01*0.1*strength;
            offsetUV *= (1. + uv.y);
            
            gl_FragColor = flixel_texture2D( bitmap, uv+offsetUV );
        }

        ')
	public function new()
	{
		super();
	}
}

class MirrorRepeatEffect extends ShaderEffect
{
	public var shader(default,null):MirrorRepeatShader = new MirrorRepeatShader();
	public var zoom:Float = 5.0;
    var iTime:Float = 0.0;

    public var angle:Float = 0.0;

    public var x:Float = 0.0;
    public var y:Float = 0.0;

	public function new():Void
	{
        shader.zoom.value = [zoom];
        shader.angle.value = [angle];
        shader.iTime.value = [0.0];
        shader.x.value = [x];
        shader.y.value = [y];
	}

	override public function update(elapsed:Float):Void
	{
        shader.zoom.value = [zoom];
        shader.angle.value = [angle];
        iTime += elapsed;
        shader.iTime.value = [iTime];
        shader.x.value = [x];
        shader.y.value = [y];
	}
}

//moved to a seperate shader because not all modcharts need the barrel shit and probably runs slightly better on weaker pcs
class MirrorRepeatShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

        //written by TheZoroForce240
		
        uniform float zoom;
        uniform float angle;
        uniform float iTime;

        uniform float x;
        uniform float y;

        vec4 render( vec2 uv )
        {
            uv.x += x;
            uv.y += y;
            
            //funny mirroring shit
            if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0)
                uv.x = (0.0-uv.x)+1.0;
            if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0)
                uv.y = (0.0-uv.y)+1.0;

            return flixel_texture2D( bitmap, vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0))) );
        }

        void main()
        {	
            vec2 iResolution = vec2(1280,720);
            //rotation bullshit
            vec2 center = vec2(0.5,0.5);
            vec2 uv = openfl_TextureCoordv.xy;

            mat2 scaling = mat2(
                zoom, 0.0,
                0.0, zoom );

            //uv = uv * scaling;

            float angInRad = radians(angle);
            mat2 rotation = mat2(
                cos(angInRad), -sin(angInRad),
                sin(angInRad), cos(angInRad) );

            //used to stretch back into 16:9
            //0.5625 is from 9/16
            mat2 aspectRatioShit = mat2(
                0.5625, 0.0,
                0.0, 1.0 );

            vec2 fragCoordShit = iResolution*openfl_TextureCoordv.xy;
            uv = ( fragCoordShit - .5*iResolution.xy ) / iResolution.y; //this helped a little, specifically the guy in the comments: https://www.shadertoy.com/view/tsSXzt
            uv = uv * scaling;
            uv = (aspectRatioShit) * (rotation * uv);
            uv = uv.xy + center; //move back to center
            
            gl_FragColor = render(uv);
        }

        ')
	public function new()
	{
		super();
	}
}

//https://www.shadertoy.com/view/MlfBWr
//le shader
class RainEffect extends ShaderEffect
{
	public var shader(default,null):RainShader = new RainShader();
    var iTime:Float = 0.0;


	public function new():Void
	{
        shader.iTime.value = [0.0];
	}

	override public function update(elapsed:Float):Void
	{
        iTime += elapsed;
        shader.iTime.value = [iTime];
	}
}

class RainShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
            
        uniform float iTime;

        vec2 rand(vec2 c){
            mat2 m = mat2(12.9898,.16180,78.233,.31415);
            return fract(sin(m * c) * vec2(43758.5453, 14142.1));
        }

        vec2 noise(vec2 p){
            vec2 co = floor(p);
            vec2 mu = fract(p);
            mu = 3.*mu*mu-2.*mu*mu*mu;
            vec2 a = rand((co+vec2(0.,0.)));
            vec2 b = rand((co+vec2(1.,0.)));
            vec2 c = rand((co+vec2(0.,1.)));
            vec2 d = rand((co+vec2(1.,1.)));
            return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
        }

        vec2 round(vec2 num)
        {
            num.x = floor(num.x + 0.5);
            num.y = floor(num.y + 0.5);
            return num;
        }




        void main()
        {	
            vec2 iResolution = vec2(1280,720);
            vec2 c = openfl_TextureCoordv.xy;

            vec2 u = c,
                    v = (c*.1),
                    n = noise(v*200.); // Displacement
            
            vec4 f = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
            
            // Loop through the different inverse sizes of drops
            for (float r = 4. ; r > 0. ; r--) {
                vec2 x = iResolution.xy * r * .015,  // Number of potential drops (in a grid)
                        p = 6.28 * u * x + (n - .5) * 2.,
                        s = sin(p);
                
                // Current drop properties. Coordinates are rounded to ensure a
                // consistent value among the fragment of a given drop.
                vec2 v = round(u * x - 0.25) / x;
                vec4 d = vec4(noise(v*200.), noise(v));
                
                // Drop shape and fading
                float t = (s.x+s.y) * max(0., 1. - fract(iTime * (d.b + .1) + d.g) * 2.);;
                
                // d.r -> only x% of drops are kept on, with x depending on the size of drops
                if (d.r < (5.-r)*.08 && t > .5) {
                    // Drop normal
                    vec3 v = normalize(-vec3(cos(p), mix(.2, 2., t-.5)));
                    // fragColor = vec4(v * 0.5 + 0.5, 1.0);  // show normals
                    
                    // Poor mans refraction (no visual need to do more)
                    f = flixel_texture2D(bitmap, u - v.xy * .3);
                }
            }
            gl_FragColor = f;
        }

        ')
	public function new()
	{
		super();
	}
}

class ScanlineEffect extends ShaderEffect
{
	public var shader(default,null):ScanlineShader = new ScanlineShader();
    public var strength:Float = 0.0;
    public var pixelsBetweenEachLine:Float = 15.0;
    public var smooth:Bool = false;

	public function new():Void
	{
        shader.strength.value = [strength];
        shader.pixelsBetweenEachLine.value = [pixelsBetweenEachLine];
        shader.smoothVar.value = [smooth];
	}

	override public function update(elapsed:Float):Void
	{
        shader.strength.value = [strength];
        shader.pixelsBetweenEachLine.value = [pixelsBetweenEachLine];
        shader.smoothVar.value = [smooth];
	}
}

class ScanlineShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
            
        uniform float strength;
        uniform float pixelsBetweenEachLine;
        uniform bool smoothVar;

        float m(float a, float b) //was having an issue with mod so i did this to try and fix it
        {
            return a - (b * floor(a/b));
        }

        void main()
        {	
            vec2 iResolution = vec2(1280.0,720.0);
            vec2 uv = openfl_TextureCoordv.xy;
            vec2 fragCoordShit = iResolution*uv;

            vec4 col = flixel_texture2D(bitmap, uv);

            if (smoothVar)
            {
                float apply = abs(sin(fragCoordShit.y)*0.5*pixelsBetweenEachLine);
                vec3 finalCol = mix(col.rgb, vec3(0.0, 0.0, 0.0), apply);
                vec4 scanline = vec4(finalCol.r, finalCol.g, finalCol.b, col.a);
    	        gl_FragColor = mix(col, scanline, strength);
                return;
            }

            vec4 scanline = flixel_texture2D(bitmap, uv);
            if (m(floor(fragCoordShit.y), pixelsBetweenEachLine) == 0.0)
            {
                scanline = vec4(0.0,0.0,0.0,1.0);
            }
            
            gl_FragColor = mix(col, scanline, strength);
        }

        ')
	public function new()
	{
		super();
	}
}

class PerlinSmokeEffect extends ShaderEffect
{
	public var shader(default,null):PerlinSmokeShader = new PerlinSmokeShader();
    public var waveStrength:Float = 0; //for screen wave (only for ruckus)
    public var smokeStrength:Float = 1;
    public var speed:Float = 1;
    var iTime:Float = 0.0;
	public function new():Void
	{
        shader.waveStrength.value = [waveStrength];
        shader.smokeStrength.value = [smokeStrength];
        shader.iTime.value = [0.0];
	}

	override public function update(elapsed:Float):Void
	{
        shader.waveStrength.value = [waveStrength];
        shader.smokeStrength.value = [smokeStrength];
        iTime += elapsed*speed;
        shader.iTime.value = [iTime];
	}
}

class PerlinSmokeShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
		
    uniform float iTime;
    uniform float waveStrength;
    uniform float smokeStrength;
    
    
    //https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
    //	Classic Perlin 3D Noise 
    //	by Stefan Gustavson
    //
    vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
    vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
    vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
    
    float cnoise(vec3 P){
      vec3 Pi0 = floor(P); // Integer part for indexing
      vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
      Pi0 = mod(Pi0, 289.0);
      Pi1 = mod(Pi1, 289.0);
      vec3 Pf0 = fract(P); // Fractional part for interpolation
      vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
      vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
      vec4 iy = vec4(Pi0.yy, Pi1.yy);
      vec4 iz0 = Pi0.zzzz;
      vec4 iz1 = Pi1.zzzz;
    
      vec4 ixy = permute(permute(ix) + iy);
      vec4 ixy0 = permute(ixy + iz0);
      vec4 ixy1 = permute(ixy + iz1);
    
      vec4 gx0 = ixy0 / 7.0;
      vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
      gx0 = fract(gx0);
      vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
      vec4 sz0 = step(gz0, vec4(0.0));
      gx0 -= sz0 * (step(0.0, gx0) - 0.5);
      gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    
      vec4 gx1 = ixy1 / 7.0;
      vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
      gx1 = fract(gx1);
      vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
      vec4 sz1 = step(gz1, vec4(0.0));
      gx1 -= sz1 * (step(0.0, gx1) - 0.5);
      gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    
      vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
      vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
      vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
      vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
      vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
      vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
      vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
      vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
    
      vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
      g000 *= norm0.x;
      g010 *= norm0.y;
      g100 *= norm0.z;
      g110 *= norm0.w;
      vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
      g001 *= norm1.x;
      g011 *= norm1.y;
      g101 *= norm1.z;
      g111 *= norm1.w;
    
      float n000 = dot(g000, Pf0);
      float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
      float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
      float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
      float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
      float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
      float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
      float n111 = dot(g111, Pf1);
    
      vec3 fade_xyz = fade(Pf0);
      vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
      vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
      float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
      return 2.2 * n_xyz;
    }
    
    float generateSmoke(vec2 uv, vec2 offset, float scale, float speed)
    {
        return cnoise(vec3((uv.x+offset.x)*scale, (uv.y+offset.y)*scale, iTime*speed));
    }
    
    float getSmoke(vec2 uv)
    {
      float smoke = 0.0;
      if (smokeStrength == 0.0)
        return smoke;
    
      float smoke1 = generateSmoke(uv, vec2(0.0-(iTime*0.5),0.0+sin(iTime*0.1)+(iTime*0.1)), 1.0, 0.5*0.1);
      float smoke2 = generateSmoke(uv, vec2(200.0-(iTime*0.2),200.0+sin(iTime*0.1)+(iTime*0.05)), 4.0, 0.3*0.1);
      float smoke3 = generateSmoke(uv, vec2(700.0-(iTime*0.1),700.0+sin(iTime*0.1)+(iTime*0.1)), 6.0, 0.7*0.1);
      smoke = smoke1*smoke2*smoke3*2.0;
    
      return smoke*smokeStrength;
    }
        
    void main()
    {	
        
        vec2 uv = openfl_TextureCoordv.xy + vec2(sin(cnoise(vec3(0.0,openfl_TextureCoordv.y*2.5,iTime))), 0.0)*waveStrength;
        vec2 smokeUV = uv;
        float smokeFactor = getSmoke(uv);
        if (smokeFactor < 0.0)
          smokeFactor = 0.0;
        
        vec3 finalCol = flixel_texture2D( bitmap, uv ).rgb + smokeFactor;
        
        gl_FragColor = vec4(finalCol.r, finalCol.g, finalCol.b, flixel_texture2D( bitmap, uv ).a);
    }

        ')
	public function new()
	{
		super();
	}
}


class WaveBurstEffect extends ShaderEffect
{
	public var shader(default,null):WaveBurstShader = new WaveBurstShader();
    public var strength:Float = 0.0;

	public function new():Void
	{
        shader.strength.value = [strength];
	}

	override public function update(elapsed:Float):Void
	{
        shader.strength.value = [strength];
	}
}

class WaveBurstShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
            
        uniform float strength;
        float nrand( vec2 n )
        {
            return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
        }
            
        void main()
        {	
            
            vec2 uv = openfl_TextureCoordv.xy;
            vec4 col = flixel_texture2D( bitmap, uv );
            float rnd = sin(uv.y*1000.0)*strength;
            rnd += nrand(uv)*strength;
    
            col = flixel_texture2D( bitmap, vec2(uv.x - rnd, uv.y) );
        
            gl_FragColor = col;
        }

        ')
	public function new()
	{
		super();
	}
}

class WaterEffect extends ShaderEffect
{
	public var shader(default,null):WaterShader = new WaterShader();
    public var strength:Float = 10.0;
    public var iTime:Float = 0.0;
    public var speed:Float = 1.0;

	public function new():Void
	{
        shader.strength.value = [strength];
        shader.iTime.value = [iTime];
	}

	override public function update(elapsed:Float):Void
	{
        shader.strength.value = [strength];
        iTime += elapsed*speed;
        shader.iTime.value = [iTime];
	}
}

class WaterShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
            
        uniform float iTime;
        uniform float strength;
        
        vec2 mirror(vec2 uv)
        {
            if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0)
                uv.x = (0.0-uv.x)+1.0;
            if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0)
                uv.y = (0.0-uv.y)+1.0;
            return vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0)));
        }
        vec2 warp(vec2 uv)
        {
            vec2 warp = strength*(uv+iTime);
            uv = vec2(cos(warp.x-warp.y)*cos(warp.y),
            sin(warp.x-warp.y)*sin(warp.y));
            return uv;
        }
        
        void main()
        {	
            
            vec2 uv = openfl_TextureCoordv.xy;
            vec4 col = flixel_texture2D( bitmap, mirror(uv + (warp(uv)-warp(uv+1.0))*(0.0035) ) );
        
            gl_FragColor = col;
        }

        ')
	public function new()
	{
		super();
	}
}

class RayMarchEffect extends ShaderEffect
{
    public var shader:RayMarchShader = new RayMarchShader();
	public var x:Float = 0;
	public var y:Float = 0;
    public var z:Float = 0;
    public var zoom:Float = -2;
    public function new(){
        shader.iResolution.value = [1280,720];
        shader.rotation.value = [0, 0, 0];
        shader.zoom.value = [zoom];
    }
  
    override public function update(elapsed:Float){
        shader.iResolution.value = [1280,720];
        
        shader.rotation.value = [x*FlxAngle.TO_RAD, y*FlxAngle.TO_RAD, z*FlxAngle.TO_RAD];
        shader.zoom.value = [zoom];
    }

    public function setPoint(){
        
    }
}

//shader from here: https://www.shadertoy.com/view/WtGXDD
class RayMarchShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    // "RayMarching starting point" 
    // by Martijn Steinrucken aka The Art of Code/BigWings - 2020
    // The MIT License
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    // Email: countfrolic@gmail.com
    // Twitter: @The_ArtOfCode
    // YouTube: youtube.com/TheArtOfCodeIsCool
    // Facebook: https://www.facebook.com/groups/theartofcode/
    //
    // You can use this shader as a template for ray marching shaders

    #define MAX_STEPS 100
    #define MAX_DIST 100.
    #define SURF_DIST .001

    #define S smoothstep
    #define T iTime

    uniform vec3 rotation;
    uniform vec3 iResolution;
    uniform float zoom;

    // Rotation matrix around the X axis.
    mat3 rotateX(float theta) {
        float c = cos(theta);
        float s = sin(theta);
        return mat3(
            vec3(1, 0, 0),
            vec3(0, c, -s),
            vec3(0, s, c)
        );
    }

    // Rotation matrix around the Y axis.
    mat3 rotateY(float theta) {
        float c = cos(theta);
        float s = sin(theta);
        return mat3(
            vec3(c, 0, s),
            vec3(0, 1, 0),
            vec3(-s, 0, c)
        );
    }

    // Rotation matrix around the Z axis.
    mat3 rotateZ(float theta) {
        float c = cos(theta);
        float s = sin(theta);
        return mat3(
            vec3(c, -s, 0),
            vec3(s, c, 0),
            vec3(0, 0, 1)
        );
    }

    mat2 Rot(float a) {
        float s=sin(a), c=cos(a);
        return mat2(c, -s, s, c);
    }

    float sdBox(vec3 p, vec3 s) {
        //p = p * rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);
        p = abs(p)-s;
        return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
    }
    float plane(vec3 p, vec3 offset) {
        float d = p.z;
        return d;
    }


    float GetDist(vec3 p) {
        float d = plane(p, vec3(0.0,0.0,0.0));
        
        return d;
    }

    float RayMarch(vec3 ro, vec3 rd) {
        float dO=0.;
        
        for(int i=0; i<MAX_STEPS; i++) {
            vec3 p = ro + rd*dO;
            float dS = GetDist(p);
            dO += dS;
            if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
        }
        
        return dO;
    }

    vec3 GetNormal(vec3 p) {
        float d = GetDist(p);
        vec2 e = vec2(.001, 0.0);
        
        vec3 n = d - vec3(
            GetDist(p-e.xyy),
            GetDist(p-e.yxy),
            GetDist(p-e.yyx));
        
        return normalize(n);
    }

    vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
        vec3 f = normalize(l-p),
            r = normalize(cross(vec3(0.0,1.0,0.0), f)),
            u = cross(f,r),
            c = f*z,
            i = c + uv.x*r + uv.y*u,
            d = normalize(i);
        return d;
    }

    vec2 repeat(vec2 uv)
    {
        return vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0)));
    }

    void main() //this shader is pain
    {
        vec2 center = vec2(0.5, 0.5);
        vec2 uv = openfl_TextureCoordv.xy - center;

        uv.x = 0-uv.x;

        vec3 ro = vec3(0.0, 0.0, zoom);

        ro = ro * rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);

        //ro.yz *= Rot(ShaderPointShit.y); //rotation shit
        //ro.xz *= Rot(ShaderPointShit.x);
        
        vec3 rd = GetRayDir(uv, ro, vec3(0.0,0.,0.0), 1.0);
        vec4 col = vec4(0.0);
    
        float d = RayMarch(ro, rd);

        if(d<MAX_DIST) {
            vec3 p = ro + rd * d;
            uv = vec2(p.x,p.y) * 0.5;
            uv += center; //move coords from top left to center
            col = flixel_texture2D(bitmap, repeat(uv)); //shadertoy to haxe bullshit i barely understand
        }        
        gl_FragColor = col;
    }')
    public function new()
        {
          super();
        } 
}


class PaletteEffect extends ShaderEffect
{
	public var shader(default,null):PaletteShader = new PaletteShader();
    public var strength:Float = 0.0;
    public var paletteSize:Float = 8.0;

	public function new():Void
	{
        shader.strength.value = [strength];
        shader.paletteSize.value = [paletteSize];
	}

	override public function update(elapsed:Float):Void
	{
        shader.strength.value = [strength];
        shader.paletteSize.value = [paletteSize];
	}
}

class PaletteShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform float strength;
    uniform float paletteSize;

    float palette(float val, float size)
    {
        float f = floor(val * (size-1.0) + 0.5);
        return f / (size-1.0);
    }
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        vec4 col = flixel_texture2D(bitmap, uv);
       
        vec4 reducedCol = vec4(col.r,col.g,col.b,col.a);
 
        reducedCol.r = palette(reducedCol.r, 8.0);
        reducedCol.g = palette(reducedCol.g, 8.0);
        reducedCol.b = palette(reducedCol.b, 8.0);
        gl_FragColor = mix(col, reducedCol, strength);
    }

        ')
	public function new()
	{
		super();
	}
}