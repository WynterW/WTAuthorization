//
//  WTAuthorization.m
//  WTAuthorization
//
//  Created by Wynter on 2018/12/7.
//  Copyright © 2018 Wynter. All rights reserved.
//

#import "WTAuthorization.h"
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <EventKit/EventKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Contacts/Contacts.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <HealthKit/HealthKit.h>
#import <HomeKit/HomeKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <StoreKit/StoreKit.h>
#import <CoreNFC/CoreNFC.h>
#import <Photos/Photos.h>
#import <Intents/Intents.h>
#import <Speech/Speech.h>

static WTAuthorization *sharedInstance = nil;

@interface WTAuthorization () <CBCentralManagerDelegate, HMHomeManagerDelegate, CLLocationManagerDelegate, NFCNDEFReaderSessionDelegate>

@property (nonatomic, copy) AuthorizationStateCompletionBlock bluetoothStateCompletionBlock;
@property (nonatomic, copy) AuthorizationStateCompletionBlock homeKitCompletionBlock;
@property (nonatomic, copy) AuthorizationStateCompletionBlock locationCompletionBlock;
@property (nonatomic, copy) AuthorizationStateCompletionBlock NFCCompletionBlock;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) HMHomeManager *homeManager;


@end

@implementation WTAuthorization

+ (WTAuthorization *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)requestAccessWithPrivacyType:(WTPrivacyType)type CompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    switch (type) {
        case WTPrivacyTypeBluetooth:
            [self requestAccessBluetoothWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeCalendars:
            [self requestAccessCalendarWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeCamera:
            [self requestAccessCameraWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeContacts:
            [self requestAccessContactsWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeFaceID:
            [self requestAccessFaceIDWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeHealth:
            [self requestAccessHealthWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeHomeKit:
            [self requestAccessHomeKitWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeLocationServices:
            [self requestAccessLocationWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeMicrophone:
            [self requestAccessMicrophoneWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeMotionAndFitness:
            [self requestAccessMotionWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeMediaAndAppleMusic:
            [self requestAccessMediaWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeNFC:
            [self requestAccessNFCWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypePhotos:
            [self requestAccessPhotosWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeReminders:
            [self requestAccessRemindersWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeSiri:
            [self requestAccessSiriWithCompletionBlock:completionBlock];
            break;
        case WTPrivacyTypeSpeechRecognition:
            [self requestAccessSpeechWithCompletionBlock:completionBlock];
            break;
    }
}

#pragma mark - 请求访问蓝牙权限
- (void)requestAccessBluetoothWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock  {
    self.bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.bluetoothStateCompletionBlock = completionBlock;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    CBManagerState state = central.state;
    
    WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if (state == CBManagerStateResetting) { // 重置或重新连接
        wtState = WTAuthorizationStateUnkonw;
    } else if (state == CBManagerStateUnsupported) {
        wtState = WTAuthorizationStateUnsupported;
    } else if (state == CBManagerStateUnauthorized) {
        wtState = WTAuthorizationStateUnauthorized;
    } else if (state == CBManagerStatePoweredOff) {
        wtState = WTAuthorizationStateDenied;
    } else if (state == CBManagerStatePoweredOn) {
        wtState = WTAuthorizationStateAuthorized;
    }
    
    [self respondWithState:wtState CompletionBlock:self.bluetoothStateCompletionBlock];
}

#pragma mark - 请求日历访问权限
- (void)requestAccessCalendarWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if (status == EKAuthorizationStatusNotDetermined) {
        EKEventStore *store = [[EKEventStore alloc] init];
        __weak __typeof(self)weakSelf = self;
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error) {} else {
                if (granted) {
                    wtState = WTAuthorizationStateAuthorized;
                } else {
                    wtState = WTAuthorizationStateDenied;
                }
            }
            
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == EKAuthorizationStatusRestricted) {
        wtState = WTAuthorizationStateUnkonw;
    } else if (status == EKAuthorizationStatusDenied) {
        wtState = WTAuthorizationStateDenied;
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

 #pragma mark - 请求相机访问权限
- (void)requestAccessCameraWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusNotDetermined) {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    wtState = WTAuthorizationStateAuthorized;
                }else{
                    wtState = WTAuthorizationStateDenied;
                }
                [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
            }];
            return;
        } else if (status == AVAuthorizationStatusRestricted) {
        } else if (status == AVAuthorizationStatusDenied) {
            wtState = WTAuthorizationStateDenied;
        } else {
            wtState = WTAuthorizationStateAuthorized;
        }
        
    } else {
        wtState = WTAuthorizationStateUnsupported;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 请求通讯录访问权限
- (void)requestAccessContactsWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
            if (error) {} else {
                if (granted) {
                    wtState = WTAuthorizationStateAuthorized;
                } else {
                    wtState = WTAuthorizationStateDenied;
                }
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == CNAuthorizationStatusRestricted) {
    } else if (status == CNAuthorizationStatusDenied) {
        wtState = WTAuthorizationStateDenied;
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - Face ID访问权限
- (void)requestAccessFaceIDWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0f) {
        [self respondWithState:WTAuthorizationStateUnsupported CompletionBlock:completionBlock];
    }
    LAContext *authenticationContext = [[LAContext alloc]init];
    NSError *error = nil;
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    BOOL canEvaluatePolicy = [authenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (canEvaluatePolicy) {
        if (authenticationContext.biometryType == LABiometryTypeFaceID) {
            [authenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"" reply:^(BOOL success, NSError * _Nullable error) {
                if (error) {} else {
                    if (success) {
                        wtState = WTAuthorizationStateAuthorized;
                    } else {
                        wtState = WTAuthorizationStateDenied;
                    }
                }
                [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
            }];
            return;
        } else {
            wtState = WTAuthorizationStateUnsupported;
        }
    }
    
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 获取健康集合
- (void)requestAccessAllHealthWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if ([HKHealthStore isHealthDataAvailable]) {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        __weak __typeof(self)weakSelf = self;

        NSSet *typeSet = [self dataTypesRead];
        [healthStore requestAuthorizationToShareTypes:typeSet readTypes:typeSet completion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                wtState = WTAuthorizationStateAuthorized;
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else {
        wtState = WTAuthorizationStateUnsupported;
    }

    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 获取健康心率 需要具体权限可以修改 HKQuantityTypeIdentifier
- (void)requestAccessHealthWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if ([HKHealthStore isHealthDataAvailable]) {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        __weak __typeof(self)weakSelf = self;
        HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        HKAuthorizationStatus status = [healthStore authorizationStatusForType:heartRateType];
        
        if (status == HKAuthorizationStatusNotDetermined) {
            NSSet *typeSet = [NSSet setWithObject:heartRateType];
            [healthStore requestAuthorizationToShareTypes:typeSet readTypes:typeSet completion:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    HKAuthorizationStatus status = [healthStore authorizationStatusForType:heartRateType];
                    if (status == HKAuthorizationStatusNotDetermined) {
                        wtState = WTAuthorizationStateUnauthorized;
                    } else if (status == HKAuthorizationStatusSharingAuthorized) {
                        wtState = WTAuthorizationStateAuthorized;
                    } else {
                        wtState = WTAuthorizationStateDenied;
                    }
                }
                [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
            }];
            return;
        } else if (status == HKAuthorizationStatusSharingAuthorized) {
            wtState = WTAuthorizationStateAuthorized;
        } else {
            wtState = WTAuthorizationStateDenied;
        }
    } else {
        wtState = WTAuthorizationStateUnsupported;
    }
    
    [self respondWithState:wtState CompletionBlock:completionBlock];
}


#pragma mark - HomeKit
- (void)requestAccessHomeKitWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
    self.homeKitCompletionBlock = completionBlock;
}

#pragma mark - HMHomeManagerDelegate
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager {
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    if (manager.homes.count > 0) {
        wtState = WTAuthorizationStateAuthorized;
       [self respondWithState:wtState CompletionBlock:self.homeKitCompletionBlock];
    } else {
        __weak __typeof(self)weakSelf = self;
        __weak HMHomeManager *weakHomeManager = manager;
        [manager addHomeWithName:@"Test Home" completionHandler:^(HMHome * _Nullable home, NSError * _Nullable error) {
            if (error) {
                wtState = WTAuthorizationStateAuthorized;
            } else {
                if (error.code == HMErrorCodeHomeAccessNotAuthorized) {
                    wtState = WTAuthorizationStateDenied;
                }
            }
            
            [weakSelf respondWithState:wtState CompletionBlock:self.homeKitCompletionBlock];
            
            if (home) {
                [weakHomeManager removeHome:home completionHandler:^(NSError * _Nullable error) {
                }];
            }
        }];
    }
}

#pragma mark - 位置访问权限
- (void)requestAccessLocationWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    self.locationCompletionBlock = completionBlock;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            wtState = WTAuthorizationStateUnauthorized;
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            break;
        }
        case kCLAuthorizationStatusDenied:{
            wtState = WTAuthorizationStateDenied;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            wtState = WTAuthorizationStateAuthorized;
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            wtState = WTAuthorizationStateAuthorized;
            break;
        }
        default:
            break;
    }
    [self respondWithState:wtState CompletionBlock:self.locationCompletionBlock];
}

#pragma mark - 麦克风
- (void)requestAccessMicrophoneWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __weak __typeof(self)weakSelf = self;
   __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                wtState = WTAuthorizationStateAuthorized;
            } else {
                wtState = WTAuthorizationStateDenied;
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == AVAuthorizationStatusRestricted) {
    } else if (status == AVAuthorizationStatusDenied) {
       wtState = WTAuthorizationStateDenied;
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 运动与健身 不需要回调
- (void)requestAccessMotionWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __weak __typeof(self)weakSelf = self;
    CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [manager startActivityUpdatesToQueue:queue withHandler:^(CMMotionActivity * _Nullable activity) {
        [manager stopActivityUpdates];
        [weakSelf respondWithState:WTAuthorizationStateAuthorized CompletionBlock:completionBlock];
    }];
}

#pragma mark - 媒体与Apple Music
- (void)requestAccessMediaWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.3f) {
        [self respondWithState:WTAuthorizationStateUnsupported CompletionBlock:completionBlock];
    }
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    
    SKCloudServiceAuthorizationStatus status = [SKCloudServiceController authorizationStatus];
    if (status == SKCloudServiceAuthorizationStatusNotDetermined) {
        
        [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
            switch (status) {
                case SKCloudServiceAuthorizationStatusNotDetermined: {
                    wtState = WTAuthorizationStateUnauthorized;
                }
                    break;
                case SKCloudServiceAuthorizationStatusRestricted: {
                }
                    break;
                case SKCloudServiceAuthorizationStatusDenied: {
                    wtState = WTAuthorizationStateDenied;
                }
                    break;
                case SKCloudServiceAuthorizationStatusAuthorized: {
                    wtState = WTAuthorizationStateAuthorized;
                }
                    break;
                default:
                    break;
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == SKCloudServiceAuthorizationStatusRestricted) {
    } else if (status == SKCloudServiceAuthorizationStatusDenied) {
        wtState = WTAuthorizationStateDenied;
    } else{
        wtState = WTAuthorizationStateAuthorized;
    }

    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - NFC
- (void)requestAccessNFCWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0f) {
        [self respondWithState:WTAuthorizationStateUnsupported CompletionBlock:completionBlock];
    }
    NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc]initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
    [session beginSession];
    self.NFCCompletionBlock = completionBlock;
}

#pragma mark - NFCNDEFReaderSessionDelegate
- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error {
    [self respondWithState:WTAuthorizationStateUnsupported CompletionBlock:self.NFCCompletionBlock];
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages {
        [self respondWithState:WTAuthorizationStateAuthorized CompletionBlock:self.NFCCompletionBlock];
}

#pragma mark - 相册权限
- (void)requestAccessPhotosWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusNotDetermined) {
                wtState = WTAuthorizationStateUnauthorized;
            } else if (status == PHAuthorizationStatusRestricted) {
                
            } else if (status == PHAuthorizationStatusDenied) {
                wtState = WTAuthorizationStateDenied;
            } else {
                wtState = WTAuthorizationStateAuthorized;
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == PHAuthorizationStatusRestricted) {
    } else if (status == PHAuthorizationStatusDenied) {
        wtState = WTAuthorizationStateDenied;
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 提醒事项
- (void)requestAccessRemindersWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (status == EKAuthorizationStatusNotDetermined) {
        EKEventStore *store = [[EKEventStore alloc] init];

        [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            if (error) {} else {
                if (granted) {
                    wtState = WTAuthorizationStateAuthorized;
                } else {
                    wtState = WTAuthorizationStateDenied;
                }
            }
            
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == EKAuthorizationStatusRestricted) {
        
    } else if (status == EKAuthorizationStatusDenied) {
       wtState = WTAuthorizationStateDenied;
        
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - Siri
- (void)requestAccessSiriWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0f) {
        [self respondWithState:WTAuthorizationStateUnsupported CompletionBlock:completionBlock];
    }
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
    if (status == INSiriAuthorizationStatusNotDetermined) {
        [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
            if (status == INSiriAuthorizationStatusNotDetermined) {
                wtState = WTAuthorizationStateUnauthorized;
            } else if (status == INSiriAuthorizationStatusDenied) {
                wtState = WTAuthorizationStateDenied;
            } else if (status == INSiriAuthorizationStatusAuthorized) {
                wtState = WTAuthorizationStateAuthorized;
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == EKAuthorizationStatusRestricted) {

    } else if (status == EKAuthorizationStatusDenied) {
        wtState = WTAuthorizationStateDenied;
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 语音识别
- (void)requestAccessSpeechWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0f) {
         [self respondWithState:WTAuthorizationStateUnsupported CompletionBlock:completionBlock];
    }
    __weak __typeof(self)weakSelf = self;
    __block WTAuthorizationState wtState = WTAuthorizationStateUnkonw;
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    
    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            
            if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
                wtState = WTAuthorizationStateUnauthorized;
                
            } else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
                wtState = WTAuthorizationStateDenied;
                
            } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                wtState = WTAuthorizationStateAuthorized;
            }
            [weakSelf respondWithState:wtState CompletionBlock:completionBlock];
        }];
        return;
    } else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
        wtState = WTAuthorizationStateDenied;
    } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
        
    } else {
        wtState = WTAuthorizationStateAuthorized;
    }
    [self respondWithState:wtState CompletionBlock:completionBlock];
}

#pragma mark - 健康读权限集合 (常用)
- (NSSet *)dataTypesRead {
    // 步数
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    // 步行+跑步距离
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    // 燃烧能量
    HKQuantityType *energyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    // 身高
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    // 体重
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    // 血氧
    HKQuantityType *oxygenSaturationType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    // 消耗能量
    HKQuantityType *dietaryEnergyConsumedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    // 心率
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    // 呼吸率
    HKQuantityType *respiratoryRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    // 体温
    HKQuantityType *bodyTemperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    // 血糖
    HKQuantityType *bloodGlucoseType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    // 血压
    HKCorrelationType *bloodPressure = [HKObjectType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
    // 收缩压
    HKQuantityType *bloodPressureSystolicType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    // 舒张压
    HKQuantityType *bloodPressureDiastolicType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *bodyMassIndexType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    // 睡眠分析
    HKCategoryType *sleepAnalysis = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];

    return [NSSet setWithObjects:stepCountType,distanceType,energyType,heightType,weightType,oxygenSaturationType,dietaryEnergyConsumedType,heartRateType,respiratoryRateType,bodyTemperatureType,bloodGlucoseType,bloodPressureSystolicType,bloodPressureDiastolicType,bodyMassIndexType,sleepAnalysis,bloodPressure,nil];
}


#pragma mark - 在主线程中完成回调
- (void)respondWithState:(WTAuthorizationState)state CompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock(state);
        }
    });
}
@end
