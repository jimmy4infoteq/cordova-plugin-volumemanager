/**
 * volumemanager.m
 */

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define DLog(...)
#endif

@interface volumemanager : CDVPlugin {
  
}
/**
* Member Functions
*/
- (void)setMusicVolume:(CDVInvokedUrlCommand*)command;
- (void)getMusicVolume:(CDVInvokedUrlCommand*)command;
@end


@implementation volumemanager

- (void)setMusicVolume:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    float volume = [[command argumentAtIndex:0] floatValue];

    DLog(@"setMusicVolume: [%f]", volume);

    Class avSystemControllerClass = NSClassFromString(@"AVSystemController");
    id avSystemControllerInstance = [avSystemControllerClass performSelector:@selector(sharedAVSystemController)];

    NSInvocation *privateInvocation = [NSInvocation invocationWithMethodSignature:
                                     [avSystemControllerClass instanceMethodSignatureForSelector:
                                      @selector(setActiveCategoryVolumeTo:)]];
    [privateInvocation setTarget:avSystemControllerInstance];
    [privateInvocation setSelector:@selector(setActiveCategoryVolumeTo:)];
    [privateInvocation setArgument:&volume atIndex:2];
    [privateInvocation invoke];
    BOOL result;
    [privateInvocation getReturnValue:&result];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getMusicVolume:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    DLog(@"getMusicVolume");

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:audioSession.outputVolume];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end