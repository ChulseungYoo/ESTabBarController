//
//  ESTabBarController+Autolayout.m
//  Pods
//
//  Created by Ezequiel Scaruli on 5/5/15.
//
//

#import "ESTabBarController+Autolayout.h"


@interface ESTabBarController ()

@property (nonatomic, weak) UIView *controllersContainer;
@property (nonatomic, weak) UIView *buttonsContainer;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, assign) NSArray *tabIcons;
@property (nonatomic, strong) UIView *selectionIndicator;
@property (nonatomic, strong) NSLayoutConstraint *selectionIndicatorLeadingConstraint;
@property (nonatomic, assign) CGFloat buttonsContainerHeightConstraintInitialConstant;
@property (nonatomic, strong) NSLayoutConstraint *selectionIndicatorHeightConstraint;

@end


@implementation ESTabBarController (Autolayout)


#pragma mark - Public methods


- (void)setupButtonsConstraints {
    for (NSInteger i = 0; i < self.tabIcons.count; i++) {
        [self.buttons[i] setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.view addConstraints:[self leftLayoutConstraintsForButtonAtIndex:i]];
        [self.view addConstraints:[self verticalLayoutConstraintsForButtonAtIndex:i]];
        [self.view addConstraint:[self widthLayoutConstraintForButtonAtIndex:i]];
        [self.view addConstraint:[self heightLayoutConstraintForButtonAtIndex:i]];
    }
}


- (void)setupSelectionIndicatorConstraints {
    self.selectionIndicatorLeadingConstraint = [self leadingLayoutConstraintForIndicator];
    
    [self.buttonsContainer addConstraint:self.selectionIndicatorLeadingConstraint];
    [self.buttonsContainer addConstraints:[self widthLayoutConstraintsForIndicator]];
    [self.buttonsContainer addConstraints:[self heightLayoutConstraintsForIndicator]];
    //  [self.view addConstraints:[self topLayoutConstraintsForIndicator]];
}


- (void)setupConstraintsForChildController:(UIViewController *)controller {
    NSDictionary *views = @{@"view": controller.view};
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views];
    [self.controllersContainer addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
    [self.controllersContainer addConstraints:verticalConstraints];
}


#pragma mark - Private methods


- (NSArray *)leftLayoutConstraintsForButtonAtIndex:(NSInteger)index {
    UIButton *button = self.buttons[index];
    NSArray *leftConstraints;
    // First button. Stick it to its left margin.
    leftConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[button]"
                                                              options:0
                                                              metrics:nil
                                                                views:@{@"button": button}];
    return leftConstraints;
}


- (NSArray *)verticalLayoutConstraintsForButtonAtIndex:(NSInteger)index {
    UIButton *button = self.buttons[index];
    NSArray *upperConstraints;
    if (index == 0) {
        upperConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[button]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:@{@"button": button}];
    } else {
        NSDictionary *views = @{@"previousButton": self.buttons[index - 1],
                                @"button": button};
        
        // Stick the button to the previous one.
        upperConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousButton]-(0)-[button]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    }
    // The button is sticked to its top and bottom margins.
    return upperConstraints;
}


- (NSLayoutConstraint *)widthLayoutConstraintForButtonAtIndex:(NSInteger)index {
    UIButton *button = self.buttons[index];
    
    return [NSLayoutConstraint constraintWithItem:button
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.buttonsContainer
                                        attribute:NSLayoutAttributeWidth
                                       multiplier:1.0
                                         constant:0.0];
}


- (NSLayoutConstraint *)heightLayoutConstraintForButtonAtIndex:(NSInteger)index {
    UIButton *button = self.buttons[index];
    
    return [NSLayoutConstraint constraintWithItem:button
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.buttonsContainer
                                        attribute:NSLayoutAttributeHeight
                                       multiplier:0.1
                                         constant:0.0];
}


- (NSLayoutConstraint *)leadingLayoutConstraintForIndicator {
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[selectionIndicator]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:@{@"selectionIndicator": self.selectionIndicator}];
    
    return [constraints firstObject];
}


- (NSArray *)widthLayoutConstraintsForIndicator {
    NSDictionary *views = @{@"button": self.buttons[0],
                            @"selectionIndicator": self.selectionIndicator};
    
    return [NSLayoutConstraint constraintsWithVisualFormat:@"[selectionIndicator(==button)]"
                                                   options:0
                                                   metrics:nil
                                                     views:views];
}


- (NSArray *)heightLayoutConstraintsForIndicator {
    NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[selectionIndicator(==3)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:@{@"selectionIndicator": self.selectionIndicator}];
    self.selectionIndicatorHeightConstraint = [heightConstraints firstObject];
    
    return heightConstraints;
}


- (NSArray *)topLayoutConstraintsForIndicator {
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[buttonsContainer]"
                                                   options:0
                                                   metrics:nil
                                                     views:@{@"buttonsContainer": self.buttonsContainer}];
}



@end
