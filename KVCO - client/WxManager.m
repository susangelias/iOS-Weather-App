//
//  WxManager.m
//  KVCO - client
//
//  Ryan Nystrom - Tutorial: iOS 7 Best Practises; A Weather App Case Study
//

#import "WxManager.h"
#import "WxClient.h"
#import <TSMessage.h>

@interface WxManager()

@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) WxCondition *currentCondition;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WxClient *client;

@end


@implementation WxManager

+ (instancetype)sharedManager
{
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
         // Creates a location manager and sets it’s delegate to self.
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // Creates the WXClient object for the manager. This handles all networking and data parsing, following our separation of concerns best practice.
        _client = [[WxClient alloc] init];
        
        // The manager observes the currentLocation key on itself using a ReactiveCocoa macro which returns a signal. This is similar to Key-Value Observing but is far more powerful.
        [[[[RACObserve(self, currentLocation)
            // In order to continue down the method chain, currentLocation must not be nil.
            ignore:nil]
           // -flattenMap: is very similar to -map:, but instead of mapping each value, it flattens the values and returns one object containing all three signals. In this way, you can consider all three processes as a single unit of work.           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               // Deliver the signal to subscribers on the main thread.
           }] deliverOn:RACScheduler.mainThreadScheduler]
         // 7
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation
{
    // check authorization to use location
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ((status == kCLAuthorizationStatusDenied) || (status == kCLAuthorizationStatusRestricted)) {
        // not allowed to use location
        return;
    }

    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.isFirstUpdate = YES;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Always ignore the first location update because it is almost always cached.
    if (self.isFirstUpdate ) {
        self.isFirstUpdate = NO;
        return;
    }
    CLLocation *location = [locations lastObject];
    
    // Once you have a location with the proper accuracy, stop further updates.
    if (location.horizontalAccuracy > 0) {
        // Setting the currentLocation key triggers the RACObservable you set earlier in the init implementation.
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate]
            doNext:^(WxCondition *condition) {
                self.currentCondition = condition;
            }];
}

- (RACSignal *)updateHourlyForecast
{
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.hourlyForecast = conditions;
            }];
}

- (RACSignal *)updateDailyForecast
{
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.dailyForecast = conditions;
            }];
}

@end
