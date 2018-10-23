/**
 * volumemanager.m
 */

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface volumemanager : CDVPlugin {
  
}
/**
* Member Functions
*/
- (void)getMusicVolume:(CDVInvokedUrlCommand*)command;
- (void)isMuted:(CDVInvokedUrlCommand*)command;
- (void)toggleMuted:(CDVInvokedUrlCommand*)command;
@end

@implementation volumemanager

- (void)toggleMuted:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    Class avSystemControllerClass = NSClassFromString(@"AVSystemController");
    id avSystemControllerInstance = [avSystemControllerClass performSelector:@selector(sharedAVSystemController)];

    NSInvocation *privateInvocation = [NSInvocation invocationWithMethodSignature:
                                      [avSystemControllerClass instanceMethodSignatureForSelector:
                                       @selector(toggleActiveCategoryMuted)]];
    [privateInvocation setTarget:avSystemControllerInstance];
    [privateInvocation setSelector:@selector(toggleActiveCategoryMuted)];
    [privateInvocation invoke];
    BOOL result;
    [privateInvocation getReturnValue:&result];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isMuted:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    Class avSystemControllerClass = NSClassFromString(@"AVSystemController");
    id avSystemControllerInstance = [avSystemControllerClass performSelector:@selector(sharedAVSystemController)];

    BOOL result;
    NSInvocation *privateInvocation = [NSInvocation invocationWithMethodSignature:
                                      [avSystemControllerClass instanceMethodSignatureForSelector:
                                       @selector(getActiveCategoryMuted:)]];
    [privateInvocation setTarget:avSystemControllerInstance];
    [privateInvocation setSelector:@selector(getActiveCategoryMuted:)];
    [privateInvocation setArgument:&result atIndex:2];
    [privateInvocation invoke];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getMusicVolume:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:audioSession.outputVolume];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
