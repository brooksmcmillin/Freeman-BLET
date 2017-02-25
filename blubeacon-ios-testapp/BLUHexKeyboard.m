//
//  BLUHexKeyboard.m
//
//  Created by Matthias Bauch on 15/05/14.
//  Copyright (c) 2014 Matthias Bauch. All rights reserved.
//

#import "BLUHexKeyboard.h"
#import "BLUTableViewCell.h"

// these are tags that define the order of the 5 x 4 keys
typedef NS_ENUM(NSInteger, BLUHexKeyType) {
    BLUHexKeyA = 1000,
    BLUHexKeyB,
    BLUHexKey1,
    BLUHexKey2,
    BLUHexKey3,
    BLUHexKeyC,
    BLUHexKeyD,
    BLUHexKey4,
    BLUHexKey5,
    BLUHexKey6,
    BLUHexKeyE,
    BLUHexKeyF,
    BLUHexKey7,
    BLUHexKey8,
    BLUHexKey9,
    BLUHexKeyDecHex,
    BLUHexKeyNone,
    BLUHexKeyRandom,
    BLUHexKey0,
    BLUHexKeyClear
};

NSString * const BLUUDKeyHexModeEnabled = @"BLUUDKeyHexModeEnabled";
NSString * const BLUHexModeDidChangeNotification = @"BLUHexModeDidChangeNotification";


@interface BLUHexKeyboard ()
/*!
 the textField that we send our changes to
 */
@property (weak, nonatomic) UIResponder <UITextInput> *targetTextInput;

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation BLUHexKeyboard

- (id)contentForKeyType:(BLUHexKeyType)index {
    id content;
    switch (index) {
        case BLUHexKeyA:
            content = @"A";
            break;
        case BLUHexKeyB:
            content = @"B";
            break;
        case BLUHexKey1:
            content = @"1";
            break;
        case BLUHexKey2:
            content = @"2";
            break;
        case BLUHexKey3:
            content = @"3";
            break;
        case BLUHexKeyC:
            content = @"C";
            break;
        case BLUHexKeyD:
            content = @"D";
            break;
        case BLUHexKey4:
            content = @"4";
            break;
        case BLUHexKey5:
            content = @"5";
            break;
        case BLUHexKey6:
            content = @"6";
            break;
        case BLUHexKeyE:
            content = @"E";
            break;
        case BLUHexKeyF:
            content = @"F";
            break;
        case BLUHexKey7:
            content = @"7";
            break;
        case BLUHexKey8:
            content = @"8";
            break;
        case BLUHexKey9:
            content = @"9";
            break;
        case BLUHexKeyDecHex:
            if (self.mode == BLUHexKeyboardModeHexadecimal) {
                content = [[UIImage imageNamed:@"Hex"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            else {
                content = [[UIImage imageNamed:@"Dec"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            break;
        case BLUHexKeyNone: {
            content = @"";
            break;
        }
        case BLUHexKeyRandom: {
            UIImage *image = [[UIImage imageNamed:@"Random"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            NSString *text = @"Random";
            content = @{@"image" : image, @"text" : text};
            break;
        }
        case BLUHexKey0:
            content = @"0";
            break;
        case BLUHexKeyClear:
            content = [[UIImage imageNamed:@"Delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
    }
    NSAssert(content, @"Must have content");
    return content;
}

- (UIColor *)backgroundColorForKeyType:(BLUHexKeyType)type {
    UIColor *color = nil;
    switch (type) {
        case BLUHexKey0:
        case BLUHexKey1:
        case BLUHexKey2:
        case BLUHexKey3:
        case BLUHexKey4:
        case BLUHexKey5:
        case BLUHexKey6:
        case BLUHexKey7:
        case BLUHexKey8:
        case BLUHexKey9:
        case BLUHexKeyA:
        case BLUHexKeyB:
        case BLUHexKeyC:
        case BLUHexKeyD:
        case BLUHexKeyE:
        case BLUHexKeyF:
            color = [UIColor whiteColor];
//            color = [UIColor colorWithRed:0.42 green:0.42 blue:0.43 alpha:1];
            break;
        case BLUHexKeyDecHex:
        case BLUHexKeyNone:
        case BLUHexKeyRandom:
        case BLUHexKeyClear:
        default:
            color = [UIColor colorWithRed:0.73 green:0.75 blue:0.76 alpha:1];
//            color = [UIColor colorWithRed:0.27 green:0.27 blue:0.28 alpha:1];
            break;
    }
    return color;
}

- (void)commonInit {
    NSDictionary *userDefaultDefaults = @{ BLUUDKeyHexModeEnabled : @YES };
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultDefaults];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BLUUDKeyHexModeEnabled]) {
        _mode = BLUHexKeyboardModeHexadecimal;
    }
    else {
        _mode = BLUHexKeyboardModeDecimal;
    }
    
    _doesAllowModeSwitch = YES;
    
    NSMutableArray *keyButtons = [NSMutableArray arrayWithCapacity:5*4];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 5.0f;

    for (NSInteger row = 0; row < 4; row++) {
        for (NSInteger col = 0; col < 5; col++) {
            NSInteger i = row * 5 + col;

            //CGFloat width = 64.0f;
            CGFloat height = 54.0f;
            CGFloat borderWidth = 0.5f;
            UIColor *borderColor = [UIColor lightGrayColor];
            
            UIButton *lastButton = [keyButtons lastObject];
            if (col == 0) {
                x = 0;
                if  (row > 0) {
                    y = CGRectGetMaxY(lastButton.frame);
                }
            }
            else {
                NSAssert(lastButton, @"Must have lastbutton at this point");
                x = CGRectGetMaxX(lastButton.frame);
            }
            
            if (row == 0) {
                height = 54.0f;
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.tintColor = [UIColor blackColor];
            button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
            button.tag = 1000 + i;
            [keyButtons addObject:button];
            button.frame = CGRectMake(x, y, width, height);
            [self addSubview:button];
            
            button.backgroundColor = [self backgroundColorForKeyType:button.tag];
            [button addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
            id buttonContent = [self contentForKeyType:button.tag];
            [self configureButton:button withButtonContent:buttonContent];
            
            if (row != 0 && row != 3)
            {
                CALayer *topBorder = [CALayer layer];
                topBorder.frame = CGRectMake(0.0, 0.0, button.frame.size.width, borderWidth);
                topBorder.backgroundColor = borderColor.CGColor;
                [button.layer addSublayer:topBorder];
            }
            if (col == 3 && row == 2)
            {
                CALayer *bottomBorder = [CALayer layer];
                bottomBorder.frame = CGRectMake(0.0, button.frame.size.height - borderWidth, button.frame.size.width, borderWidth);
                bottomBorder.backgroundColor = borderColor.CGColor;
                [button.layer addSublayer:bottomBorder];
            }
            if (col != 4)
            {  
                CALayer *rightBorder = [CALayer layer];
                rightBorder.frame = CGRectMake(button.frame.size.width - borderWidth, 0.0f, borderWidth, button.frame.size.height);
                rightBorder.backgroundColor = borderColor.CGColor;
                [button.layer addSublayer:rightBorder];
            }
        }
    }
    
    // disable hex keys if necessary
    [self configureView];
    
    UILongPressGestureRecognizer *clearLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(clearLongPressed:)];
    UIButton *clearButton = (UIButton *)[self viewWithTag:BLUHexKeyClear];
    [clearButton addGestureRecognizer:clearLongPressGesture];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegin:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegin:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidEnd:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidEnd:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)configureButton:(UIButton *)button withButtonContent:(id)buttonContent {
    button.titleEdgeInsets = UIEdgeInsetsZero;
    button.imageEdgeInsets = UIEdgeInsetsZero;
    [button setTitle:nil forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateNormal];

    if ([buttonContent isKindOfClass:[NSString class]]) {
        [button setTitle:buttonContent forState:UIControlStateNormal];
    }
    else if ([buttonContent isKindOfClass:[UIImage class]]) {
        [button setImage:buttonContent forState:UIControlStateNormal];
    }
    else if ([buttonContent isKindOfClass:[NSDictionary class]]) {
        UIImage *image = buttonContent[@"image"];
        NSString *text = buttonContent[@"text"];
        [button setTitle:text forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        
        CGFloat spacing = 10.0;
        CGSize imageSize = button.imageView.frame.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (22 + spacing), 0.0);
        CGSize titleSize = button.titleLabel.frame.size;
        button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height), 0.0, 0.0, - titleSize.width);
    }
}

+ (instancetype)keyboardWithDelegate:(id<BLUHexKeyboardDelegate>)delegate {
    BLUHexKeyboard *keyboard = [[BLUHexKeyboard alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    keyboard.delegate = delegate;
    return keyboard;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)setDoesAllowModeSwitch:(BOOL)doesAllowModeSwitch {
    _doesAllowModeSwitch = doesAllowModeSwitch;
    [self configureView];
}

- (void)setMode:(BLUHexKeyboardMode)mode {
    _mode = mode;
    [self configureView];
}

- (void)editingDidBegin:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UITextView class]]) {
        UITextView *textView = notification.object;
        if (textView.inputView == self) {
            self.targetTextInput = textView;
            return;
        }
    }
    else if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = notification.object;
        if (textField.inputView == self) {
            self.targetTextInput = textField;
            return;
        }
    }
    self.targetTextInput = nil;
}

- (void)editingDidEnd:(NSNotification *)notification {
    if (notification.object == self.targetTextInput) {
        self.targetTextInput = nil;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (IBAction)didPressButton:(UIButton *)sender {
    if (sender.tag == BLUHexKeyClear) {
        UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
        if ([selectedTextRange isEmpty]) {
            // no text selected. remove last character
            UITextPosition *afterLastCharacterPosition = selectedTextRange.start;
            UITextPosition *lastCharacterPosition = [self.targetTextInput positionFromPosition:afterLastCharacterPosition offset:-1];
            selectedTextRange = [self.targetTextInput textRangeFromPosition:lastCharacterPosition toPosition:afterLastCharacterPosition];
        }
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@""];
    }
    else if (sender.tag == BLUHexKeyDecHex) {
        BLUHexKeyboardMode previousMode = self.mode;
        if (self.mode == BLUHexKeyboardModeDecimal) {
            self.mode = BLUHexKeyboardModeHexadecimal;
        }
        else {
            self.mode = BLUHexKeyboardModeDecimal;
        }
        [self configureView];
        
        if ([self.delegate respondsToSelector:@selector(hexKeyboard:didSwitchToKeyboardMode:oldMode:)]) {
            [self.delegate hexKeyboard:self didSwitchToKeyboardMode:self.mode oldMode:previousMode];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:BLUHexModeDidChangeNotification object:self userInfo:@{@"newMode" : @(self.mode)}];
        [[NSUserDefaults standardUserDefaults] setBool:(BOOL)(self.mode == BLUHexKeyboardModeHexadecimal) forKey:BLUUDKeyHexModeEnabled];
    }
    else if (sender.tag == BLUHexKeyRandom) {
        if ([self.delegate respondsToSelector:@selector(hexKeyboardDidTapRandomButton:)]) {
            [self.delegate hexKeyboardDidTapRandomButton:self];
        }
    }
    else if (sender.tag == BLUHexKeyNone) {

    }
    else {
        NSString *numberPressed  = [sender titleForState:UIControlStateNormal];
        if ([numberPressed length] > 0) {
            UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
            if (selectedTextRange) {
                [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:numberPressed];
            }
        }
    }
}

- (IBAction)clearLongPressed:(UILongPressGestureRecognizer *)sender {
    if (self.targetTextInput) {
        if ([self.targetTextInput isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.targetTextInput;
            textView.text = @"";
        }
        else if ([self.targetTextInput isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.targetTextInput;
            textField.text = @"";
        }
        else {
        }
    }
}

// Check delegate methods to see if we should change the characters in range
- (BOOL)textInput:(id <UITextInput>)textInput shouldChangeCharactersInRange:(NSRange)range withString:(NSString *)string {
    if (textInput) {
        if ([textInput isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)textInput;
            if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                if ([textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        } else if ([textInput isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)textInput;
            if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                if ([textView.delegate textView:textView shouldChangeTextInRange:range replacementText:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        }
    }
    return NO;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(id <UITextInput>)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string {
    if (textInput) {
        if (textRange) {
            // Calculate the NSRange for the textInput text in the UITextRange textRange:
            NSInteger startPos = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.start];
            NSInteger length = [textInput offsetFromPosition:textRange.start toPosition:textRange.end];
            NSRange selectedRange = NSMakeRange(startPos, length);
            
            if ([self textInput:textInput shouldChangeCharactersInRange:selectedRange withString:string]) {
                // Make the replacement:
                [textInput replaceRange:textRange withText:string];
            }
        }
    }
}

- (void)configureView {
    NSInteger tags[] = { BLUHexKeyA, BLUHexKeyB, BLUHexKeyC, BLUHexKeyD, BLUHexKeyE, BLUHexKeyF };
    BOOL hexEnabled = (self.mode == BLUHexKeyboardModeHexadecimal);
    for (NSInteger i = 0; i < 6; i++) {
        NSInteger tag = tags[i];
        UIButton *button = (UIButton *)[self viewWithTag:tag];
        NSAssert(button, @"Must have button");
        button.enabled = hexEnabled;
    }

    UIButton *hexDecButton = (UIButton *)[self viewWithTag:BLUHexKeyDecHex];
    if (self.doesAllowModeSwitch) {
        hexDecButton.enabled = YES;

        id buttonContent = [self contentForKeyType:BLUHexKeyDecHex];
        [self configureButton:hexDecButton withButtonContent:buttonContent];
    }
    else {
        hexDecButton.enabled = NO;
        [self configureButton:hexDecButton withButtonContent:nil];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self configureView];
}

@end
