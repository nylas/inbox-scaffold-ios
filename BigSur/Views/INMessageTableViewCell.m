//
//  INDraftTableViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageTableViewCell.h"
#import "INConvenienceCategories.h"

@implementation INMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier: reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setMessage:(INMessage *)message
{
    _message = message;

	NSMutableArray * addresses = [NSMutableArray array];
    [addresses addObjectsFromArray: [_message to]];
	[self.participantsLabel setPrefixString: @"" andRecipients:addresses includeMe: YES];
	[self.dateLabel setText: [NSString stringForMessageDate: [_message date]]];
    [self.bodyLabel setText: [NSString stringByCleaningWhitespaceInString: [_message body]]];
	if ([[_message subject] length] > 0)
		[self.subjectLabel setText: [_message subject]];
	else
		[self.subjectLabel setText: @"(no subject)"];
}

@end
