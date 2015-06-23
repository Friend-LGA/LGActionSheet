//
//  LGActionView.h
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

#import <UIKit/UIKit.h>

@class LGActionSheet;

static NSString *const kLGActionSheetWillShowNotification    = @"LGActionSheetWillShowNotification";
static NSString *const kLGActionSheetWillDismissNotification = @"LGActionSheetWillDismissNotification";
static NSString *const kLGActionSheetDidShowNotification     = @"LGActionSheetDidShowNotification";
static NSString *const kLGActionSheetDidDismissNotification  = @"LGActionSheetDidDismissNotification";

static CGFloat const kLGActionSheetMargin = 8.f;
static CGFloat const kLGActionSheetWidth  = 320.f-kLGActionSheetMargin*2;

@protocol LGActionSheetDelegate <NSObject>

@optional

- (void)actionSheetWillShow:(LGActionSheet *)actionSheet;
- (void)actionSheetWillDismiss:(LGActionSheet *)actionSheet;
- (void)actionSheetDidShow:(LGActionSheet *)actionSheet;
- (void)actionSheetDidDismiss:(LGActionSheet *)actionSheet;
- (void)actionSheet:(LGActionSheet *)actionSheet buttonPressedWithTitle:(NSString *)title index:(NSUInteger)index;
- (void)actionSheetCancelled:(LGActionSheet *)actionSheet;
- (void)actionSheetDestructiveButtonPressed:(LGActionSheet *)actionSheet;

@end

@interface LGActionSheet : NSObject

typedef enum
{
    LGActionSheetTransitionStyleBottom = 0,
    LGActionSheetTransitionStyleCenter = 1
}
LGActionSheetTransitionStyle;

@property (assign, nonatomic) LGActionSheetTransitionStyle transitionStyle;

@property (assign, nonatomic, getter=isShowing) BOOL showing;

/** Default is YES */
@property (assign, nonatomic, getter=isCancelOnTouch) BOOL cancelOnTouch;
/** Set highlighted buttons background color to blue, and set highlighted destructive button background color to red. Default is YES */
@property (assign, nonatomic, getter=isColorful) BOOL colorful;

@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIColor *coverColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) CGFloat layerCornerRadius;
@property (strong, nonatomic) UIColor *layerBorderColor;
@property (assign, nonatomic) CGFloat layerBorderWidth;
@property (strong, nonatomic) UIColor *layerShadowColor;
@property (assign, nonatomic) CGFloat layerShadowRadius;

@property (assign, nonatomic) CGFloat heightMax;
@property (assign, nonatomic) CGFloat widthMax;

@property (strong, nonatomic) UIColor         *titleTextColor;
@property (assign, nonatomic) NSTextAlignment titleTextAlignment;
@property (strong, nonatomic) UIFont          *titleFont;

@property (strong, nonatomic) UIColor         *buttonsTitleColor;
@property (strong, nonatomic) UIColor         *buttonsTitleColorHighlighted;
@property (assign, nonatomic) NSTextAlignment buttonsTextAlignment;
@property (strong, nonatomic) UIFont          *buttonsFont;
@property (strong, nonatomic) UIColor         *buttonsBackgroundColorHighlighted;
@property (assign, nonatomic) NSUInteger      buttonsNumberOfLines;
@property (assign, nonatomic) NSLineBreakMode buttonsLineBreakMode;
@property (assign, nonatomic) BOOL            buttonsAdjustsFontSizeToFitWidth;
@property (assign, nonatomic) CGFloat         buttonsMinimumScaleFactor;

@property (strong, nonatomic) UIColor         *cancelButtonTitleColor;
@property (strong, nonatomic) UIColor         *cancelButtonTitleColorHighlighted;
@property (assign, nonatomic) NSTextAlignment cancelButtonTextAlignment;
@property (strong, nonatomic) UIFont          *cancelButtonFont;
@property (strong, nonatomic) UIColor         *cancelButtonBackgroundColorHighlighted;
@property (assign, nonatomic) NSUInteger      cancelButtonNumberOfLines;
@property (assign, nonatomic) NSLineBreakMode cancelButtonLineBreakMode;
@property (assign, nonatomic) BOOL            cancelButtonAdjustsFontSizeToFitWidth;
@property (assign, nonatomic) CGFloat         cancelButtonMinimumScaleFactor;

@property (strong, nonatomic) UIColor         *destructiveButtonTitleColor;
@property (strong, nonatomic) UIColor         *destructiveButtonTitleColorHighlighted;
@property (assign, nonatomic) NSTextAlignment destructiveButtonTextAlignment;
@property (strong, nonatomic) UIFont          *destructiveButtonFont;
@property (strong, nonatomic) UIColor         *destructiveButtonBackgroundColorHighlighted;
@property (assign, nonatomic) NSUInteger      destructiveButtonNumberOfLines;
@property (assign, nonatomic) NSLineBreakMode destructiveButtonLineBreakMode;
@property (assign, nonatomic) BOOL            destructiveButtonAdjustsFontSizeToFitWidth;
@property (assign, nonatomic) CGFloat         destructiveButtonMinimumScaleFactor;

@property (strong, nonatomic) UIColor *separatorsColor;

@property (assign, nonatomic) UIScrollViewIndicatorStyle indicatorStyle;

/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willShowHandler)(LGActionSheet *actionSheet);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willDismissHandler)(LGActionSheet *actionSheet);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didShowHandler)(LGActionSheet *actionSheet);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didDismissHandler)(LGActionSheet *actionSheet);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^actionHandler)(LGActionSheet *actionSheet, NSString *title, NSUInteger index);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^cancelHandler)(LGActionSheet *actionSheet, BOOL onButton);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^destructiveHandler)(LGActionSheet *actionSheet);

@property (assign, nonatomic) id<LGActionSheetDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle;

/** View can not be subclass of UIScrollView */
- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle;

+ (instancetype)actionSheetWithTitle:(NSString *)title
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle;

+ (instancetype)actionSheetWithTitle:(NSString *)title
                                view:(UIView *)view
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle;

#pragma mark -

/** Do not forget about weak referens to self for actionHandler, cancelHandler and destructiveHandler blocks */
- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
           destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler;

/**
 View can not be subclass of UIScrollView.
 Do not forget about weak referens to self for actionHandler, cancelHandler and destructiveHandler blocks.
 */
- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
           destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler;

/** Do not forget about weak referens to self for actionHandler, cancelHandler and destructiveHandler blocks */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                       actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                       cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
                  destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler;

/**
 View can not be subclass of UIScrollView.
 Do not forget about weak referens to self for actionHandler, cancelHandler and destructiveHandler blocks.
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                                view:(UIView *)view
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                       actionHandler:(void(^)(LGActionSheet *actionSheet, NSString *title, NSUInteger index))actionHandler
                       cancelHandler:(void(^)(LGActionSheet *actionSheet, BOOL onButton))cancelHandler
                  destructiveHandler:(void(^)(LGActionSheet *actionSheet))destructiveHandler;

#pragma mark -

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     delegate:(id<LGActionSheetDelegate>)delegate;

/** View can not be subclass of UIScrollView */
- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     delegate:(id<LGActionSheetDelegate>)delegate;

+ (instancetype)actionSheetWithTitle:(NSString *)title
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                            delegate:(id<LGActionSheetDelegate>)delegate;

/** View can not be subclass of UIScrollView */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                                view:(UIView *)view
                        buttonTitles:(NSArray *)buttonTitles
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                            delegate:(id<LGActionSheetDelegate>)delegate;

#pragma mark -

- (void)showAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)dismissAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;

#pragma mark -

/** Unavailable, use +actionSheetWithTitle... instead */
+ (instancetype)new __attribute__((unavailable("use +actionSheetWithTitle... instead")));
/** Unavailable, use -initWithTitle... instead */
- (instancetype)init __attribute__((unavailable("use -initWithTitle... instead")));
/** Unavailable, use -initWithTitle... instead */
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use -initWithTitle... instead")));

@end
