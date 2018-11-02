/**
 * volumemanager.m
 * @author jmj for igs
 */

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

@interface volumemanager : CDVPlugin {
    NSString* changeCallbackId;
}
/**
 * Member Functions
 */

- (void)bindVolumeChangeCallback:(CDVInvokedUrlCommand*)command;
- (void)getMusicVolume:(CDVInvokedUrlCommand*)command;
- (void)setMusicVolume:(CDVInvokedUrlCommand*)command;
- (UISlider *)currentDeviceMPVolume;
@end


@implementation volumemanager

- (void) pluginInitialize {
    DLog(@"plugin Initializer");
    [super pluginInitialize];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) bindVolumeChangeCallback:(CDVInvokedUrlCommand*) command {
    DLog(@"Bind outputVolume");
    if (command.callbackId) {
        DLog(@"Overriding volChangeCBack: %@!", command.callbackId);
    }
    changeCallbackId = command.callbackId;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (changeCallbackId && [keyPath isEqual:@"outputVolume"]) {
        [self getCurrentVolumeForCDV:changeCallbackId];
    }
}

- (void) getCurrentVolumeForCDV:(NSString*) callbackId {
    CDVPluginResult* result = [self currentDeviceVolume];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult: result callbackId:callbackId];
}

- (CDVPluginResult*) currentDeviceVolume {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    float volume = audioSession.outputVolume;
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:volume];
}

- (void)getMusicVolume:(CDVInvokedUrlCommand*)command
{
    DLog(@"getMusicVolume");
    CDVPluginResult* pluginResult = [self currentDeviceVolume];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMusicVolume:(CDVInvokedUrlCommand*)command
{
    DLog(@"setMusicVolume");
    float volume = [[command argumentAtIndex:0] floatValue];
    
    [self currentDeviceMPVolume].value = volume;
    
    CDVPluginResult* pluginResult = [self currentDeviceVolume];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (UISlider *)currentDeviceMPVolume {
    DLog(@"currentDeviceMPVolume");
    static UISlider * volumeViewSlider = nil;
    if(volumeViewSlider == nil) {
        MPVolumeView * volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 4)];
        [volumeView setHidden:YES];
        for(UIView *newView in volumeView.subviews) {
            if([newView.class.description isEqualToString:@"MPVolume"]) {
                volumeViewSlider = (UISlider *)newView;
                break;
            }
        }
    }
    return volumeViewSlider;
}

@end