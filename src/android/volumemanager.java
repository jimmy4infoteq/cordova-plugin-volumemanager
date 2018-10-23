package org.igs.cordova.volumemanager;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.media.AudioManager;

public class volumemanager extends CordovaPlugin {

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
        if (action.equals("getMusicVolume")) {
            String dataArray = args.getString(0);
            getMusicVolume(dataArray,callbackContext);
            return true;
        } else if (action.equals("isMuted")) {
            String dataArray = args.getString(0);
            getIsMuted(dataArray,callbackContext);
            return true;
        } else if (action.equals("toggleMuted")) {
            String dataArray = args.getString(0);
            toggleMuted(dataArray,callbackContext);
            return true;
        }
		return false;
    }
    
    public void getMusicVolume(String dataArray, CallbackContext callbackContext) {
        getVolume(AudioManager.STREAM_MUSIC, callbackContext);
    }

    public void getIsMuted( 
        String dataArray, 
        CallbackContext callbackContext 
    ) {
        AudioManager manager = (AudioManager)this.cordova.getActivity().getSystemService(Context.AUDIO_SERVICE);
        int max = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        int volume = manager.getStreamVolume(AudioManager.STREAM_MUSIC);
        if (volume != 0) {
            callbackContext.success(0);
        } else {
            callbackContext.success(1);
        }
    }

    public void toggleMuted( 
        String dataArray, 
        CallbackContext callbackContext 
    ) {
        AudioManager manager = (AudioManager)this.cordova.getActivity().getSystemService(Context.AUDIO_SERVICE);
        int max = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        int volume = manager.getStreamVolume(AudioManager.STREAM_MUSIC);
        if (volume != 0) {
            setVolume(AudioManager.STREAM_MUSIC, "Music", 0, callbackContext);
        } else {
            setVolume(AudioManager.STREAM_MUSIC, "Music", 50, callbackContext);
        }
    }

    public void setMusicVolume(
            int dataArray, 
            CallbackContext callbackContext
    ) {
        setVolume(AudioManager.STREAM_MUSIC, "Music", dataArray, callbackContext);
    }

    public void setVolume(
            int streamType,
            String volumeType,
            int volume,
            CallbackContext callbackContext
    ) {
        AudioManager manager = (AudioManager)this.cordova.getActivity().getSystemService(Context.AUDIO_SERVICE);
        int max = manager.getStreamMaxVolume(streamType);
        int newVolume = volume;
        if (volume != 0) {
            double percent = (double)volume / 100;
            newVolume = (int)(max * percent);
        } else {
            newVolume = 0;
        }
        manager.setStreamVolume(streamType, newVolume, AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE);

        if (callbackContext != null) {
            callbackContext.success(volume);
        }
    }


    public void getVolume(int streamType, CallbackContext callbackContext) {
        AudioManager manager = (AudioManager)this.cordova.getActivity().getSystemService(Context.AUDIO_SERVICE);
        int max = manager.getStreamMaxVolume(streamType);
        int volume = manager.getStreamVolume(streamType);
        if (volume != 0) {
            double percent = (double)volume / (double)max;
            volume = (int)Math.round(percent * 100);
        }
        callbackContext.success(volume);
    }

}