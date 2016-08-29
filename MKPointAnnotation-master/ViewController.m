//
//  ViewController.m
//  MKPointAnnotation-master
//
//  Created by 黄海燕 on 16/8/26.
//  Copyright © 2016年 huanghy. All rights reserved.
//

#import "ViewController.h"
#import "JZLocationConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
/**
 *  定位管理器
 */
@property (nonatomic,strong) CLLocationManager *locationManager;
/**
 *  地理位置解码编码器
 */
@property (nonatomic,strong) CLGeocoder *geocoder;
/**
 *  地图控件
 */
@property (nonatomic,strong) MKMapView *mapView;

@property (nonatomic,strong)  MKPointAnnotation *pointAnnotation;

@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@end

@implementation ViewController

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        //创建定位管理器对象，作用是定位当前用户的经度和纬度
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [_locationManager requestAlwaysAuthorization];
        _locationManager.distanceFilter = 10.f;
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //设置地图的类型
        _mapView.maskView = MKMapTypeStandard;
        //显示当前用户的位置
        _mapView.showsUserLocation = YES;
    }
    return _mapView;
}

- (MKPointAnnotation *)pointAnnotation
{
    if (!_pointAnnotation) {
        _pointAnnotation = [[MKPointAnnotation alloc]init];
    }
    return _pointAnnotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //info.plist文件添加以下两条(或者其中一条):
    //NSLocationWhenInUseUsageDescription 在使用应用期间
    //NSLocationAlwaysUsageDescription 始终
    [self.view addSubview:self.mapView];
    [self.locationManager startUpdatingLocation];

    [self.view bringSubviewToFront:self.btnLocation];
}
#pragma mark -定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = locations[0];
    CLLocationCoordinate2D oCoordinate = newLocation.coordinate;
    CLLocationCoordinate2D gcjPt = [JZLocationConverter wgs84ToGcj02:oCoordinate];
    //定义地图的缩放比例
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.longitudeDelta = 0.1;
    coordinateSpan.latitudeDelta = 0.1;
    //为地图添加定义的内容
    MKCoordinateRegion coordinateRegion;
    coordinateRegion.center = gcjPt;
    coordinateRegion.span = coordinateSpan;
    
    //添加到地图上
    [self.mapView setRegion:coordinateRegion animated:YES];
    
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *place in placemarks) {
            NSDictionary *location = [place addressDictionary];
            
            //设置大头针坐标
            self.pointAnnotation.coordinate = gcjPt;
            self.pointAnnotation.title = [location objectForKey:@"State"];
            self.pointAnnotation.subtitle = [location objectForKey:@"SubLocality"];
            
            //添加大头针对象
            [self.mapView addAnnotation:self.pointAnnotation];
            
            NSLog(@"国家：%@",[location objectForKey:@"Country"]);
            NSLog(@"城市：%@",[location objectForKey:@"State"]);
            NSLog(@"区：%@",[location objectForKey:@"SubLocality"]);
        }
    }];
}
- (IBAction)locationAction:(id)sender {
    //开始定位
    [self.locationManager startUpdatingLocation];

}
@end
