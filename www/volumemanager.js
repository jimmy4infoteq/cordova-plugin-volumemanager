
var exec = require('cordova/exec');

function createGetterFunction(functionName) {
	return function(volume, success, error) {
		volume = volume || 0;
		success = success || function(){};
		error = error || function(){};
		if (volume > 1) { volume /= 100; }
		exec(success, error, 'volumemanager', functionName, [volume * 1]);
	}
}

module.exports.getMusicVolume        	= createGetterFunction('getMusicVolume');
module.exports.setMusicVolume  			= createGetterFunction('setMusicVolume');
module.exports.bindVolumeChangeCallback = createGetterFunction('bindVolumeChangeCallback');

