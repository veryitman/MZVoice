//
//  ViewController.m
//  WePlayVoiceDemo
//
//  Created by Me on 24/05/2017.
//  Copyright © 2017 veryitman.com. All rights reserved.
//

#import "ViewController.h"
#import "MZIMVoiceManager.h"
#import "IDSIMVoiceMainPage.h"
#import "IDSRoomTablePage.h"
#import "UIView+MZToast.h"

static NSString * const sLoginStr    = @"登录";
static NSString * const sJoinRoomStr = @"房间";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NSString *> *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"实时语音";
    
    [self _setupViews];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self handleEvent:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_gv";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *title = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)handleEvent:(NSIndexPath *)indexPath
{
    if (nil == indexPath) {
        return;
    }
    
    NSString *title = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([sLoginStr isEqualToString:title]) {
        [self loginGVoice];
    }
    else if ([sJoinRoomStr isEqualToString:title]) {
        IDSRoomTablePage *page = [[IDSRoomTablePage alloc] initWithNibName:NSStringFromClass([IDSRoomTablePage class]) bundle:nil];
        [self.navigationController pushViewController:page animated:YES];
    }
}

- (void)loginGVoice
{
    BOOL sus = [MZVManagerInstance initIMVoiceSDK];
    
    if (sus) {
        [self.view showToast:@"登录成功."];
    }
    else {
        [self.view showToast:@"登录失败."];
    }
}

- (void)_setupViews
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.rowHeight = 50.f;
    
    [self.view addSubview:self.tableView];
}

- (NSMutableArray *)dataSource
{
    if (nil == _dataSource) {
        _dataSource = [NSMutableArray arrayWithObjects:sLoginStr, sJoinRoomStr, nil];
    }
    
    return _dataSource;
}

@end
