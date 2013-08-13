//
//  SNBeatListViewController.h
//  iOSSearchNamesInTable
//
//  Created by Bradley Griffith on 8/13/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNBeatListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@interface NSArray (Reverse)
- (NSArray *)sortedDiacriticalAlphabetical;
@end
