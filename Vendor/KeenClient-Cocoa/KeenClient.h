//
//  KeenClient.h
//  KeenClient
//
//  Created by Daniel Kador on 2/8/12.
//  Copyright (c) 2012 Keen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "KIOEventStore.h"
#import "KeenProperties.h"

// defines a type for the block we'll use with our global properties
typedef NSDictionary* (^KeenGlobalPropertiesBlock)(NSString *eventCollection);

/**
 KeenClient has class methods to return managed instances of itself and instance methods
 to collect new events and upload them through the Keen IO API.
 
 Example usage:
 
    [KeenClient sharedClientWithProjectId:@"my_project_id" 
                              andWriteKey:@"my_write_key" 
                               andReadKey:@"my_read_key"];
    NSDictionary *myEvent = [NSDictionary dictionary];
    [[KeenClient sharedClient] addEvent:myEvent toEventCollection:@"purchases"];
    [[KeenClient sharedClient] uploadWithFinishedBlock:nil];
 */
@interface KeenClient : NSObject <CLLocationManagerDelegate>

/**
 This Objective-C property represents the Keen Global Properties dictionary for this instance of the
 KeenClient. The dictionary is used every time an event is added to an event collection.
 
 Keen Global Properties are properties which are sent with EVERY event. For example, you may wish to always
 capture static information like user ID, app version, etc.
 
 Every time an event is added to an event collection, the SDK will check to see if this property is defined.
 If it is, the SDK will copy all the properties from the global properties into the newly added event.
 
 Note that because this is just a dictionary, it's much more difficult to create DYNAMIC global properties.
 It also doesn't support per-collection properties. If either of these use cases are important to you, please use 
 the Objective-C property globalPropertiesBlock.
 
 Also note that the Keen properties defined in the globalPropertiesBlock take precendence over the properties
 defined in the globalPropertiesDictionary, and that the Keen Properties defined in each individual event take
 precedence over either of the Global Properties.
 
 Example usage:
 
    KeenClient *client = [KeenClient sharedClient];
    client.globalPropertiesDictionary = @{@"some_standard_key": @"some_standard_value"};
 
 */
@property (nonatomic, strong) NSDictionary *globalPropertiesDictionary;

/**
 This Objective-C property represents the Keen Global Properties block for this instance of the KeenClient. 
 The block is invoked every time an event is added to an event collection.
 
 Keen Global Properties are properties which are sent with EVERY event. For example, you may wish to always
 capture device information like OS version, handset type, orientation, etc.
 
 The block is invoked every time an event is added to an event collection. It takes as a parameter a single
 NSString, which is the name of the event collection the event's being added to. The user is responsible
 for returning an NSDictionary which represents the global properties for this particular event collection.
 
 Note that because we use a block, you can create DYNAMIC global properties. For example, if you want to
 capture device orientation, then your block can ask the device for its current orientation and then construct
 the NSDictionary. If your global properties aren't dynamic, then just return the same NSDictionary every time.
 
 Also note that the Keen properties defined in the globalPropertiesBlock take precendence over the properties
 defined in the globalPropertiesDictionary, and that the Keen Properties defined in each individual event take
 precedence over either of the Global Properties.
 
 Example usage:
 
    KeenClient *client = [KeenClient sharedClient];
    client.globalPropertiesBlock = ^NSDictionary *(NSString *eventCollection) {
        if ([eventCollection isEqualToString:@"apples"]) {
            return @{ @"color": @"red" };
        } else if ([eventCollection isEqualToString:@"pears"]) {
            return @{ @"color": @"green" };
        } else {
            return nil;
        }
    };
 
 */
@property (nonatomic, copy) KeenGlobalPropertiesBlock globalPropertiesBlock;

/**
 A property that holds the current location of the device. You can either call
 [KeenClient refreshCurrentLocation] to pull location from the device or you can set this property with
 your own value.
 */
@property (nonatomic, strong) CLLocation *currentLocation;

/**
 Call this to retrieve the managed instance of KeenClient and set its project ID and Write/Read Keys
 to the given parameters.
 
 You'll generally want to call this the first time you ask for the shared client.  Once you've called
 this, you can simply call [KeenClient sharedClient] afterwards.
 
 @param projectId Your Keen IO Project ID.
 @param writeKey Your Keen IO Write Key.
 @param readKey Your Keen IO Read Key.
 @return A managed instance of KeenClient, or nil if projectId is invalid.
 */
+ (KeenClient *)sharedClientWithProjectId:(NSString *)projectId andWriteKey:(NSString *)writeKey andReadKey:(NSString *)readKey;

/**
 Call this to retrieve the managed instance of KeenClient.
 
 If you only have to use a single Keen project, just use this.
 
 @return A managed instance of KeenClient, or nil if you haven't called [KeenClient sharedClientWithProjectId:andWriteKey:andReadKey:].
 */
+ (KeenClient *)sharedClient;

/**
 Call this to authorize geo location always (iOS 8 and above). You must also add NSLocationAlwaysUsageDescription string to Info.plist to
 authorize geo location always (foreground and background), call this BEFORE doing anything else with KeenClient.
 
 */
+ (void)authorizeGeoLocationAlways;

/**
 Call this to authorize geo location when in use (iOS 8 and above). You must also add NSLocationWhenInUsageDescription string to Info.plist to
 authorize geo location when in use (foreground), call this BEFORE doing anything else with KeenClient.
 
 When In Use is AUTHORIZED by default.
 */
+ (void)authorizeGeoLocationWhenInUse;

/**
 Call this to disable geo location. If you don't want to pop up a message to users asking them to approve geo location
 services, call this BEFORE doing anything else with KeenClient.
 
 Geo location is ENABLED by default.
 */
+ (void)disableGeoLocation;

/**
 Call this to enable geo location. You'll probably only have to call this if for some reason you've explicitly
 disabled geo location.
 
 Geo location is ENABLED by default.
 */
+ (void)enableGeoLocation;

/**
 Call this to disable debug logging. It's disabled by default.
 */
+ (void)disableLogging;

/**
 Call this to enable debug logging.
 */
+ (void)enableLogging;

/**
 Returns whether or not logging is currently enabled.
 
 @return true if logging is enabled, false if disabled.
 */
+ (Boolean)isLoggingEnabled;


/**
 Call this to indiscriminately delete all events queued for sending.
 */
+ (void)clearAllEvents;


/**
 Call this to retrieve an instance of KIOEventStore.
 
 @return An instance of KIOEventStore.
 */
+ (KIOEventStore *)getEventStore;

/**
 Call this if your code needs to use more than one Keen project.  By convention, if you
 call this, you're responsible for releasing the returned instance once you're finished with it.
 
 Otherwise, just use [KeenClient sharedClient].
 
 @param projectId Your Keen IO Project ID.
 @param writeKey Your Keen IO Write Key.
 @param readKey Your Keen IO Read Key.
 @return An initialized instance of KeenClient.
 */
- (id)initWithProjectId:(NSString *)projectId andWriteKey:(NSString *)writeKey andReadKey:(NSString *)readKey;

/**
 Call this to set the global properties block for this instance of the KeenClient. The block is invoked
 every time an event is added to an event collection.
 
 Global properties are properties which are sent with EVERY event. For example, you may wish to always
 capture device information like OS version, handset type, orientation, etc.
 
 The block is invoked every time an event is added to an event collection. It takes as a parameter a single
 NSString, which is the name of the event collection the event's being added to. The user is responsible
 for returning an NSDictionary which represents the global properties for this particular event collection.
 
 Note that because we use a block, you can create DYNAMIC global properties. For example, if you want to
 capture device orientation, then your block can ask the device for its current orientation and then construct
 the NSDictionary. If your global properties aren't dynamic, then just return the same NSDictionary every time.
 
 @param block The block which is invoked any time an event is added to an event collection.
 */
- (void)setGlobalPropertiesBlock:(NSDictionary * (^)(NSString *eventCollection))block;

/**
 Call this any time you want to add an event that will eventually be sent to the keen.io server.
 
 The event will be stored on the local file system until you decide to upload (usually this will happen
 in your application delegate right before your app goes into the background, but it could be any time).
 
 @param event An NSDictionary that consists of key/value pairs.  Keen naming conventions apply.  Nested NSDictionaries or NSArrays are acceptable.
 @param eventCollection The name of the collection you want to put this event into.
 @param anError If the event was added, anError will be nil, otherwise it will contain information about why it wasn't added.

 @return YES if the event was added, or NO in case some error happened.
 */
- (BOOL)addEvent:(NSDictionary *)event toEventCollection:(NSString *)eventCollection error:(NSError **)anError;

/**
 Call this any time you want to add an event that will eventually be sent to the keen.io server AND you
 want to override keen-default properties (like timestamp).
 
 The event will be stored on the local file system until you decide to upload (usually this will happen
 in your application delegate right before your app goes into the background, but it could be any time).
 
 @param event An NSDictionary that consists of key/value pairs.  Keen naming conventions apply.  Nested NSDictionaries or NSArrays are acceptable.
 @param keenProperties An instance of KeenProperties that consists of properties to override defaulted values.
 @param eventCollection The name of the event collection you want to put this event into.
 @param anError If the event was added, anError will be nil, otherwise it will contain information about why it wasn't added.

 @return YES if the event was added, or NO in case some error happened.
 */
- (BOOL)addEvent:(NSDictionary *)event withKeenProperties:(KeenProperties *)keenProperties toEventCollection:(NSString *)eventCollection error:(NSError **)anError;

/**
 Call this whenever you want to upload all the events captured so far.  This will spawn a low
 priority background thread and process all required HTTP requests.
 
 If an upload fails, the events will be saved for a later attempt.
 
 If a particular event is invalid, the event will be dropped from the queue and the failure message
 will be logged.
 
 @param block The block to be executed once uploading is finished, regardless of whether or not the upload succeeded.
 The block is also called when no upload was necessary because no events were captured.
 */
- (void)uploadWithFinishedBlock:(void (^)())block;

/**
 Refresh the current geo location. The Keen Client only gets geo at the beginning of each session (i.e. when the client is created).
 If you want to update geo to the current location, call this method.
 */
- (void)refreshCurrentLocation;

/**
 Returns the Keen SDK Version
 
 @return The current SDK version string.
 */
+ (NSString *)sdkVersion;

/**
 * Import fs-based data into the SQLite database.
 */
- (void)importFileData;

// defines the KCLog macro
#define KEEN_LOGGING_ENABLED [KeenClient loggingEnabled]
#define KCLog(message, ...)if([KeenClient isLoggingEnabled]) NSLog(message, ##__VA_ARGS__)

@end
