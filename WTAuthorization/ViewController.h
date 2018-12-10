//
//  ViewController.h
//  WTAuthorization
//
//  Created by Wynter on 2018/12/6.
//  Copyright © 2018 Wynter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTAuthorization.h"

@interface ViewController : UITableViewController

@end

@interface PrivacyModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) WTPrivacyType privacyType;

@end
