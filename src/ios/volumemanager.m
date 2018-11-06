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
    NSString *changeCallbackId;
    UIView *mpVolumeViewParentView;
    MPVolumeView *sopVolumeView;
    UISlider *systemVolumeSlider;
    float originalSystemVolume;
    float currentSystemVolume;
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
    [self doBindVolumeChange];
    DLog(@"End- plugin Init");
}

- (void) bindVolumeChangeCallback:(CDVInvokedUrlCommand*) command {
    DLog(@"Bind outputVolume");
    [self addAnMPVolViewToApp];
    DLog(@"MPViewAdded");
    if (command.callbackId) {
        DLog(@"Overriding volChangeCBack: %@!", command.callbackId);
    }
    
    changeCallbackId = command.callbackId;
    
    originalSystemVolume = [self bareCurrentDeviceVolume];
    currentSystemVolume = originalSystemVolume;
    
    [self setSystemVolume:currentSystemVolume];
}

- (void)setSystemVolume:(float)volume
{
    UISlider *slide = [self currentDeviceMPVolume];
    if(slide != nil){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
                slide.value = volume;
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    DLog(@"withChange");
    [self removeBindVolumeChange];
    if (changeCallbackId && [keyPath isEqual:@"outputVolume"]) {
         DLog(@"javascript contacted_from watch");
        [self getCurrentVolumeForCDV:changeCallbackId];
    }

    [self doBindVolumeChange];
}
- (void) doBindVolumeChange
{
    [self removeBindVolumeChange];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:0 context:nil];
}
- (void)removeBindVolumeChange
{
    @try
    {
        [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    }
    @catch(id anException)
    {
        DLog(@"RemoveWatcher - error");
    }
}

- (void) getCurrentVolumeForCDV:(NSString*) callbackId {
    DLog(@"getCurrentVolumeForCDV");
    CDVPluginResult* result = [self currentDeviceVolume];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult: result callbackId:callbackId];
}

- (CDVPluginResult*) currentDeviceVolume {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    float volume = audioSession.outputVolume;
    DLog(@"currentDeviceVolumeREAD: %.2f", volume);
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:volume];
}

- (float) bareCurrentDeviceVolume {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    float volume = audioSession.outputVolume;
    return volume;
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
    
    [self setSystemVolume:volume];
    
    CDVPluginResult* pluginResult = [self currentDeviceVolume];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addAnMPVolViewToApp
{
    if (mpVolumeViewParentView != NULL) {  return; }
    
    CGRect viewRect = CGRectMake( 0.0, -100.0, 10.0, 0.0 );
    
    sopVolumeView = [[MPVolumeView alloc] initWithFrame: viewRect];
    [self.webView.superview addSubview:sopVolumeView];
    [sopVolumeView setHidden:YES];
}

- (UISlider *)currentDeviceMPVolume {
    static UISlider *volumeViewSlider = nil;
    if(volumeViewSlider == nil) {
        for(UIView *sbview in sopVolumeView.subviews) {
            DLog(@"for loop: %@!", sbview);
            DLog(@"TestLoop - %@", sbview.class.description);
            if([sbview isKindOfClass:[UISlider class]])
            {
                volumeViewSlider = (UISlider *)sbview;
                volumeViewSlider.continuous = true;
                systemVolumeSlider = volumeViewSlider;
                DLog(@"for loop - IF: %@!", volumeViewSlider);
                return volumeViewSlider;
            }
        }
    }
    DLog(@"currentDeviceMPVolumeViewSlider: %@!", volumeViewSlider);
    return volumeViewSlider;
}
@end