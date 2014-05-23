//
//  INComposeRecipientsView.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeRecipientRowView.h"
#import "INLeftJustifiedFlowLayout.h"
#import "INComposeRecipientCollectionViewCell.h"
#import "UIView+FrameAdditions.h"
#import "INAppDelegate.h"


@interface INIntrinsicallySizedCollectionView : UICollectionView
@end

@implementation INIntrinsicallySizedCollectionView

- (CGSize)intrinsicContentSize
{
	return CGSizeMake(UIViewNoIntrinsicMetric, [[self collectionViewLayout] collectionViewContentSize].height);
}

@end


@implementation INComposeRecipientRowView

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
		[self.actionButton setImage: [UIImage imageNamed: @"icon_add_recipient.png"] forState:UIControlStateNormal];
		[self setClipsToBounds: NO];
		
		UICollectionViewFlowLayout * layout = [[INLeftJustifiedFlowLayout alloc] init];
		[layout setScrollDirection: UICollectionViewScrollDirectionVertical];
		[layout setSectionInset: UIEdgeInsetsMake(1,1,1,1)];
		[layout setMinimumInteritemSpacing: 5];
		[layout setMinimumLineSpacing: 0]; // causes layout issue unless 0
		
		_recipientsCollectionView = [[INIntrinsicallySizedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		[_recipientsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"textfield"];
		[_recipientsCollectionView registerClass:[INComposeRecipientCollectionViewCell class] forCellWithReuseIdentifier:@"token"];
		[_recipientsCollectionView setDelegate: self];
		[_recipientsCollectionView setDataSource: self];
		[_recipientsCollectionView setScrollEnabled: NO];
		[_recipientsCollectionView setBackgroundColor: [UIColor whiteColor]];
		_recipientsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview: _recipientsCollectionView];
		self.bodyView = _recipientsCollectionView;

		_autocompletionView = [[INAutocompletionResultsView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, 0)];
		[_autocompletionView setDelegate: self];
		
		typeof(self) __weak __self = self;
		_textField = [[INDeleteDetectingTextField alloc] initWithFrame: CGRectZero];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:_textField];
		[_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[_textField setAutocapitalizationType: UITextAutocapitalizationTypeNone];
		[_textField setAutocorrectionType: UITextAutocorrectionTypeNo];
		[_textField setDidDeleteBlock: ^(void){
			if ([__self selectedRecipient])
				[__self deleteRecipient: [__self selectedRecipient]];
			else
				[__self selectRecipient: [__self.recipients lastObject]];
		}];
		[_textField setDelegate: self];
		[_textField setFont: INComposeRecipientFont];

		UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTextField:)];
		[tapRecognizer setDelegate: self];
		[_recipientsCollectionView addGestureRecognizer: tapRecognizer];

		_recipients = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)updateConstraints
{
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(7)-[body]-(7)-|" options:0 metrics:nil views: @{@"body": _recipientsCollectionView}]];
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(14)-[label]" options:NSLayoutFormatAlignAllBaseline metrics:nil views: @{@"label": self.rowLabel, @"action":self.actionButton}]];
	[super updateConstraints];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect frame = [self convertRect:[self bounds] toView:[self superview]];
	[_autocompletionView setFrameOrigin: CGPointMake(0, frame.origin.y + frame.size.height)];
}

- (void)propogateConstraintChanges
{
	[[_recipientsCollectionView collectionViewLayout] invalidateLayout];
	[_recipientsCollectionView invalidateIntrinsicContentSize];
}

- (id)selectedRecipient
{
	NSIndexPath * path = [[_recipientsCollectionView indexPathsForSelectedItems] firstObject];
	if (!path)
		return nil;
	return [_recipients objectAtIndex: [path row]];
}

- (void)selectRecipient:(id)recipient
{
	NSUInteger index = [_recipients indexOfObjectIdenticalTo: recipient];
	[_recipientsCollectionView deselectItemAtIndexPath:[[_recipientsCollectionView indexPathsForSelectedItems] firstObject] animated:NO];
	[_recipientsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)deleteRecipient:(id)recipient
{
	NSUInteger index = [_recipients indexOfObjectIdenticalTo: recipient];
	[_recipients removeObjectAtIndex: index];
	[_recipientsCollectionView deleteItemsAtIndexPaths: @[[NSIndexPath indexPathForItem:index inSection:0]]];
	[self propogateConstraintChanges];
	
	if ([_recipients count] > 0)
		[self selectRecipient: [_recipients objectAtIndex: fminf(index, [_recipients count] - 1)]];
	else
		[_textField showInsertionPoint];
}

- (BOOL)containsInvalidRecipients
{
	[self addRecipientFromTextField];
	return ([[_textField text] length] > 0);
}

- (void)selectTextField:(UITapGestureRecognizer*)recognizer
{
	// necessary logic is in gestureRecognizerShouldBegin:, because this method doesn't get
	// invoked if the touch is caught by the textField after gestureRecognizerShouldBegin:
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_recipients count] + 1;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[_textField hideInsertionPoint];
	return YES;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] < [_recipients count]) {
		INComposeRecipientCollectionViewCell * cell = (INComposeRecipientCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"token" forIndexPath:indexPath];
		[cell setRecipient: _recipients[[indexPath row]]];
		return cell;

	} else {
		UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"textfield" forIndexPath:indexPath];
		if (![_textField superview]) {
			[[collectionView collectionViewLayout] invalidateLayout];
		}
		[cell addSubview: _textField];
		return cell;
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	float rowHeight = 24 + INComposeRecipientVPadding * 2;
	
	if ([indexPath row] < [_recipients count]) {
		NSDictionary * recipient = [_recipients objectAtIndex: [indexPath row]];
		CGSize textSize = [recipient[@"name"] sizeWithAttributes: @{NSFontAttributeName: INComposeRecipientFont}];
		float size = fminf(textSize.width + 8 * 2 + 24, _recipientsCollectionView.frame.size.width - 8);
		return CGSizeMake(size, rowHeight);

	} else {
		CGSize textSize = [[_textField text] sizeWithAttributes: @{NSFontAttributeName: INComposeRecipientFont}];
		float size = fminf(textSize.width + 20, _recipientsCollectionView.frame.size.width - 8);
		[_textField setFrameSize: CGSizeMake(size, rowHeight)];
		[collectionView invalidateIntrinsicContentSize];
		return CGSizeMake(size, rowHeight);
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString * newString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
	
	NSIndexPath * selectedIndexPath = [[_recipientsCollectionView indexPathsForSelectedItems] firstObject];
	[_recipientsCollectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
	
	if ([string rangeOfString: @","].location != NSNotFound) {
		NSMutableArray * newTokens = [[newString componentsSeparatedByString: @","] mutableCopy];
		[_textField setText: @""];
		
        for (int ii = (int)[newTokens count] - 1; ii >= 0; ii --) {
            if ([self addRecipientFromText: [newTokens objectAtIndex: ii]])
                [newTokens removeObjectAtIndex: ii];
        }
        [_textField setText: [newTokens componentsJoinedByString:@","]];
        [self propogateConstraintChanges];
		return NO;
	}
	return YES;
}

- (void)textFieldTextDidChange:(NSNotification*)notif
{
	[self propogateConstraintChanges];
	[self updateAutocompletionQuery: [_textField text]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self addRecipientFromTextField];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSIndexPath * selectedIndexPath = [[_recipientsCollectionView indexPathsForSelectedItems] firstObject];
	[_recipientsCollectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
	[self updateAutocompletionQuery: @""];
	
	[self addRecipientFromTextField];
}

- (void)addRecipientFromTextField
{
    if ([self addRecipientFromText: _textField.text])
        [_textField setText: @""];
}

- (void)addRecipients:(NSObject<NSFastEnumeration>*)recipients
{
	for (id recipient in recipients)
	    [self addRecipientWithName:[recipient valueForKey: @"name"] andEmail:[recipient valueForKey: @"email"]];
}

- (void)addRecipientFromContact:(INContact*)contact
{
    [self addRecipientWithName:contact.name andEmail:contact.email];
}

- (BOOL)addRecipientFromText:(NSString*)text
{
	text = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([text length] == 0)
		return NO;

    INContact __block * contact = nil;
    [[INDatabaseManager shared] selectModelsOfClassSync:[INContact class] withQuery:@"SELECT * FROM INContact WHERE email = :text OR name = :text" andParameters:@{@"text":text} andCallback:^(NSArray *objects) {
        contact = (INContact *)[objects firstObject];
    }];

	NSRegularExpression * emailRegexp = [NSRegularExpression regularExpressionWithPattern: @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * emails = [emailRegexp matchesInString: text options: 0 range:NSMakeRange(0, [text length])];
    
    if ([emails count]) {
		NSString * email = [text substringWithRange: [[emails firstObject] range]];
        [self addRecipientWithName:email andEmail: email];
        return YES;

    } else if (contact) {
        [self addRecipientWithName:contact.name andEmail:contact.email];
        return YES;

    } else {
        // do nothing. This is invalid input!
        return NO;
    }
}

- (void)addRecipientWithName:(NSString*)name andEmail:(NSString*)email
{
	email = [email stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([email length] == 0)
		return;
	
	name = [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([name length] == 0)
		name = email;
		
	[CATransaction begin];
	[CATransaction setDisableActions: YES];
	[_recipientsCollectionView performBatchUpdates:^{
		NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[_recipients count] inSection:0];
		[_recipients addObject: @{@"name": name, @"email": email}];
		[_recipientsCollectionView insertItemsAtIndexPaths: @[indexPath]];
	} completion:NULL];
	[CATransaction commit];
    
	[self propogateConstraintChanges];
	[self updateAutocompletionQuery: nil];
}

#pragma Tap Recognizer for Selecting Text Field

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	[_textField becomeFirstResponder];
	
	CGPoint p = [gestureRecognizer locationInView: _recipientsCollectionView];
	BOOL selectedNoCell = ([_recipientsCollectionView indexPathForItemAtPoint: p] == nil);
	BOOL selectedTextCell = ([[_recipientsCollectionView indexPathForItemAtPoint: p] row] == [_recipients count]);
	
	if (selectedNoCell || selectedTextCell) {
		NSIndexPath * selectedIndexPath = [[_recipientsCollectionView indexPathsForSelectedItems] firstObject];
		[_recipientsCollectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];

		[_textField showInsertionPoint];
		[_textField becomeFirstResponder];
	}
	
	return NO;
}

#pragma mark Autocompletion

- (void)updateAutocompletionQuery:(NSString*)typedText
{
	if ([typedText length] < 3) {
		[_autocompletionView removeFromSuperview];
		_autocompletionView.provider = nil;
		
	} else {
		if (!_autocompletionView.provider) {
            INNamespace * namespace = [[INAppDelegate current] currentNamespace];
			INModelProvider * provider = [namespace newContactProvider];
			[_autocompletionView setProvider: provider];
		}
		NSPredicate * namePredicate = [NSComparisonPredicate predicateWithFormat: @"name BEGINSWITH %@", typedText];
        NSPredicate * emailPredicate = [NSComparisonPredicate predicateWithFormat: @"email BEGINSWITH %@", typedText];
        [_autocompletionView.provider setItemFilterPredicate: [NSCompoundPredicate orPredicateWithSubpredicates: @[namePredicate, emailPredicate]]];
		[self.superview addSubview: _autocompletionView];
	}
}

- (void)autocompletionResultPicked:(id)item
{
	[self addRecipientFromContact: item];
    [_textField setText: @""];
}

@end
