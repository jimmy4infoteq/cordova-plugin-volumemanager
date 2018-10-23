
	var exec = require('cordova/exec');
	
	function createGetterFunction(functionName) {
		return function(dataArray, success, error) {
			dataArray = dataArray || [];
			success = success || function(){};
			error = error || function(){};
			exec(success, error, 'volumemanager', functionName, [dataArray]);
		}
	}
	
	module.exports.getMusicVolume        	= createGetterFunction('getMusicVolume');
	module.exports.isMuted        			= createGetterFunction('isMuted');
	module.exports.toggleMuted        		= createGetterFunction('toggleMuted');

	