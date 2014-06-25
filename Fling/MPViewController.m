//
//  MPViewController.m
//  Fling
//
//  Created by Ritchie Iu on 6/23/14.
//  Copyright (c) 2014 CCIFT. All rights reserved.
//

#import "MPViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MPViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
- (IBAction)jsonButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *address;
- (IBAction)buttonPressed:(id)sender;
@end

@implementation MPViewController
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    manager.delegate =  self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [manager startUpdatingLocation];
    
}

#pragma mark CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location!");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            self.address.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                 placemark.subThoroughfare,
                                 placemark.thoroughfare,
                                 placemark.postalCode,
                                 placemark.locality,
                                 placemark.administrativeArea,
                                  placemark.country];
                                 
        }
        else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
    [manager stopUpdatingLocation];

}
- (IBAction)jsonButtonPressed:(id)sender {
    NSLog(@"HI You pressed the button!");
    NSDictionary *inner = @{
      @"name": @"riu",
      @"email": @"myEmail",
      @"longitude":@"6",
      @"latitude":@"7"};
    
    NSDictionary *dictionary = @{@"user": inner};
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0 error:nil];
    //NSString *someString = [NSString stringWithFormat:@"%@", JSONData];
    
    //NSString *JSONString = @"{'user': {'name': 'test2', 'email':'email2','longitude':'5','latitude':'21'}}";
    //NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Content-Type"  : @"application/json"
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];

    NSURL *url = [NSURL URLWithString:@"http://arcane-dawn-1935.herokuapp.com/users"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = JSONData;
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error) {
            NSLog(@"Status code: %i", ((NSHTTPURLResponse *)response).statusCode);
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
    }];
    [task resume];
    //NSLog(someString);
}
@end