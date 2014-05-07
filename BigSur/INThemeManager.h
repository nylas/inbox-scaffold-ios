////
////  CWThemeManager.h
////  Crossly
////
////  Created by Demetri Miller on 4/17/13.
////  Copyright (c) 2013 Demetri Miller. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
////#import "CWTheme.h"
//
//extern NSString * const CWThemeChangedNotification;
//
//// *******************************
//// Fonts
//// *******************************
//extern const struct Font {
//    __unsafe_unretained NSString * pencil;
//    __unsafe_unretained NSString * pen;
//    __unsafe_unretained NSString * clueNumber;
//    __unsafe_unretained NSString * peek;
//    __unsafe_unretained NSString * peekIconLarge;
//    
//    __unsafe_unretained NSString * popupRegular;
//    __unsafe_unretained NSString * popupBold;
//    __unsafe_unretained NSString * popupGameOverPlayer;
//    __unsafe_unretained NSString * popupGameOverScore;
//    __unsafe_unretained NSString * popupPeeksEarned;
//    
//    __unsafe_unretained NSString * optionsPopupTitle;
//    __unsafe_unretained NSString * optionsPopupButton;
//    
//    __unsafe_unretained NSString * alertTitle;
//    __unsafe_unretained NSString * alertMessage;
//    __unsafe_unretained NSString * alertAction;
//    __unsafe_unretained NSString * alertCancel;
//    
//    __unsafe_unretained NSString * tauntStatusLabel;
//    __unsafe_unretained NSString * tauntPromptLabel;
//    __unsafe_unretained NSString * tauntCancel;
//    __unsafe_unretained NSString * tauntSend;
//    __unsafe_unretained NSString * tauntRetake;
//    
//    __unsafe_unretained NSString * clueListNumber;
//    __unsafe_unretained NSString * clueListLabel;
//    
//    __unsafe_unretained NSString * gameListPlayer;
//    __unsafe_unretained NSString * gameListScore;
//    __unsafe_unretained NSString * gameListSectionHeader;
//    __unsafe_unretained NSString * gameListPlayerTurn;
//    __unsafe_unretained NSString * gameListPlayerTurnBold;
//    __unsafe_unretained NSString * gameListAdvertisement;
//    __unsafe_unretained NSString * gameListPlayerHeader;
//    
//    __unsafe_unretained NSString * headerScoreLarge;
//    __unsafe_unretained NSString * headerScoreSmall;
//    __unsafe_unretained NSString * headerScoreCounter;
//    
//    __unsafe_unretained NSString * keyboardBarClueNumber;
//    __unsafe_unretained NSString * keyboardBarClueLabel;
//    __unsafe_unretained NSString * keyboardKeyZoomCharacter;
//    
//    __unsafe_unretained NSString * buyPeekQuantity;
//    __unsafe_unretained NSString * buyPeekPrice;
//    
//    __unsafe_unretained NSString * submitButton;
//    __unsafe_unretained NSString * navDoneButton;
//
//    __unsafe_unretained NSString * settingsListLabel;
//    __unsafe_unretained NSString * settingsListDescription;
//    __unsafe_unretained NSString * settingsHeader;
//    __unsafe_unretained NSString * settingsBody;
//    __unsafe_unretained NSString * settingsPremiumPay;
//    __unsafe_unretained NSString * settingsAboutHeader;
//    __unsafe_unretained NSString * settingsNavHeader;
//    
//    __unsafe_unretained NSString * logo;
//} Font;
//
//
//// *******************************
//// Main Colors
//// *******************************
//extern const struct Main {
//    __unsafe_unretained NSString * headerBackground;
//    
//    __unsafe_unretained NSString * tint;
//    
//    __unsafe_unretained NSString * localCorrect;
//    __unsafe_unretained NSString * localSteal;
//    __unsafe_unretained NSString * opponentCorrect;
//    __unsafe_unretained NSString * opponentSteal;
//    __unsafe_unretained NSString * opponentSelected;
//    __unsafe_unretained NSString * limbo;
//    __unsafe_unretained NSString * limboSelected;
//    
//    __unsafe_unretained NSString * popupBackground;
//    __unsafe_unretained NSString * popupButtonDivider;
//    __unsafe_unretained NSString * popupButtonSelected;
//    
//    __unsafe_unretained NSString * puzzleBackground;
//    __unsafe_unretained NSString * puzzleGridDivider;
//    __unsafe_unretained NSString * puzzleEmptyBlock;
//    __unsafe_unretained NSString * puzzleSelectedClueShadow;
//    __unsafe_unretained NSString * puzzleBlurTintColor;
//    
//    __unsafe_unretained NSString * marchingAntsPrimary;
//    __unsafe_unretained NSString * marchingAntsSecondary;
//    
//    __unsafe_unretained NSString * submitButtonDisabled;
//    
//    __unsafe_unretained NSString * keyboardBackground;
//    __unsafe_unretained NSString * keyboardKeyBackground;
//    __unsafe_unretained NSString * keyboardKeyShadow;
//    __unsafe_unretained NSString * keyboardDeleteKeyBackground;
//    __unsafe_unretained NSString * keyboardDeleteKeyShadow;
//    __unsafe_unretained NSString * keyboardPeekKeyDepressed;
//    
//    __unsafe_unretained NSString * settingsPremiumCheckboxBorder;
//    __unsafe_unretained NSString * settingsIcons;
//    __unsafe_unretained NSString * settingsIconsTheme;
//    __unsafe_unretained NSString * settingsListDivider;
//    
//    __unsafe_unretained NSString * gameListBackground;
//    __unsafe_unretained NSString * gameListHeaderDivider;
//    __unsafe_unretained NSString * gameListDivider;
//    __unsafe_unretained NSString * gameListCellSelectedBackground;
//    __unsafe_unretained NSString * gameListRefresh;
//} Main;
//
//
//// *******************************
//// Text Colors
//// *******************************
//extern const struct TextColor {
//    __unsafe_unretained NSString * selected;
//    __unsafe_unretained NSString * pencil;
//    __unsafe_unretained NSString * pen;
//    __unsafe_unretained NSString * limbo;
//    
//    __unsafe_unretained NSString * popupRegular;
//    __unsafe_unretained NSString * popupWrong;
//    __unsafe_unretained NSString * popupPeekError;
//    
//    __unsafe_unretained NSString * optionsPopupDisabled;
//    __unsafe_unretained NSString * optionsPopupCancel;
//
//    __unsafe_unretained NSString * tauntRetake;
//    __unsafe_unretained NSString * tauntCancel;
//    
//    __unsafe_unretained NSString * clueListLabel;
//    __unsafe_unretained NSString * clueListClue;
//    
//    __unsafe_unretained NSString * keyboardBarClue;
//    __unsafe_unretained NSString * keyboardBarClueNumber;
//    __unsafe_unretained NSString * keyboardCharacter;
//    
//    __unsafe_unretained NSString * submitButtonDisabled;
//    __unsafe_unretained NSString * submitButtonEnabled;
//    
//    __unsafe_unretained NSString * settingsHeader;
//    __unsafe_unretained NSString * settingsBody;
//    
//    __unsafe_unretained NSString * logo;
//    __unsafe_unretained NSString * gameListPlayer;
//    __unsafe_unretained NSString * gameListScore;
//    __unsafe_unretained NSString * gameListPlayerTurn;
//} TextColor;
//
//
//
//// *******************************
//// Clue Number Colors
//// *******************************
//extern const struct ClueNumberColor {
//    __unsafe_unretained NSString * standard;
//    __unsafe_unretained NSString * standardSelected;
//    __unsafe_unretained NSString * disabled;
//    __unsafe_unretained NSString * limbo;
//    __unsafe_unretained NSString * limboSelected;
//    __unsafe_unretained NSString * localCorrect;
//    __unsafe_unretained NSString * localSteal;
//    __unsafe_unretained NSString * localSelected;
//    __unsafe_unretained NSString * opponentCorrect;
//    __unsafe_unretained NSString * opponentSteal;
//    __unsafe_unretained NSString * opponentSelected;
//} ClueNumberColor;
//
//
//typedef enum {
//    CWThemeColorType_Light = 1,
//    CWThemeColorType_Dark,
//} CWThemeColorType;
//
///** 
// Singleton that imports and provides styling information for app.
// */
//@interface INThemeManager : NSObject
//
///** Array of CWTheme objects. */
//@property(nonatomic, strong) NSArray *themes;
//
///// Lifecycle
//+ (id)shared;
//
//
///// Analytics
//- (NSDictionary *)paramsForViewThemesEvent;
//
//
///// Theme Management
///** Saves the current theme to user defaults and posts a notification that the theme has changed. */
//- (CWTheme *)currentTheme;
//- (CWThemeColorType)currentThemeColorType;
//- (void)setCurrentTheme:(CWTheme *)theme withColorType:(CWThemeColorType)colorType;
//- (BOOL)isCurrentTheme:(CWTheme *)theme;
//
///// Theme Info
//- (NSString *)currentThemeFullName;
//- (NSString *)resignBannerImageName;
//
//
///// Theme Queries
//- (UIColor *)colorWithProperty:(NSString *)property class:(NSString *)aClass;
//- (UIColor *)mainColorWithProperty:(NSString *)property;
//- (UIColor *)textColorWithProperty:(NSString *)property;
//- (UIColor *)clueNumberColorWithProperty:(NSString *)property;
//- (UIFont *)fontWithProperty:(NSString *)property;
//
//@end
