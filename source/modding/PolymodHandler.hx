package modding;

#if polymod
import polymod.Polymod;

class PolymodHandler
{
    public static var metadataArrays:Array<String> = [];

    public static function loadMods()
    {
        loadModMetadata();

		Polymod.init({
			modRoot:"mods/",
			dirs: ModList.getActiveMods(metadataArrays),
            framework: OPENFL,
			errorCallback: function(error:PolymodError)
			{
				#if debug
                trace(error.message);
                #end
			},
            frameworkParams: {
                assetLibraryPaths: [
                    "songs" => "songs",
                    "stages" => "stages",
                    "shared" => "shared",
                    "replays" => "replays",
                    "fonts" => "fonts"
                ]
            }
		});
    }

    public static function loadModMetadata()
    {
        metadataArrays = [];

        #if (polymod <= "1.5.2")
        var tempArray = Polymod.scan("mods/","*.*.*",function(error:PolymodError) {
            #if debug
			trace(error.message);
            #end
		});
        #else //1.7.0+
        var tempArray:Array<ModMetadata> = Polymod.scan({
            modRoot: "mods/",
            apiVersionRule: "*.*.*",
            errorCallback: function(error:PolymodError) {
                #if debug
                trace(error.message);
                #end
            },
        });
        #end



        for(metadata in tempArray)
        {
            metadataArrays.push(metadata.id);
            ModList.modMetadatas.set(metadata.id, metadata);
        }
    }
}
#end