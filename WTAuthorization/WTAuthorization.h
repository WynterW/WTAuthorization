//
//  WTAuthorization.h
//  WTAuthorization
//
//  Created by Wynter on 2018/12/7.
//  Copyright © 2018 Wynter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WTPrivacyType) {
    WTPrivacyTypeBluetooth          = 1,// 蓝牙
    WTPrivacyTypeCalendars          = 2,// 日历
    WTPrivacyTypeCamera             = 3,// 相机
    WTPrivacyTypeContacts           = 4,// 通讯录
    WTPrivacyTypeFaceID             = 5,// 人脸识别 >= iOS 11
    WTPrivacyTypeHealth             = 6,// 健康
    WTPrivacyTypeHomeKit            = 7,// 住宅
    WTPrivacyTypeLocationServices   = 8,// 定位服务
    WTPrivacyTypeMicrophone         = 9,// 麦克风
    WTPrivacyTypeMotionAndFitness   = 10,// 运动与健身
    WTPrivacyTypeMediaAndAppleMusic = 11,// 媒体与Apple Music >= iOS9.3
    WTPrivacyTypeNFC                = 12,// NFC >= iOS10
    WTPrivacyTypePhotos             = 13,// 照片
    WTPrivacyTypeReminders          = 14,// 提醒事项
    WTPrivacyTypeSiri               = 15,// Siri
    WTPrivacyTypeSpeechRecognition  = 16,// 语音识别 >= iOS10
};

typedef NS_ENUM(NSInteger, WTAuthorizationState) {
    WTAuthorizationStateUnkonw = 0, // 未知
    WTAuthorizationStateUnauthorized = 1, // 未授权
    WTAuthorizationStateDenied = 2, // 拒绝
    WTAuthorizationStateUnsupported = 3, // 设备不支持
    WTAuthorizationStateAuthorized = 4, // 已授权，可用
};

typedef void(^AuthorizationStateCompletionBlock)(WTAuthorizationState state);

/**<
 NOTE:
 
 一、HMHomeManager、CLLocationManager必须使用属性定义，否则会被销毁无法正常使用;
 
 二、Siri、Health、NFC、HomeKit需要在Capabilities开启相应配置，否则无法访问；
 
 三、WTPrivacyTypeHealth 获取的是心率访问权限，具体访问权限可以自定义集合
 */

NS_ASSUME_NONNULL_BEGIN

@interface WTAuthorization : NSObject

+ (WTAuthorization *)sharedInstance;


/**
 获取指定类型访问权限

 @param type 权限类型
 @param completionBlock 回调权限访问状态
 */
- (void)requestAccessWithPrivacyType:(WTPrivacyType)type CompletionBlock:(AuthorizationStateCompletionBlock)completionBlock;


/**
 获取常用健康数据访问权限
 
 上面获取的健康权限是以心率为例的权限

 @param completionBloc 回调权限访问状态
 */
- (void)requestAccessAllHealthWithCompletionBlock:(AuthorizationStateCompletionBlock)completionBloc;

@end

NS_ASSUME_NONNULL_END
