//
//  INAutocompletionResultsView.m
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAutocompletionResultsView.h"
#import "UIView+FrameAdditions.h"

#define ROW_HEIGHT 36

@implementation INAutocompletionResultsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, 0)];
		[_tableView setDelegate: self];
		[_tableView setDataSource: self];
		[self addSubview: _tableView];
		
		[[self layer] setShadowOffset: CGSizeMake(0, 3)];
		[[self layer] setShadowRadius: 2];
		[[self layer] setShadowOpacity: 0.3];
    }
    return self;
}

- (void)setProvider:(INModelProvider *)provider
{
	[_provider setDelegate: nil];
	_provider = provider;
	[_provider setDelegate: self];
	[_provider setItemRange:NSMakeRange(0, 3)];
	[_tableView reloadData];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame: frame];
	[_tableView setFrame: self.bounds];
	[[self layer] setShadowPath: CGPathCreateWithRect(self.bounds, NULL)];
}

#pragma mark Autocompletion

- (void)providerDataChanged:(INModelProvider*)provider
{
	[_tableView reloadData];
	
	CGRect worldFrame = [self convertRect:self.bounds toView:self.window];
	float worldMaxY = self.window.frame.size.height - 216;
	// todo: make this check if keyboard is actually onscreen
	
	float resultsHeight = [[_provider items] count] * ROW_HEIGHT;
	float availableHeight = worldMaxY - worldFrame.origin.y;
	float height = fminf(availableHeight, resultsHeight);
	[self setFrameHeight: height];
	[_tableView setScrollEnabled: (height < resultsHeight)];
}

- (void)providerDataFetchCompleted:(INModelProvider*)provider
{
	
}

- (void)provider:(INModelProvider*)provider dataFetchFailed:(NSError *)error
{
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_provider items] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ROW_HEIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	
	INContact * contact = [[_provider items] objectAtIndex: [indexPath row]];
	if ([[contact name] length])
		[[cell textLabel] setText: [NSString stringWithFormat:@"%@ (%@)", [contact name],[contact email]]];
	else
		[[cell textLabel] setText: [contact email]];
	[[cell textLabel] setFont: [UIFont systemFontOfSize: 14]];
	[[cell textLabel] setTextColor: [UIColor grayColor]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	INContact * contact = [[_provider items] objectAtIndex: [indexPath row]];
	if ([self.delegate respondsToSelector: @selector(autocompletionResultPicked:)])
		[self.delegate autocompletionResultPicked: contact];

	[self.tableView deselectRowAtIndexPath: indexPath animated:YES];
}

@end
