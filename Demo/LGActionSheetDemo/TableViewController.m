//
//  TableViewController.m
//  LGActionSheetDemo
//
//  Created by Grigory Lutkov on 18.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "TableViewController.h"
#import "LGActionSheet.h"

@interface TableViewController ()

@property (strong, nonatomic) NSArray *titlesArray;

@end

@implementation TableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.title = @"LGActionSheet";

        _titlesArray = @[@"UIActionSheet",
                         @"LGActionSheet + UIView",
                         @"LGActionSheet + Buttons Short",
                         @"LGActionSheet + Buttons Long",
                         @"LGActionSheet + Buttons Multiline",
                         @"LGActionSheet + Buttons (a lot of) 1",
                         @"LGActionSheet + Buttons (a lot of) 2",
                         @"LGActionSheet + No cancel gesture",
                         @"LGActionSheet + Crazy style"];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return self;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titlesArray.count;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.text = _titlesArray[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [[[UIActionSheet alloc] initWithTitle:@"Title"
                                     delegate:nil
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:@"Destructive"
                            otherButtonTitles:@"Other 1", @"Other 2", nil] showInView:self.view];
    }
    else if (indexPath.row == 1)
    {
        UIDatePicker *datePicker = [UIDatePicker new];
        datePicker.frame = CGRectMake(0.f, 0.f, datePicker.frame.size.width, 100.f);

        [[[LGActionSheet alloc] initWithTitle:@"Choose any date, please"
                                         view:datePicker
                                 buttonTitles:@[@"Done"]
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                                actionHandler:nil
                                cancelHandler:nil
                           destructiveHandler:nil] showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 2)
    {
        [[[LGActionSheet alloc] initWithTitle:@"Tap any button"
                                 buttonTitles:@[@"Other 1", @"Other 2"]
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:@"Destructive"
                                actionHandler:nil
                                cancelHandler:nil
                           destructiveHandler:nil] showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 3)
    {
        [[[LGActionSheet alloc] initWithTitle:@"Some really unbelievable long title text. And for iPhone 6 Plus it needs to be even bigger."
                                 buttonTitles:@[@"Other button 1 with longest title text, for iPhone 6 Plus even bigger.",
                                                @"Other button 2 with longest title text, for iPhone 6 Plus even bigger."]
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:@"Destructive"
                                actionHandler:nil
                                cancelHandler:nil
                           destructiveHandler:nil] showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 4)
    {
        LGActionSheet *actionSheet = [[LGActionSheet alloc] initWithTitle:@"Some really unbelievable long title text. And for iPhone 6 Plus it needs to be even bigger."
                                                             buttonTitles:@[@"Other button 1 with longest title text, for iPhone 6 Plus even bigger.",
                                                                            @"Other button 2 with longest title text, for iPhone 6 Plus even bigger."]
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Destructive"
                                                            actionHandler:nil
                                                            cancelHandler:nil
                                                       destructiveHandler:nil];
        actionSheet.buttonsNumberOfLines = 0;
        [actionSheet showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 5)
    {
        [[[LGActionSheet alloc] initWithTitle:@"A lot of buttons, scroll it"
                                 buttonTitles:@[@"Other 1",
                                                @"Other 2",
                                                @"Other 3",
                                                @"Other 4",
                                                @"Other 5",
                                                @"Other 6",
                                                @"Other 7",
                                                @"Other 8",
                                                @"Other 9",
                                                @"Other 10",
                                                @"Other 12",
                                                @"Other 13",
                                                @"Other 14",
                                                @"Other 15",
                                                @"Other 16",
                                                @"Other 17",
                                                @"Other 18",
                                                @"Other 19",
                                                @"Other 20",
                                                @"Other 21",
                                                @"Other 22",
                                                @"Other 23",
                                                @"Other 24",
                                                @"Other 25"]
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:@"Destructive"
                                actionHandler:nil
                                cancelHandler:nil
                           destructiveHandler:nil] showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 6)
    {
        LGActionSheet *actionSheet = [[LGActionSheet alloc] initWithTitle:@"A lot of buttons, scroll it"
                                                             buttonTitles:@[@"Other 1",
                                                                            @"Other 2",
                                                                            @"Other 3",
                                                                            @"Other 4",
                                                                            @"Other 5",
                                                                            @"Other 6",
                                                                            @"Other 7",
                                                                            @"Other 8",
                                                                            @"Other 9",
                                                                            @"Other 10",
                                                                            @"Other 12",
                                                                            @"Other 13",
                                                                            @"Other 14",
                                                                            @"Other 15"]
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Destructive"
                                                            actionHandler:nil
                                                            cancelHandler:nil
                                                       destructiveHandler:nil];
        actionSheet.heightMax = 200.f;
        [actionSheet showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 7)
    {
        LGActionSheet *actionSheet = [[LGActionSheet alloc] initWithTitle:@"No cancel here, you need to make a decision"
                                                             buttonTitles:@[@"Blue pill"]
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:@"Red pill"
                                                            actionHandler:nil
                                                            cancelHandler:nil
                                                       destructiveHandler:nil];
        actionSheet.cancelOnTouch = NO;
        [actionSheet showAnimated:YES completionHandler:nil];
    }
    else if (indexPath.row == 8)
    {
        LGActionSheet *actionSheet = [[LGActionSheet alloc] initWithTitle:@"CRAZY STYLE\nMay be someone like it?"
                                                             buttonTitles:@[@"Cancel"]
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:@"Destructive"
                                                            actionHandler:nil
                                                            cancelHandler:nil
                                                       destructiveHandler:nil];

        actionSheet.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.8];
        actionSheet.offsetAround = 0;
        actionSheet.buttonsHeight = 64.f;

        actionSheet.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        actionSheet.layerBorderWidth = 1.f;
        actionSheet.layerBorderColor = [UIColor redColor];
        actionSheet.layerCornerRadius = 0.f;
        actionSheet.layerShadowColor = [UIColor colorWithWhite:0.f alpha:0.5];
        actionSheet.layerShadowRadius = 5.f;

        actionSheet.titleTextAlignment = NSTextAlignmentLeft;
        actionSheet.titleTextColor = [UIColor whiteColor];

        actionSheet.separatorsColor = [UIColor colorWithWhite:0.6 alpha:1.f];

        actionSheet.tintColor = [UIColor greenColor];

        actionSheet.buttonsTitleColorHighlighted = [UIColor blackColor];

        actionSheet.cancelButtonTitleColor = [UIColor cyanColor];
        actionSheet.cancelButtonTitleColorHighlighted = [UIColor blackColor];
        actionSheet.cancelButtonBackgroundColorHighlighted = [UIColor cyanColor];

        actionSheet.destructiveButtonTitleColor = [UIColor yellowColor];
        actionSheet.destructiveButtonTitleColorHighlighted = [UIColor blackColor];
        actionSheet.destructiveButtonBackgroundColorHighlighted = [UIColor yellowColor];

        // And much more settings you can apply, check it in LGActionSheet class

        [actionSheet showAnimated:YES completionHandler:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end









