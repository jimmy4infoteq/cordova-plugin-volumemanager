package org.igs.cordova.volumemanager;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.media.*;

public class volumemanager extends CordovaPlugin {
    /**
     * 
     * Member Variables
     */

	private static final String PKGTAG = "volumemanager";

	private Context context;
	private AudioManager manager;

    /**
     * Entry Point from the javascript calls
     * @param action
     * @param args
     * @param callbackContext
     * @return
     * @throws JSONException
     */
	@Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        boolean fnStatus = true;
		context = cordova.getActivity().getApplicationContext();
        manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
        
        if (action.equals("getMusicVolume")) {
            try {
				int _currVol = getCurrentVolume();
				float currVol = _currVol / 100.0f;
				String strVol= String.valueOf(currVol);
				callbackContext.success(strVol);
			} catch (Exception e) {
				LOG.d(PKGTAG, "Error :- " + e);
				fnStatus = false;
			}
        } else if (action.equals("setMusicVolume")) {
            try {
				int volumeToSet = (int) Math.round(args.getDouble(0) * 100.0f);
				int volume = getVolumeToSet(volumeToSet);
				manager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, 0);
				callbackContext.success();
			} catch (Exception e) {
				LOG.d(PKGTAG, "Error :- " + e);
				fnStatus = false;
			}
        }
		return fnStatus;
    }

    private int getVolumeToSet(int percent) {
		try {
			int volLevel;
			int maxVolume = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
			volLevel = Math.round((percent * maxVolume) / 100);

			return volLevel;
		} catch (Exception e){
			LOG.d(PKGTAG, "Error :- " + e);
			return 1;
		}
	}

	private int getCurrentVolume() {
		try {
			int volLevel;
			int maxVolume = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
			int currSystemVol = manager.getStreamVolume(AudioManager.STREAM_MUSIC);
			volLevel = Math.round((currSystemVol * 100) / maxVolume);

			return volLevel;
		} catch (Exception e) {
			LOG.d(PKGTAG, "Error :- " + e);
			return 1;
		}
	}
}