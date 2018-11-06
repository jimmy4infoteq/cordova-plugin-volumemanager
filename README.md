# cordova-plugin-volume-manager

* This plugin is to manage volume on Cordova Apps on both Android and iOS
* Volume is treated as a value between 0.0 to 1.0

## How to add it to the Cordova project

  
    cordova plugin add https://github.com/jimmy4infoteq/cordova-plugin-volumemanager.git
    

## How to Remove it from Cordova project

    
    cordova plugin remove cordova-plugin-volumemanager
    

## How this can be used in Javascript

1. To get the current Music Volume
    ```
    cordova.plugins.volumemanager.getMusicVolume(null, function(volume){
        console.log(volume);
    },function(err){
        console.log(err);
    });
    ```
2. To set the Music Volume
    ```
    cordova.plugins.volumemanager.setMusicVolume(0.5,function(volume){
        console.log(volume);
    },function(err){
        console.log(err);
    });
    ```
3. To register a volume watch
    
    We have to do it only once in the `deviceready` so that to get the callback fired with every volume change.
    
    ```
    cordova.plugins.volumemanager.bindVolumeChangeCallback(null,function(volume){
        console.log(volume);
    },function(err){
        console.log(err);
    });
    ```

