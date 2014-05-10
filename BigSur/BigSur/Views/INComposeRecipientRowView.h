//
//  INComposeRecipientsView.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INComposeRowView.h"
#import "INDeleteDetectingTextField.h"
#import "INAutocompletionResultsView.h"

@interface INComposeRecipientRowView : INComposeRowView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITextFieldDelegate, INAutocompletionResultsViewDelegate>
{
	INDeleteDetectingTextField * _textField;
}
@property (nonatomic, strong) NSMutableArray * recipients;
@property (nonatomic, strong) UICollectionView * recipientsCollectionView;
@property (nonatomic, strong) INAutocompletionResultsView * autocompletionView;

- (void)addRecipientFromContact:(INContact*)contact;

@end
