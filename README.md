# LGActionSheet

Customizable implementation of UIActionSheet.

## Preview

<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGActionSheet/Preview.gif" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGActionSheet/1.png" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGActionSheet/2.png" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGActionSheet/3.png" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGActionSheet/4.png" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGActionSheet/5.png" width="230"/>

## Installation

### With source code

[Download repository](https://github.com/Friend-LGA/LGActionSheet/archive/master.zip), then add [LGActionSheet directory](https://github.com/Friend-LGA/LGActionSheet/blob/master/LGActionSheet/) to your project.

### With CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the "Get Started" section for more details.

#### Podfile

```
platform :ios, '6.0'
pod 'LGActionSheet', '~> 1.0.0'
```

## Usage

In the source files where you need to use the library, import the header file:

```objective-c
#import "LGActionSheet.h"
```

### Initialization

You have several methods for initialization:

```objective-c
- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle;

- (instancetype)initWithTitle:(NSString *)title
                         view:(UIView *)view
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle;
```

More init methods you can find in [LGActionSheet.h](https://github.com/Friend-LGA/LGActionSheet/blob/master/LGActionSheet/LGActionSheet.h)

### Handle actions

To handle actions you can use initialization methods with blocks or delegate, or implement it after initialization.

#### Delegate

```objective-c
@property (assign, nonatomic) id<LGActionSheetDelegate> delegate;

- (void)actionSheetWillShow:(LGActionSheet *)actionSheet;
- (void)actionSheetWillDismiss:(LGActionSheet *)actionSheet;
- (void)actionSheetDidShow:(LGActionSheet *)actionSheet;
- (void)actionSheetDidDismiss:(LGActionSheet *)actionSheet;
- (void)actionSheet:(LGActionSheet *)actionSheet buttonPressedWithTitle:(NSString *)title index:(NSUInteger)index;
- (void)actionSheetCancelled:(LGActionSheet *)actionSheet;
- (void)actionSheetDestructiveButtonPressed:(LGActionSheet *)actionSheet;
```

#### Blocks

```objective-c
@property (strong, nonatomic) void (^willShowHandler)(LGActionSheet *actionSheet);
@property (strong, nonatomic) void (^willDismissHandler)(LGActionSheet *actionSheet);
@property (strong, nonatomic) void (^didShowHandler)(LGActionSheet *actionSheet);
@property (strong, nonatomic) void (^didDismissHandler)(LGActionSheet *actionSheet);
@property (strong, nonatomic) void (^actionHandler)(LGActionSheet *actionSheet, NSString *title, NSUInteger index);
@property (strong, nonatomic) void (^cancelHandler)(LGActionSheet *actionSheet, BOOL onButton);
@property (strong, nonatomic) void (^destructiveHandler)(LGActionSheet *actionSheet);
```

#### Notifications

Here is also some notifications, that you can add to NSNotificationsCenter:

```objective-c
kLGActionSheetWillShowNotification;
kLGActionSheetWillDismissNotification;
kLGActionSheetDidShowNotification;
kLGActionSheetDidDismissNotification;
```

### More

For more details try Xcode [Demo project](https://github.com/Friend-LGA/LGActionSheet/blob/master/Demo) and see [LGActionSheet.h](https://github.com/Friend-LGA/LGActionSheet/blob/master/LGActionSheet/LGActionSheet.h)

## License

LGActionSheet is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/Friend-LGA/LGActionSheet/master/LICENSE) for details.
