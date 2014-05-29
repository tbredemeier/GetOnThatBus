//
//  ViewController.m
//  GetOnThatBus
//
//  Created by tbredemeier on 5/28/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *busStops;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpMap];
    [self loadData];
}

- (void)loadData
{
    NSURL *url = [NSURL URLWithString: @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
         if(data)
         {
             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&connectionError];
             self.busStops = [dictionary objectForKey:@"row"];
             for(NSDictionary *busStop in self.busStops)
             {
                 MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                 CLLocationDegrees latitude = [[busStop objectForKey:@"latitude"] doubleValue];
                 CLLocationDegrees longitude = [[busStop objectForKey:@"longitude"] doubleValue];
                 annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                 annotation.title = [busStop objectForKey:@"cta_stop_name"];
                 annotation.subtitle = [NSString stringWithFormat:@"Routes: %@",
                                        [busStop objectForKey:@"routes"]];
                 [self.mapView addAnnotation:annotation];
             }
         }
     }];
}

- (void)setUpMap
{
    NSString *address = @"Chicago";
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray *placemarks,
                                     NSError *error)
     {
         for (CLPlacemark *placemark in placemarks)
         {
             CLLocationCoordinate2D centerCoordinate = placemark.location.coordinate;
             MKCoordinateSpan span = MKCoordinateSpanMake(.4, .4);
             MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
             [self.mapView setRegion:region animated:YES];
         }
     }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
        pin.canShowCallout = YES;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    NSDictionary *selectedBusStop;
    NSString *location = view.annotation.title;
    for(NSDictionary *busStop in self.busStops)
    {
        if([[busStop objectForKey:@"cta_stop_name"] isEqualToString:location])
            selectedBusStop = busStop;
    }
    if(selectedBusStop)
    {
        DetailViewController *nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        nextViewController.name = [selectedBusStop objectForKey:@"cta_stop_name"];
        nextViewController.routes = [NSString stringWithFormat:@"Routes: %@",
                                     [selectedBusStop objectForKey:@"routes"]];
        if([selectedBusStop objectForKey:@"inter_modal"])
            nextViewController.transfers = [NSString stringWithFormat:@"Transfers: %@",
                                         [selectedBusStop objectForKey:@"inter_modal"]];
        else
            nextViewController.transfers = @"";

        CLLocationDegrees latitude = [[selectedBusStop objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[selectedBusStop objectForKey:@"longitude"] doubleValue];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray *placemarks,
                                           NSError *error)
        {
            for (CLPlacemark *placemark in placemarks)
            {
                NSString *address = [NSString stringWithFormat:@"Address:\n%@",
                ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
                NSLog(@"%@", address);
                nextViewController.address = address;
                [self.navigationController pushViewController:nextViewController animated:YES];
            }
        }];
    }
}



@end
