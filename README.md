从iOS 10开始获取用户隐私数据都需要在info.plist文件中配置对应的权限。在没有配置权限下调系统接口直接闪退，也是很苹果。

目前涉及16种隐私权限，分别是蓝牙、日历、相机、通讯录、Face ID、健康分享、住宅配件、位置、麦克风、运动与健身、媒体与Apple Music、NFC、相册、提醒事项、Siri、 语音识别。


## 配置权限的XML格式

```xml
<!-- 蓝牙 -->
<key>NSBluetoothPeripheralUsageDescription</key>
<string>App需要您的同意,才能访问蓝牙</string>

<!-- 日历 -->
<key>NSCalendarsUsageDescription</key>
<string>App需要您的同意,才能访问日历</string>

<!-- 相机 -->
<key>NSCameraUsageDescription</key>
<string>App需要您的同意,才能访问相机</string>

<!-- 通讯录 -->
<key>NSContactsUsageDescription</key>
<string>App需要您的同意,才能访问通讯录</string>

<!-- Face ID --> 
<key>NSFaceIDUsageDescription</key>
<string>App需要您的同意,才能访问Face ID</string>

<!-- 健康分享 --> 
<key>NSHealthShareUsageDescription</key>
<string>App需要您的同意,才能访问健康分享</string>

<!-- 健康更新 -->
<key>NSHealthUpdateUsageDescription</key>
<string>App需要您的同意,才能访问健康更新 </string>

<!-- 住宅配件 --> 
<key>NSHomeKitUsageDescription</key>
<string>App需要您的同意,才能访问住宅配件 </string>

<!-- 位置 -->
<key>NSLocationUsageDescription</key>
<string>App需要您的同意,才能访问位置</string>

<!-- 始终访问位置 -->
<key>NSLocationAlwaysUsageDescription</key>
<string>App需要您的同意,才能始终访问位置</string>

<!-- 在使用期间访问位置 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>App需要您的同意,才能在使用期间访问位置</string>

<!-- 麦克风 -->
<key>NSMicrophoneUsageDescription</key>
<string>App需要您的同意,才能访问麦克风</string>

<!-- 运动与健身 -->
<key>NSMotionUsageDescription</key>
<string>App需要您的同意,才能访问运动与健身</string>

<!-- 媒体资料库 -->
<key>NSAppleMusicUsageDescription</key>
<string>App需要您的同意,才能访问媒体资料库</string>

<!-- NFC -->
<key>NFCReaderUsageDescription</key>
<string>App需要您的同意,才能访问NFC</string>

<!-- 相册 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>

<!-- 提醒事项 -->
<key>NSRemindersUsageDescription</key>
<string>App需要您的同意,才能访问提醒事项</string>

<!-- Siri -->
<key>NSSiriUsageDescription</key>
<string>App需要您的同意,才能使用Siri功能</string> 

<!-- 语音识别 -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>App需要您的同意,才能使用语音识别功能</string> 

<!-- 电视提供商 -->
<key>NSVideoSubscriberAccountUsageDescription</key>
<string>App需要您的同意,才能访问电视提供商</string> 
```

## 需要引入的库

```
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
```

## Capabilities中开启相应开关
![Capabilities.png](https://upload-images.jianshu.io/upload_images/937490-b315a845fe199715.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 请求获取隐私权限

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```


```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

```obj
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
```

隐私权限请求完成应在主线程中完成回调

```obj
#pragma mark - 在主线程中完成回调
- (void)respondWithState:(WTAuthorizationState)state CompletionBlock:(AuthorizationStateCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock(state);
        }
    });
}
```

## 总结
 
获取隐私权限需要分为四步：

- 在Info.plist文件中配置应用所需权限；
- 在项目的Targets->Capabilities中开启相应开关，目前Siri、Health、NFC、HomeKit需要开启；
- 引入相关库；
- 使用代码获取对应的隐私权限。



## 参考
[Protecting the User’s Privacy](https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy?language=objc)
[Checking and Requesting Access to Data Classes in Privacy Settings](https://developer.apple.com/library/archive/samplecode/PrivacyPrompts/Introduction/Intro.html)

