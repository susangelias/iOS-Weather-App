//
//  WxClient.m
//  KVCO - client
//
//  Ryan Nystrom - Tutorial: iOS 7 Best Practises; A Weather App Case Study
//

#import "WxClient.h"
#import "WxCondition.h"
#import "WXDailyForecast.h"

@interface WxClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WxClient

- (id)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching: %@", url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:kNilOptions
                                                            error:&jsonError];
                if (! jsonError) {
                    [subscriber sendNext:json];
                }
                else {
                    [subscriber sendError:jsonError];
                }
            }
            else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (RACSignal *) fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
     NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        return [MTLJSONAdapter modelOfClass:[WxCondition class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use -fetchJSONFromURL again and map the JSON as appropriate. Note how much code you’re saving by reusing this call!
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build an RACSequence from the “list” key of the JSON. RACSequences let you perform ReactiveCocoa operations on lists.
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Map the new list of objects. This calls -map: on each object in the list, returning a list of new objects.
        return [[list map:^(NSDictionary *item) {
            // Use MTLJSONAdapter again to convert the JSON into a WXCondition object.
            return [MTLJSONAdapter modelOfClass:[WxCondition class] fromJSONDictionary:item error:nil];
            // Using -map on RACSequence returns another RACSequence, so use this convenience method to get the data as an NSArray
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
