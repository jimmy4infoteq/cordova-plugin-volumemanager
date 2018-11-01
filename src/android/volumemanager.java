/**
 * @author jmj for igs
 */
package org.igs.cordova.volumemanager;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;

import android.os.Handler;
import android.content.Context;
import android.database.ContentObserver;
import android.media.*;
import android.provider.Settings.System;

public class volumemanager extends CordovaPlugin {
	/**
	 *
	 * Member Variables
	 */

	private static final String PKGTAG = "volumemanager";
	private Context context;
	private AudioManager manager;
	private static final int STREAM = AudioManager.STREAM_MUSIC;
	private CallbackContext changedEventCallback = null;

	/**
	 * Plugin Initializer reloaded
	 * @param cordova
	 * @param webView
	 */
	@Override
	public void initialize (CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
		context = super.cordova.getActivity().getApplicationContext();
	}

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
		/**
		 * getMusicVolume
		 */
		if (action.equals("getMusicVolume")) {
			try {
				double currVol = getCurrentVolume();
				String strVol= String.valueOf(currVol);
				callbackContext.success(strVol);
			} catch (Exception e) {
				LOG.d(PKGTAG, "Error :- " + e);
				fnStatus = false;
			}
		}
		/**
		 * setMusicVolume
		 */
		else if (action.equals("setMusicVolume")) {
			try {
				int volumeToSet = (int) Math.round(args.getDouble(0) * 100.0f);
				int maxVolume = manager.getStreamMaxVolume(STREAM);
				int volume = Math.round((volumeToSet * maxVolume) / 100);
				manager.setStreamVolume(STREAM, volume, 0);
				callbackContext.success();
			} catch (Exception e) {
				LOG.d(PKGTAG, "Error :- " + e);
				fnStatus = false;
			}
		}
		/**
		 * bindVolumeChangeCallback
		 */
		else if (action.equals("bindVolumeChangeCallback")) {
			try {
				changedEventCallback = callbackContext;
				SettingsContentObserver observer = new SettingsContentObserver(new Handler());
				context.getContentResolver().registerContentObserver(System.CONTENT_URI, true, observer);
				return true;
			} catch (Exception e) {
				LOG.d(PKGTAG, "ErrorBINDVol :- " + e);
				fnStatus = false;
			}
		}
		return fnStatus;
	}

	/**
	 * Content Observer to watch volume change
	 */
	public class SettingsContentObserver extends ContentObserver {
		private double previousVolume;

		public SettingsContentObserver(Handler handler) {
			super(handler);
			previousVolume = getCurrentVolume();
		}

		@Override
		public boolean deliverSelfNotifications() {
			return super.deliverSelfNotifications();
		}

		@Override
		public void onChange(boolean selfChange) {
			super.onChange(selfChange);

			double currentVolume = getCurrentVolume();

			double delta= previousVolume - currentVolume;

			if(delta != 0) {
				invokeVolChangeForCDV(currentVolume);
			}

			previousVolume=currentVolume;
		}
	}

	/**
	 * Get current music volume of the device
	 * @return
	 */
	private double getCurrentVolume() {
		try {
			int volLevel;
			int maxVolume = manager.getStreamMaxVolume(STREAM);
			int currSystemVol = manager.getStreamVolume(STREAM);
			if (currSystemVol == 0) {
				return 0.0;
			}
			return 1.0 * currSystemVol / maxVolume;
		} catch (Exception e) {
			LOG.d(PKGTAG, "Error :- " + e);
			return 1.0;
		}
	}

	/**
	 * Give the JS callback a report on volumechange
	 * @param volume
	 */
	private void invokeVolChangeForCDV(double volume) {
		if(changedEventCallback != null) {
			PluginResult result = new PluginResult(PluginResult.Status.OK, (float) getCurrentVolume());
			result.setKeepCallback(true);
			changedEventCallback.sendPluginResult(result);
		}
	}

}