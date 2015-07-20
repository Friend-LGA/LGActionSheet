//
//  LGActionSheet.m
//  LGActionSheet
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Grigory Lutkov <Friend.LGA@gmail.com>
//  (https://github.com/Friend-LGA/LGActionSheet)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "LGActionSheet.h"
#import "LGActionSheetCell.h"

#define kLGActionSheetSeparatorHeight ([UIScreen mainScreen].scale == 1.f || [UIDevice currentDevice].systemVersion.floatValue < 7.0 ? 1.f : 0.5)

static CGFloat const kLGActionSheetCornerRadiusTSBottom = 4.f;
static CGFloat const kLGActionSheetCornerRadiusTSCenter = 8.f;
static CGFloat const kLGActionSheetInnerMarginW         = 10.f;
static CGFloat const kLGActionSheetTitleMarginH         = 10.f;
static CGFloat const kLGActionSheetButtonTitleMarginH   = 5.f;
static CGFloat const kLGActionSheetButtonHeight         = 44.f;

@interface UIWindow (LGActionSheet)

- (UIViewController *)currentViewController;

@end

@interface LGActionSheetViewController : UIViewController

@property (strong, nonatomic) LGActionSheet *actionSheet;

@end

@interface LGActionSheet () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic, getter=isExists) BOOL exists;

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIWindow *windowPrevious;
@property (assign, nonatomic) UIWindow *windowNotice;

@property (strong, nonatomic) UIView *view;

@property (strong, nonatomic) LGActionSheetViewController *viewController;

@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) UIView *styleView;
@property (strong, nonatomic) UIView *styleCancelView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView  *tableView;

@property (strong, nonatomic) NSString       *title;
@property (strong, nonatomic) UIView         *innerView;
@property (strong, nonatomic) NSMutableArray *buttonTitles;
@property (strong, nonatomic) NSString       *cancelButtonTitle;
@property (strong, nonatomic) NSString       *destructiveButtonTitle;

@property (strong, nonatomic) UILabel  *titleLabel;
@property (strong, nonatomic) UIButton *destructiveButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIView   *separatorView1;
@property (strong, nonatomic) UIView   *separatorView2;

@property (assign, nonatomic) CGPoint scrollViewCenterShowed;
@property (assign, nonatomic) CGPoint scrollViewCenterHidden;

@property (assign, nonatomic) CGPoint cancelButtonCenterShowed;
@property (assign, nonatomic) CGPoint cancelButtonCenterHidden;

- (void)layoutInvalidateWithSize:(CGSize)size;

@end

#pragma mark -

@implementation UIWindow (LGActionSheet)

- (UIViewController *)currentViewController
{
    UIViewController *viewController = self.rootViewController;
    
    if (viewController.presentedViewController)
        viewController = viewController.presentedViewController;
    
    return viewController;
}

@end

@implementation LGActionSheetViewController

- (instancetype)initWithActionSheet:(LGActionSheet *)actionSheet
{
    self = [super init];
    if (self)
    {
        if ([UIDevice currentDevice].systemVersion.floatValue < 7.0)
            self.wantsFullScreenLayout = YES;
        
        _actionSheet = actionSheet;
        
        self.view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_actionSheet.view];
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    return window.currentViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    return window.currentViewController.supportedInterfaceOrientations;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0

#pragma mark iOS <= 7

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGSize size = self.view.frame.size;
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        size = CGSizeMake(MIN(size.width, size.height), MAX(size.width, size.height));
    else
        size = CGSizeMake(MAX(size.width, size.height), MIN(size.width, size.height));
    
    [_actionSheet layoutInvalidateWithSize:size];
}

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

#pragma mark iOS == 8

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [_actionSheet layoutInvalidateWithSize:size];
     }
                                 completion:nil];
}

#endif

@end

@implementation LGActionSheet

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
{
    self = [super init];
    if (self)
    {
        _title = title;
        _buttonTitles = buttonTitles.mutableCopy;
        _cancelButtonTitle = cancelButtonTitle;
        _destructiveButtonTitle = destructiveButtonTitle;
        
        [self setupDefaults];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
{
    self = [super init];
    if (self)
    {
        if ([view isKindOfClass:[UIScrollView class]])
            NSLog(@"LGFilterView: WARNING !!! view can not be subclass of UIScrollView !!!");
        
        // -----
        
        _title = title;
        _innerView = view;
        _buttonTitles = buttonTitles.mutableCopy;
        _cancelButtonTitle = cancelButtonTitle;
        _destructiveButtonTitle = destructiveButtonTitle;
        
        [self setupDefaults];
    }
    return self;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
{
    return [[self alloc] initWithTitle:title
                          buttonTitles:buttonTitles
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                                view:(UIView *)view
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
{
    return [[self alloc] initWithTitle:title
                                  view:view
                          buttonTitles:buttonTitles
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle];
}

#pragma mark -

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
           destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler
{
    self = [self initWithTitle:title buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle];
    if (self)
    {
        _actionHandler = actionHandler;
        _cancelHandler = cancelHandler;
        _destructiveHandler = destructiveHandler;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
           destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler
{
    self = [self initWithTitle:title view:view buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle];
    if (self)
    {
        _actionHandler = actionHandler;
        _cancelHandler = cancelHandler;
        _destructiveHandler = destructiveHandler;
    }
    return self;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                       actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                       cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
                  destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler
{
    return [[self alloc] initWithTitle:title
                          buttonTitles:buttonTitles
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle
                         actionHandler:actionHandler
                         cancelHandler:cancelHandler
                    destructiveHandler:destructiveHandler];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                                view:(UIView *)view
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                       actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                       cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
                  destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler
{
    return [[self alloc] initWithTitle:title
                                  view:view
                          buttonTitles:buttonTitles
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle
                         actionHandler:actionHandler
                         cancelHandler:cancelHandler
                    destructiveHandler:destructiveHandler];
}

#pragma mark -

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     delegate:(id<LGActionSheetDelegate>)delegate
{
    self = [self initWithTitle:title buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     delegate:(id<LGActionSheetDelegate>)delegate
{
    self = [self initWithTitle:title view:view buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                            delegate:(id<LGActionSheetDelegate>)delegate
{
    return [[self alloc] initWithTitle:title
                          buttonTitles:buttonTitles
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle
                              delegate:delegate];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                                view:(UIView *)view
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                            delegate:(id<LGActionSheetDelegate>)delegate
{
    return [[self alloc] initWithTitle:title
                                  view:view
                          buttonTitles:buttonTitles
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle
                              delegate:delegate];
}

#pragma mark -

- (void)setupDefaults
{
    _transitionStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGActionSheetTransitionStyleBottom : LGActionSheetTransitionStyleCenter);
    
    _cancelOnTouch = YES;
    
    self.tintColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
    
    _coverColor = [UIColor colorWithWhite:0.f alpha:0.5];
    _backgroundColor = [UIColor whiteColor];
    _layerCornerRadius = -1.f;
    _layerBorderColor = nil;
    _layerBorderWidth = 0.f;
    _layerShadowColor = nil;
    _layerShadowRadius = 0.f;
    
    _titleTextColor     = [UIColor grayColor];
    _titleTextAlignment = NSTextAlignmentCenter;
    _titleFont          = [UIFont systemFontOfSize:16.f];
    
    _buttonsTitleColor                 = _tintColor;
    _buttonsTitleColorHighlighted      = [UIColor whiteColor];
    _buttonsTextAlignment              = NSTextAlignmentCenter;
    _buttonsFont                       = [UIFont systemFontOfSize:20.f];
    _buttonsNumberOfLines              = 1;
    _buttonsLineBreakMode              = NSLineBreakByTruncatingMiddle;
    _buttonsAdjustsFontSizeToFitWidth  = YES;
    _buttonsMinimumScaleFactor         = 14.f/20.f;
    _buttonsBackgroundColorHighlighted = _tintColor;
    
    _cancelButtonTitleColor                 = _tintColor;
    _cancelButtonTitleColorHighlighted      = [UIColor whiteColor];
    _cancelButtonTextAlignment              = NSTextAlignmentCenter;
    _cancelButtonFont                       = [UIFont boldSystemFontOfSize:20.f];
    _cancelButtonNumberOfLines              = 1;
    _cancelButtonLineBreakMode              = NSLineBreakByTruncatingMiddle;
    _cancelButtonAdjustsFontSizeToFitWidth  = YES;
    _cancelButtonMinimumScaleFactor         = 14.f/20.f;
    _cancelButtonBackgroundColorHighlighted = _tintColor;
    
    _destructiveButtonTitleColor                 = [UIColor redColor];
    _destructiveButtonTitleColorHighlighted      = [UIColor whiteColor];
    _destructiveButtonTextAlignment              = NSTextAlignmentCenter;
    _destructiveButtonFont                       = [UIFont systemFontOfSize:20.f];
    _destructiveButtonNumberOfLines              = 1;
    _destructiveButtonLineBreakMode              = NSLineBreakByTruncatingMiddle;
    _destructiveButtonAdjustsFontSizeToFitWidth  = YES;
    _destructiveButtonMinimumScaleFactor         = 14.f/20.f;
    _destructiveButtonBackgroundColorHighlighted = [UIColor redColor];
    
    self.colorful = YES;
    
    _separatorsColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.f];
    
    _indicatorStyle = UIScrollViewIndicatorStyleBlack;
    
    // -----
    
    _view = [UIView new];
    _view.backgroundColor = [UIColor clearColor];
    _view.userInteractionEnabled = YES;
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _backgroundView = [UIView new];
    _backgroundView.alpha = 0.f;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_view addSubview:_backgroundView];
    
    // -----
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction:)];
    tapGesture.delegate = self;
    [_backgroundView addGestureRecognizer:tapGesture];
    
    // -----
    
    _viewController = [[LGActionSheetViewController alloc] initWithActionSheet:self];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.hidden = YES;
    _window.windowLevel = UIWindowLevelStatusBar+1;
    _window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _window.opaque = NO;
    _window.backgroundColor = [UIColor clearColor];
    _window.rootViewController = _viewController;
}

#pragma mark - Dealloc

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
#endif
    
    [self removeObservers];
}

#pragma mark - Observers

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowVisibleChanged:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowVisibleChanged:) name:UIWindowDidBecomeHiddenNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
}

- (void)windowVisibleChanged:(NSNotification *)notification
{
    //NSLog(@"windowVisibleChanged: %@", notification);
    
    UIWindow *window = notification.object;
    
    if (notification.name == UIWindowDidBecomeVisibleNotification)
    {
        if ([window isEqual:_windowPrevious])
        {
            window.hidden = YES;
        }
        else if (![window isEqual:_window] && !_windowNotice)
        {
            _windowNotice = window;
            
            _window.hidden = YES;
        }
    }
    else if (notification.name == UIWindowDidBecomeHiddenNotification)
    {
        __weak UIView *view = window.subviews.lastObject;
        
        if (![window isEqual:_window] && [window isEqual:_windowNotice])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                           {
                               if (!view)
                               {
                                   _windowNotice = nil;
                                   
                                   [_window makeKeyAndVisible];
                               }
                           });
        }
    }
}

#pragma mark - Setters and Getters

- (void)setColorful:(BOOL)colorful
{
    _colorful = colorful;
    
    if (_colorful)
    {
        _buttonsTitleColorHighlighted      = [UIColor whiteColor];
        _buttonsBackgroundColorHighlighted = _tintColor;
        
        _cancelButtonTitleColorHighlighted      = [UIColor whiteColor];
        _cancelButtonBackgroundColorHighlighted = _tintColor;
        
        _destructiveButtonTitleColorHighlighted      = [UIColor whiteColor];
        _destructiveButtonBackgroundColorHighlighted = [UIColor redColor];
    }
    else
    {
        _buttonsTitleColorHighlighted      = _buttonsTitleColor;
        _buttonsBackgroundColorHighlighted = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
        
        _cancelButtonTitleColorHighlighted      = _cancelButtonTitleColor;
        _cancelButtonBackgroundColorHighlighted = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
        
        _destructiveButtonTitleColorHighlighted      = _destructiveButtonTitleColor;
        _destructiveButtonBackgroundColorHighlighted = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    _buttonsBackgroundColorHighlighted      = _tintColor;
    _cancelButtonBackgroundColorHighlighted = _tintColor;
    
    _buttonsTitleColor      = _tintColor;
    _cancelButtonTitleColor = _tintColor;
    
    if (!self.isColorful)
    {
        _buttonsTitleColorHighlighted      = _tintColor;
        _cancelButtonTitleColorHighlighted = _tintColor;
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _buttonTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LGActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.title = _buttonTitles[indexPath.row];
    
    if (_destructiveButtonTitle.length && indexPath.row == 0)
    {
        cell.titleColor                 = _destructiveButtonTitleColor;
        cell.titleColorHighlighted      = _destructiveButtonTitleColorHighlighted;
        cell.backgroundColorHighlighted = _destructiveButtonBackgroundColorHighlighted;
        cell.separatorVisible           = (indexPath.row != _buttonTitles.count-1);
        cell.separatorColor_            = _separatorsColor;
        cell.textAlignment              = _destructiveButtonTextAlignment;
        cell.font                       = _destructiveButtonFont;
        cell.numberOfLines              = _destructiveButtonNumberOfLines;
        cell.lineBreakMode              = _destructiveButtonLineBreakMode;
        cell.adjustsFontSizeToFitWidth  = _destructiveButtonAdjustsFontSizeToFitWidth;
        cell.minimumScaleFactor         = _destructiveButtonMinimumScaleFactor;
    }
    else
    {
        cell.titleColor                 = _buttonsTitleColor;
        cell.titleColorHighlighted      = _buttonsTitleColorHighlighted;
        cell.backgroundColorHighlighted = _buttonsBackgroundColorHighlighted;
        cell.separatorVisible           = (indexPath.row != _buttonTitles.count-1);
        cell.separatorColor_            = _separatorsColor;
        cell.textAlignment              = _buttonsTextAlignment;
        cell.font                       = _buttonsFont;
        cell.numberOfLines              = _buttonsNumberOfLines;
        cell.lineBreakMode              = _buttonsLineBreakMode;
        cell.adjustsFontSizeToFitWidth  = _buttonsAdjustsFontSizeToFitWidth;
        cell.minimumScaleFactor         = _buttonsMinimumScaleFactor;
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_destructiveButtonTitle.length && indexPath.row == 0 && _destructiveButtonNumberOfLines != 1)
    {
        NSString *title = _buttonTitles[indexPath.row];
        
        UILabel *label = [UILabel new];
        label.text = title;
        label.textAlignment             = _destructiveButtonTextAlignment;
        label.font                      = _destructiveButtonFont;
        label.numberOfLines             = _destructiveButtonNumberOfLines;
        label.lineBreakMode             = _destructiveButtonLineBreakMode;
        label.adjustsFontSizeToFitWidth = _destructiveButtonAdjustsFontSizeToFitWidth;
        label.minimumScaleFactor        = _destructiveButtonMinimumScaleFactor;
        
        CGSize size = [label sizeThatFits:CGSizeMake(tableView.frame.size.width-kLGActionSheetInnerMarginW*2, CGFLOAT_MAX)];
        size.height += kLGActionSheetButtonTitleMarginH*2;
        
        if (size.height < kLGActionSheetButtonHeight)
            size.height = kLGActionSheetButtonHeight;
        
        return size.height;
    }
    else if (_buttonsNumberOfLines != 1)
    {
        NSString *title = _buttonTitles[indexPath.row];
        
        UILabel *label = [UILabel new];
        label.text = title;
        label.textAlignment             = _buttonsTextAlignment;
        label.font                      = _buttonsFont;
        label.numberOfLines             = _buttonsNumberOfLines;
        label.lineBreakMode             = _buttonsLineBreakMode;
        label.adjustsFontSizeToFitWidth = _buttonsAdjustsFontSizeToFitWidth;
        label.minimumScaleFactor        = _buttonsMinimumScaleFactor;
        
        CGSize size = [label sizeThatFits:CGSizeMake(tableView.frame.size.width-kLGActionSheetInnerMarginW*2, CGFLOAT_MAX)];
        size.height += kLGActionSheetButtonTitleMarginH*2;
        
        if (size.height < kLGActionSheetButtonHeight)
            size.height = kLGActionSheetButtonHeight;
        
        return size.height;
    }
    else return kLGActionSheetButtonHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_destructiveButtonTitle.length && indexPath.row == 0)
    {
        [self destructiveAction:nil];
    }
    else
    {
        [self dismissAnimated:YES completionHandler:nil];
        
        NSUInteger index = indexPath.row;
        if (_destructiveButtonTitle.length) index--;
        
        NSString *title = _buttonTitles[indexPath.row];
        
        if (_actionHandler) _actionHandler(self, title, index);
        
        if (_delegate && [_delegate respondsToSelector:@selector(actionSheet:buttonPressedWithTitle:index:)])
            [_delegate actionSheet:self buttonPressedWithTitle:title index:index];
    }
}

#pragma mark -

- (void)showAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isShowing) return;
    
    CGSize size = _viewController.view.frame.size;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        size = CGSizeMake(MIN(size.width, size.height), MAX(size.width, size.height));
    else
        size = CGSizeMake(MAX(size.width, size.height), MIN(size.width, size.height));
    
    [self subviewsInvalidateWithSize:size];
    [self layoutInvalidateWithSize:size];
    
    _showing = YES;
    
    [_window makeKeyAndVisible];
    
    // -----
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGActionSheetWillShowNotification object:self userInfo:nil];
    
    if (_willShowHandler) _willShowHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetWillShow:)])
        [_delegate actionSheetWillShow:self];
    
    // -----
    
    if (animated)
    {
        [LGActionSheet animateStandardWithAnimations:^(void)
         {
             [self showAnimations];
         }
                                          completion:^(BOOL finished)
         {
             [self showComplete];
             
             if (completionHandler) completionHandler();
         }];
    }
    else
    {
        [self showAnimations];
        
        [self showComplete];
        
        if (completionHandler) completionHandler();
    }
}

- (void)showAnimations
{
    _backgroundView.alpha = 1.f;
    
    if (_transitionStyle == LGActionSheetTransitionStyleBottom)
    {
        _scrollView.center = _scrollViewCenterShowed;
        
        _styleView.center = _scrollViewCenterShowed;
    }
    else
    {
        _scrollView.transform = CGAffineTransformIdentity;
        _scrollView.alpha = 1.f;
        
        _styleView.transform = CGAffineTransformIdentity;
        _styleView.alpha = 1.f;
    }
    
    if (_cancelButton)
    {
        _cancelButton.center = _cancelButtonCenterShowed;
        
        _styleCancelView.center = _cancelButtonCenterShowed;
    }
}

- (void)showComplete
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGActionSheetDidShowNotification object:self userInfo:nil];
    
    if (_didShowHandler) _didShowHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetDidShow:)])
        [_delegate actionSheetDidShow:self];
}

- (void)dismissAnimated:(BOOL)animated completionHandler:(void (^)())completionHandler
{
    if (!self.isShowing) return;
    
    _showing = NO;
    
    [self removeObservers];
    
    // -----
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGActionSheetWillDismissNotification object:self userInfo:nil];
    
    if (_willDismissHandler) _willDismissHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetWillDismiss:)])
        [_delegate actionSheetWillDismiss:self];
    
    // -----
    
    if (animated)
    {
        [LGActionSheet animateStandardWithAnimations:^(void)
         {
             [self dismissAnimations];
         }
                                          completion:^(BOOL finished)
         {
             [self dismissComplete];
             
             if (completionHandler) completionHandler();
         }];
    }
    else
    {
        [self dismissAnimations];
        
        [self dismissComplete];
        
        if (completionHandler) completionHandler();
    }
}

- (void)dismissAnimations
{
    _backgroundView.alpha = 0.f;
    
    if (_transitionStyle == LGActionSheetTransitionStyleBottom)
    {
        _scrollView.center = _scrollViewCenterHidden;
        
        _styleView.center = _scrollViewCenterHidden;
    }
    else
    {
        _scrollView.transform = CGAffineTransformMakeScale(0.95, 0.95);
        _scrollView.alpha = 0.f;
        
        _styleView.transform = CGAffineTransformMakeScale(0.95, 0.95);
        _styleView.alpha = 0.f;
    }
    
    if (_cancelButton)
    {
        _cancelButton.center = _cancelButtonCenterHidden;
        
        _styleCancelView.center = _cancelButtonCenterHidden;
    }
}

- (void)dismissComplete
{
    _window.hidden = YES;
    
    [_windowPrevious makeKeyAndVisible];
    
    self.viewController = nil;
    self.window = nil;
    
    // -----
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGActionSheetDidDismissNotification object:self userInfo:nil];
    
    if (_didDismissHandler) _didDismissHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetDidDismiss:)])
        [_delegate actionSheetDidDismiss:self];
}

#pragma mark -

- (void)subviewsInvalidateWithSize:(CGSize)size
{
    CGFloat widthMax = MIN(size.width, size.height)-kLGActionSheetMargin*2;
    if (_transitionStyle == LGActionSheetTransitionStyleCenter)
        widthMax = kLGActionSheetWidth;
    else if (_widthMax && _widthMax < widthMax)
        widthMax = _widthMax;
    
    // -----
    
    if (!self.isExists)
    {
        _exists = YES;
        
        _backgroundView.backgroundColor = _coverColor;
        
        _styleView = [UIView new];
        _styleView.backgroundColor = _backgroundColor;
        _styleView.layer.masksToBounds = NO;
        
        CGFloat cornerRadius = (_transitionStyle == LGActionSheetTransitionStyleBottom ? kLGActionSheetCornerRadiusTSBottom : kLGActionSheetCornerRadiusTSCenter);
        if (_layerCornerRadius >= 0)
            cornerRadius = _layerCornerRadius;
        
        _styleView.layer.cornerRadius = cornerRadius;
        _styleView.layer.borderColor = _layerBorderColor.CGColor;
        _styleView.layer.borderWidth = _layerBorderWidth;
        _styleView.layer.shadowColor = _layerShadowColor.CGColor;
        _styleView.layer.shadowRadius = _layerShadowRadius;
        _styleView.layer.shadowOpacity = 1.f;
        _styleView.layer.shadowOffset = CGSizeZero;
        [_view addSubview:_styleView];
        
        _scrollView = [UIScrollView new];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.indicatorStyle = _indicatorStyle;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.layer.masksToBounds = YES;
        _scrollView.layer.cornerRadius = cornerRadius;
        [_view addSubview:_scrollView];
        
        CGFloat offsetY = 0.f;
        
        if (_title.length)
        {
            _titleLabel = [UILabel new];
            _titleLabel.text = _title;
            _titleLabel.textColor = _titleTextColor;
            _titleLabel.textAlignment = _titleTextAlignment;
            _titleLabel.numberOfLines = 0;
            _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = _titleFont;
            
            CGSize titleLabelSize = [_titleLabel sizeThatFits:CGSizeMake(widthMax-kLGActionSheetInnerMarginW*2, CGFLOAT_MAX)];
            CGRect titleLabelFrame = CGRectMake(kLGActionSheetInnerMarginW, kLGActionSheetTitleMarginH, widthMax-kLGActionSheetInnerMarginW*2, titleLabelSize.height);
            if ([UIScreen mainScreen].scale == 1.f)
                titleLabelFrame = CGRectIntegral(titleLabelFrame);
            
            _titleLabel.frame = titleLabelFrame;
            [_scrollView addSubview:_titleLabel];
            
            offsetY = _titleLabel.frame.origin.y+_titleLabel.frame.size.height;
        }
        
        if (_innerView)
        {
            CGRect innerViewFrame = CGRectMake(widthMax/2-_innerView.frame.size.width/2, offsetY+kLGActionSheetTitleMarginH, _innerView.frame.size.width, _innerView.frame.size.height);
            if ([UIScreen mainScreen].scale == 1.f)
                innerViewFrame = CGRectIntegral(innerViewFrame);
            
            _innerView.frame = innerViewFrame;
            [_scrollView addSubview:_innerView];
            
            offsetY = _innerView.frame.origin.y+_innerView.frame.size.height;
        }
        
        if (_destructiveButtonTitle.length)
        {
            if (!_buttonTitles)
                _buttonTitles = [NSMutableArray new];
            
            [_buttonTitles insertObject:_destructiveButtonTitle atIndex:0];
        }
        
        if (_buttonTitles.count)
        {
            _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            _tableView.clipsToBounds = NO;
            _tableView.backgroundColor = [UIColor clearColor];
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _tableView.dataSource = self;
            _tableView.delegate = self;
            _tableView.scrollEnabled = NO;
            [_tableView registerClass:[LGActionSheetCell class] forCellReuseIdentifier:@"cell"];
            _tableView.frame = CGRectMake(0.f, 0.f, widthMax, CGFLOAT_MAX);
            [_tableView reloadData];
            
            if (!offsetY) offsetY = -kLGActionSheetTitleMarginH;
            else
            {
                _separatorView1 = [UIView new];
                _separatorView1.backgroundColor = _separatorsColor;
                
                CGRect separatorView1Frame = CGRectMake(0.f, 0.f, widthMax, kLGActionSheetSeparatorHeight);
                if ([UIScreen mainScreen].scale == 1.f)
                    separatorView1Frame = CGRectIntegral(separatorView1Frame);
                
                _separatorView1.frame = separatorView1Frame;
                _tableView.tableHeaderView = _separatorView1;
            }
            
            CGRect tableViewFrame = CGRectMake(0.f, offsetY+kLGActionSheetTitleMarginH, widthMax, _tableView.contentSize.height);
            if ([UIScreen mainScreen].scale == 1.f)
                tableViewFrame = CGRectIntegral(tableViewFrame);
            _tableView.frame = tableViewFrame;
            
            [_scrollView addSubview:_tableView];
            
            offsetY = _tableView.frame.origin.y+_tableView.frame.size.height;
        }
        
        // -----
        
        _scrollView.contentSize = CGSizeMake(widthMax, offsetY);
        
        // -----
        
        if (_cancelButtonTitle.length && _transitionStyle == LGActionSheetTransitionStyleBottom)
        {
            _styleCancelView = [UIView new];
            _styleCancelView.backgroundColor = _backgroundColor;
            _styleCancelView.layer.masksToBounds = NO;
            
            CGFloat cornerRadius = kLGActionSheetCornerRadiusTSBottom;
            if (_layerCornerRadius >= 0)
                cornerRadius = _layerCornerRadius;
            
            _styleCancelView.layer.cornerRadius = cornerRadius;
            _styleCancelView.layer.borderColor = _layerBorderColor.CGColor;
            _styleCancelView.layer.borderWidth = _layerBorderWidth;
            _styleCancelView.layer.shadowColor = _layerShadowColor.CGColor;
            _styleCancelView.layer.shadowRadius = _layerShadowRadius;
            _styleCancelView.layer.shadowOpacity = 1.f;
            _styleCancelView.layer.shadowOffset = CGSizeZero;
            [_view insertSubview:_styleCancelView belowSubview:_scrollView];
            
            _cancelButton = [UIButton new];
            _cancelButton.backgroundColor = [UIColor clearColor];
            _cancelButton.titleLabel.numberOfLines = _cancelButtonNumberOfLines;
            _cancelButton.titleLabel.lineBreakMode = _cancelButtonLineBreakMode;
            _cancelButton.titleLabel.adjustsFontSizeToFitWidth = _cancelButtonAdjustsFontSizeToFitWidth;
            _cancelButton.titleLabel.minimumScaleFactor = _cancelButtonMinimumScaleFactor;
            _cancelButton.titleLabel.font = _cancelButtonFont;
            [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
            [_cancelButton setTitleColor:_cancelButtonTitleColor forState:UIControlStateNormal];
            [_cancelButton setTitleColor:_cancelButtonTitleColorHighlighted forState:UIControlStateHighlighted];
            [_cancelButton setTitleColor:_cancelButtonTitleColorHighlighted forState:UIControlStateSelected];
            [_cancelButton setBackgroundImage:[LGActionSheet image1x1WithColor:_cancelButtonBackgroundColorHighlighted] forState:UIControlStateHighlighted];
            [_cancelButton setBackgroundImage:[LGActionSheet image1x1WithColor:_cancelButtonBackgroundColorHighlighted] forState:UIControlStateSelected];
            _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(kLGActionSheetButtonTitleMarginH, kLGActionSheetInnerMarginW, kLGActionSheetButtonTitleMarginH, kLGActionSheetInnerMarginW);
            _cancelButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            if (_cancelButtonTextAlignment == NSTextAlignmentCenter)
                _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            else if (_cancelButtonTextAlignment == NSTextAlignmentLeft)
                _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            else if (_cancelButtonTextAlignment == NSTextAlignmentRight)
                _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            _cancelButton.layer.masksToBounds = YES;
            _cancelButton.layer.cornerRadius = cornerRadius;
            [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
            [_view addSubview:_cancelButton];
        }
        
        // -----
        
        [self addObservers];
        
        // -----
        
        UIWindow *windowApp = [UIApplication sharedApplication].delegate.window;
        _windowPrevious = [UIApplication sharedApplication].keyWindow;
        
        if (![windowApp isEqual:_windowPrevious])
            _windowPrevious.hidden = YES;
    }
}

- (void)layoutInvalidateWithSize:(CGSize)size
{
    _view.frame = CGRectMake(0.f, 0.f, size.width, size.height);
    
    _backgroundView.frame = CGRectMake(0.f, 0.f, size.width, size.height);
    
    // -----
    
    CGFloat widthMax = MIN(size.width, size.height)-kLGActionSheetMargin*2;
    if (_transitionStyle == LGActionSheetTransitionStyleCenter)
        widthMax = kLGActionSheetWidth;
    else if (_widthMax && _widthMax < widthMax)
        widthMax = _widthMax;
    
    // -----
    
    CGFloat heightMax = size.height-kLGActionSheetMargin*2;
    
    if (_cancelButton)
        heightMax -= (kLGActionSheetButtonHeight+kLGActionSheetMargin);
    else if (_transitionStyle == LGActionSheetTransitionStyleCenter &&
             _cancelOnTouch &&
             size.width < widthMax+kLGActionSheetButtonHeight*2)
        heightMax -= kLGActionSheetButtonHeight*2;
    
    if (_heightMax && _heightMax < heightMax)
        heightMax = _heightMax;
    
    if (_scrollView.contentSize.height < heightMax)
        heightMax = _scrollView.contentSize.height;
    
    // -----
    
    CGRect scrollViewFrame = CGRectZero;
    CGAffineTransform scrollViewTransform = CGAffineTransformIdentity;
    CGFloat scrollViewAlpha = 1.f;
    
    if (_transitionStyle == LGActionSheetTransitionStyleBottom)
    {
        CGFloat bottomShift = kLGActionSheetMargin;
        if (_cancelButton)
            bottomShift += kLGActionSheetButtonHeight+kLGActionSheetMargin;
        
        scrollViewFrame = CGRectMake(size.width/2-widthMax/2, size.height-bottomShift-heightMax, widthMax, heightMax);
    }
    else
    {
        scrollViewFrame = CGRectMake(size.width/2-widthMax/2, size.height/2-heightMax/2, widthMax, heightMax);
        
        if (!self.isShowing)
        {
            scrollViewTransform = CGAffineTransformMakeScale(1.2, 1.2);
            
            scrollViewAlpha = 0.f;
        }
    }
    
    if ([UIScreen mainScreen].scale == 1.f)
    {
        scrollViewFrame = CGRectIntegral(scrollViewFrame);
        
        if (_tableView && _tableView.frame.origin.y+_tableView.frame.size.height < scrollViewFrame.size.height)
            scrollViewFrame.size.height = _tableView.frame.origin.y+_tableView.frame.size.height;
    }
    
    // -----
    
    if (_transitionStyle == LGActionSheetTransitionStyleBottom)
    {
        CGRect cancelButtonFrame = CGRectZero;
        if (_cancelButton)
        {
            cancelButtonFrame = CGRectMake(size.width/2-widthMax/2, size.height-kLGActionSheetMargin-kLGActionSheetButtonHeight, widthMax, kLGActionSheetButtonHeight);
            if ([UIScreen mainScreen].scale == 1.f)
                cancelButtonFrame = CGRectIntegral(cancelButtonFrame);
        }
        
        _scrollViewCenterShowed = CGPointMake(scrollViewFrame.origin.x+scrollViewFrame.size.width/2, scrollViewFrame.origin.y+scrollViewFrame.size.height/2);
        _cancelButtonCenterShowed = CGPointMake(cancelButtonFrame.origin.x+cancelButtonFrame.size.width/2, cancelButtonFrame.origin.y+cancelButtonFrame.size.height/2);
        
        // -----
        
        CGFloat commonHeight = scrollViewFrame.size.height+kLGActionSheetMargin;
        if (_cancelButton)
            commonHeight += kLGActionSheetButtonHeight+kLGActionSheetMargin;
        
        _scrollViewCenterHidden = CGPointMake(scrollViewFrame.origin.x+scrollViewFrame.size.width/2, scrollViewFrame.origin.y+scrollViewFrame.size.height/2+commonHeight+_layerBorderWidth+_layerShadowRadius);
        _cancelButtonCenterHidden = CGPointMake(cancelButtonFrame.origin.x+cancelButtonFrame.size.width/2, cancelButtonFrame.origin.y+cancelButtonFrame.size.height/2+commonHeight);
        
        if (!self.isShowing)
        {
            scrollViewFrame.origin.y += commonHeight;
            if ([UIScreen mainScreen].scale == 1.f)
                scrollViewFrame = CGRectIntegral(scrollViewFrame);
            
            if (_cancelButton)
            {
                cancelButtonFrame.origin.y += commonHeight;
                if ([UIScreen mainScreen].scale == 1.f)
                    cancelButtonFrame = CGRectIntegral(cancelButtonFrame);
            }
        }
        
        // -----
        
        if (_cancelButton)
        {
            _cancelButton.frame = cancelButtonFrame;
            
            CGFloat borderWidth = _layerBorderWidth;
            _styleCancelView.frame = CGRectMake(cancelButtonFrame.origin.x-borderWidth, cancelButtonFrame.origin.y-borderWidth, cancelButtonFrame.size.width+borderWidth*2, cancelButtonFrame.size.height+borderWidth*2);
        }
    }
    
    // -----
    
    _scrollView.frame = scrollViewFrame;
    _scrollView.transform = scrollViewTransform;
    _scrollView.alpha = scrollViewAlpha;
    
    CGFloat borderWidth = _layerBorderWidth;
    _styleView.frame = CGRectMake(scrollViewFrame.origin.x-borderWidth, scrollViewFrame.origin.y-borderWidth, scrollViewFrame.size.width+borderWidth*2, scrollViewFrame.size.height+borderWidth*2);
    _styleView.transform = scrollViewTransform;
    _styleView.alpha = scrollViewAlpha;
}

#pragma mark -

- (void)cancelAction:(id)sender
{
    BOOL onButton = [sender isKindOfClass:[UIButton class]];
    
    if (sender)
    {
        if (onButton)
            [(UIButton *)sender setSelected:YES];
        else if ([sender isKindOfClass:[UIGestureRecognizer class]] && !self.isCancelOnTouch)
            return;
    }
    
    [self dismissAnimated:YES completionHandler:nil];
    
    // -----
    
    if (_cancelHandler) _cancelHandler(self, onButton);
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetCancelled:)])
        [_delegate actionSheetCancelled:self];
}

- (void)destructiveAction:(id)sender
{
    if (sender && [sender isKindOfClass:[UIButton class]])
        [(UIButton *)sender setSelected:YES];
    
    [self dismissAnimated:YES completionHandler:nil];
    
    if (_destructiveHandler) _destructiveHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetDestructiveButtonPressed:)])
        [_delegate actionSheetDestructiveButtonPressed:self];
}

#pragma mark - Support

+ (void)animateStandardWithAnimations:(void(^)())animations completion:(void(^)(BOOL finished))completion
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.5
                            options:0
                         animations:animations
                         completion:completion];
    }
    else
    {
        [UIView animateWithDuration:0.5*0.66
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    }
}

+ (UIImage *)image1x1WithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
