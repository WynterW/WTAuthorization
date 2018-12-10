//
//  ViewController.m
//  WTAuthorization
//
//  Created by Wynter on 2018/12/6.
//  Copyright © 2018 Wynter. All rights reserved.
//

#import "ViewController.h"
#import "WTAuthorization.h"

@implementation PrivacyModel

@end

@interface ViewController ()

@property (nonatomic, strong) NSArray *titltAry;
@property (nonatomic, strong) NSMutableArray *dataAry;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titltAry = @[@"访问蓝牙权限", @"访问日历权限", @"访问相机权限", @"访问通讯录权限", @"访问Face ID权限", @"访问健康分享权限", @"访问住宅配件权限", @"访问位置权限", @"访问麦克风权限", @"访问运动与健身权限", @"访问媒体与Apple Music权限", @"访问NFC权限", @"访问相册权限", @"访问提醒事项权限", @"访问Siri权限", @"访问语音识别权限"];
    
    self.dataAry = [NSMutableArray array];
    for (int i = 0; i < self.titltAry.count; i++) {
        PrivacyModel *item = [[PrivacyModel alloc]init];
        item.title = self.titltAry[i];
        item.privacyType = i + 1;
        [self.dataAry addObject:item];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataAry.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    PrivacyModel *item = self.dataAry[indexPath.row];
    cell.textLabel.text = item.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PrivacyModel *item = self.dataAry[indexPath.row];
    [[WTAuthorization sharedInstance] requestAccessWithPrivacyType:item.privacyType CompletionBlock:^(WTAuthorizationState state) {
        if (state == WTAuthorizationStateAuthorized) {
            NSLog(@"%@可以访问", item.title);
        } else if (state == WTAuthorizationStateDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"去开启%@", item.title] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            UIAlertAction *destructive = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self openSettings];
            }];
            [alert addAction:cancel];
            [alert addAction:destructive];
            [self presentViewController:alert animated:YES completion:^{}];
        } else if (state == WTAuthorizationStateUnsupported) {
            NSLog(@"%@设备不支持", item.title);
        } else {
            NSLog(@"%@无法访问", item.title);
        }
    }];
}

- (void)openSettings {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
