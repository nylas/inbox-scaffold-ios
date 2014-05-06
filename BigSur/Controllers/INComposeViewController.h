//
//  INComposeViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INThread.h"
#import "INComposeRecipientRowView.h"
#import "INComposeSubjectRowView.h"

@interface INComposeViewController : UIViewController

@property (nonatomic, strong) INThread * thread;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) NSMutableArray *scrollViewRows;
@property (strong, nonatomic) UITextView * bodyTextView;
@property (strong, nonatomic) INComposeRecipientRowView * toRecipientsView;
@property (strong, nonatomic) INComposeRecipientRowView * ccBccRecipientsView;
@property (strong, nonatomic) INComposeSubjectRowView * subjectView;

- (id)initWithThread:(INThread*)thread;

@end
