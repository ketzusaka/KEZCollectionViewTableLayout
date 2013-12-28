//
//  KZLabeledHeaderView.m
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/22/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KZLabeledHeaderView.h"

@interface KZLabeledHeaderView ()
@property (nonatomic, strong, readwrite) UILabel *label;
@end

@implementation KZLabeledHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor cyanColor];
      self.label.backgroundColor = [UIColor cyanColor];
      [self addSubview:self.label];
    }
    return self;
}

- (void) prepareForReuse {
  [super prepareForReuse];
  self.label.text = nil;
}

- (void) updateConstraints {
  NSDictionary *views = @{@"label": self.label};
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"|[label]|"
                        options:0
                        metrics:nil
                        views:views]];
  
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|[label]|"
                        options:0
                        metrics:nil
                        views:views]];
  [super updateConstraints];
}

- (UILabel *) label {
  if (!_label) {
    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:13.0f];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.textAlignment = NSTextAlignmentCenter;
  }
  
  return _label;
}
@end
