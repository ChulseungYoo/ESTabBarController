//
//  ESTabBarController.m
//  Pods
//
//  Created by Ezequiel Scaruli on 5/4/15.
//
//

#import "ESTabBarController.h"
#import "UIButton+ESTabBar.h"
#import "ESTabBarController+Autolayout.h"


@interface ESTabBarController ()

@property (nonatomic, weak) IBOutlet UIView *controllersContainer;
@property (nonatomic, weak) IBOutlet UIView *buttonsContainer;
@property (nonatomic, weak) IBOutlet UIView *separatorLine;

@property (nonatomic, strong) NSMutableDictionary *controllers;
@property (nonatomic, strong) NSMutableDictionary *actions;
@property (nonatomic, assign) BOOL didSetupInterface;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableSet *highlightedButtonIndexes;
@property (nonatomic, strong) NSArray *tabIcons;
@property (nonatomic, strong) UIView *selectionIndicator;
@property (nonatomic, strong) NSLayoutConstraint *selectionIndicatorLeadingConstraint;

@end


@implementation ESTabBarController


#pragma mark - Init


- (instancetype)initWithTabIcons:(NSArray *)tabIcons {
    self = [self initWithNibName:@"ESTabBarController" bundle:nil];
    
    if (self != nil) {
        [self initializeWithTabIcons:tabIcons];
    }
    
    return self;
}


- (instancetype)initWithTabIconNames:(NSArray *)tabIconNames {
    NSMutableArray *icons = [NSMutableArray array];
    
    for (NSString *name in tabIconNames) {
        [icons addObject:[UIImage imageNamed:name]];
    }
    
    return [self initWithTabIcons:icons];
}


#pragma mark - Getters / Setters


- (void)setSelectedColor:(UIColor *)selectedColor {
    if (_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
    }
    
    [self updateInterfaceIfNeeded];
    
    // Select the current button again to reflect the color change.
    UIButton *selectedButton = self.buttons[self.selectedIndex];
    selectedButton.selected = YES;
}


- (void)setSeparatorLineVisible:(BOOL)visible {
    if (_separatorLineVisible != visible) {
        _separatorLineVisible = visible;
    }
    
    [self setupSeparatorLine];
}


- (void)setSeparatorLineColor:(UIColor *)color {
    if (_separatorLineColor != color) {
        _separatorLineColor = color;
    }
    
    self.separatorLine.backgroundColor = color;
}


#pragma mark - UIViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupInterface];
    [self moveToControllerAtIndex:0 animated:NO];
}


#pragma mark - Public methods


- (void)setViewController:(UIViewController *)viewController
                  atIndex:(NSInteger)index {
    self.controllers[@(index)] = viewController;
}


- (void)setAction:(ESTabBarAction)action
          atIndex:(NSInteger)index {
    self.actions[@(index)] = action;
}


- (void)highlightButtonAtIndex:(NSInteger)index {
    [self.highlightedButtonIndexes addObject:@(index)];
    [self updateInterfaceIfNeeded];
}


#pragma mark - Action


- (void)tabButtonAction:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    
    if (index != NSNotFound) {
        // Show the selected view controller.
        [self moveToControllerAtIndex:index animated:YES];
        
        // Run the action if necessary.
        void (^action)(void) = self.actions[@(index)];
        if (action != nil) {
            action();
        }
    }
}


#pragma mark - Private methods


- (void)initializeWithTabIcons:(NSArray *)tabIcons {
    NSAssert(tabIcons.count > 0,
             @"The array of tab icons shouldn't be empty.");
    
    _tabIcons = tabIcons;
    
    self.controllers = [NSMutableDictionary dictionaryWithCapacity:tabIcons.count];
    self.actions = [NSMutableDictionary dictionaryWithCapacity:tabIcons.count];
    
    self.highlightedButtonIndexes = [NSMutableSet set];
    
    // No selected index at first.
    _selectedIndex = -1;
    
    self.separatorLineColor = [UIColor lightGrayColor];
}


- (void)updateInterfaceIfNeeded {
    if (self.didSetupInterface) {
        // If the UI was already setup, it's necessary to update it.
        [self setupInterface];
    }
}


- (void)setupInterface {
    [self setupButtons];
    [self setupSelectionIndicator];
    [self setupSeparatorLine];
    self.didSetupInterface = YES;
}


- (void)setupButtons {
    if (self.buttons == nil) {
        self.buttons = [NSMutableArray arrayWithCapacity:self.tabIcons.count];
        
        for (NSInteger i = 0; i < self.tabIcons.count; i++) {
            UIButton *button = [self createButtonForIndex:i];
            
            [self.buttonsContainer addSubview:button];
            self.buttons[i] = button;
        }
        
        [self setupButtonsConstraints];
    }
    
    [self customizeButtons];
    self.buttonsContainer.backgroundColor = self.buttonsBackgroundColor ?: [UIColor lightGrayColor];
}


- (UIButton *)createButtonForIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button addTarget:self
               action:@selector(tabButtonAction:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


- (void)customizeButtons {
    for (NSInteger i = 0; i < self.tabIcons.count; i++) {
        UIButton *button = self.buttons[i];
        
        BOOL isHighlighted = [self.highlightedButtonIndexes containsObject:@(i)];
        [button customizeForTabBarWithImage:self.tabIcons[i]
                              selectedColor:self.selectedColor ?: [UIColor blackColor]
                                highlighted:isHighlighted];

    }
}


- (void)moveToControllerAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.selectedIndex == index) {
        // Nothing to do.
        return;
    }
    
    // Deselect all the buttons excepting the selected one.
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        button.selected = (i == index);
    }
    
    UIViewController *controller = self.controllers[@(index)];
    
    if (controller != nil) {
        if (self.selectedIndex >= 0) {
            // Remove the current controller's view.
            UIViewController *currentController = self.controllers[@(self.selectedIndex)];
            [currentController.view removeFromSuperview];
        }
        
        if (![self.childViewControllers containsObject:controller]) {
            // If I haven't added the controller to the childs yet...
            [self addChildViewController:controller];
            [controller didMoveToParentViewController:self];
        }
        
        controller.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.controllersContainer addSubview:controller.view];
        [self setupConstraintsForChildController:controller];
        
        [self moveSelectionIndicatorToIndex:index animated:animated];
        
        _selectedIndex = index;
    }
}


- (void)setupSelectionIndicator {
    if (self.selectionIndicator == nil) {
        self.selectionIndicator = [[UIView alloc] init];
        self.selectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.buttonsContainer addSubview:self.selectionIndicator];
        
        [self setupSelectionIndicatorConstraints];
    }
    
    self.selectionIndicator.backgroundColor = self.selectedColor ?: [UIColor blackColor];
}


- (void)setupSeparatorLine {
    self.separatorLine.backgroundColor = self.separatorLineColor;
    self.separatorLine.hidden = !self.separatorLineVisible;
}


- (void)moveSelectionIndicatorToIndex:(NSInteger)index animated:(BOOL)animated {
    CGFloat constant = [self.buttons[index] frame].origin.x;
    
    [self.buttonsContainer layoutIfNeeded];
    void (^animations)(void) = ^{
        self.selectionIndicatorLeadingConstraint.constant = constant;
        [self.buttonsContainer layoutIfNeeded];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:animations
                         completion:nil];
    } else {
        animations();
    }
}


@end
