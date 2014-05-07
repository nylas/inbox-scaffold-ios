////
////  CWThemeManager.m
////  Crossly
////
////  Created by Demetri Miller on 4/17/13.
////  Copyright (c) 2013 Demetri Miller. All rights reserved.
////
//
//#import "INThemeManager.h"
//
//#define CurrentThemeName @"CurrentThemeName"
//#define CurrentThemeColorType @"CurrentThemeColorType"
//
//NSString * const CWThemeChangedNotification = @"CWThemeChangedNotification";
////
//// *******************************
//// Fonts
//// *******************************
//const struct Font Font = {
//    .pencil = @"pencil",
//    .pen = @"pen",
//    .clueNumber = @"clue-number",
//    .peek = @"peek",
//    .peekIconLarge = @"peek-icon-large",
//    
//    .popupRegular = @"popup-regular",
//    .popupBold = @"popup-bold",
//    .popupGameOverPlayer = @"popup-game-over-player",
//    .popupGameOverScore = @"popup-game-over-score",
//    .popupPeeksEarned = @"popup-peeks-earned",
//    
//    .optionsPopupTitle = @"options-popup-title",
//    .optionsPopupButton = @"options-popup-button",
//    
//    .alertTitle = @"alert-title",
//    .alertMessage = @"alert-message",
//    .alertAction = @"alert-action",
//    .alertCancel = @"alert-cancel",
//    
//    .tauntStatusLabel = @"taunt-status-label",
//    .tauntPromptLabel = @"taunt-prompt-label",
//    .tauntCancel = @"taunt-cancel",
//    .tauntSend = @"taunt-send",
//    .tauntRetake = @"taunt-retake",
//    
//    .clueListNumber = @"clue-list-number",
//    .clueListLabel = @"clue-list-label",
//    
//    .gameListPlayer = @"game-list-player",
//    .gameListScore = @"game-list-score",
//    .gameListSectionHeader = @"game-list-section-header",
//    .gameListPlayerTurn = @"game-list-player-turn",
//    .gameListPlayerTurnBold = @"game-list-player-turn-bold",
//    .gameListAdvertisement = @"game-list-advertisement",
//    .gameListPlayerHeader = @"game-list-player-header",
//    
//    .headerScoreLarge = @"header-score-large",
//    .headerScoreSmall = @"header-score-small",
//    .headerScoreCounter = @"header-score-counter",
//    
//    .keyboardBarClueNumber = @"keyboard-bar-clue-number",
//    .keyboardBarClueLabel = @"keyboard-bar-clue-label",
//    .keyboardKeyZoomCharacter = @"keyboard-key-zoom-character",
//    
//    .buyPeekQuantity = @"buy-peek-quantity",
//    .buyPeekPrice = @"buy-peek-price",
//    
//    .submitButton = @"submit-button",
//    .navDoneButton = @"nav-done-button",
//    
//    .settingsListLabel = @"settings-list-label",
//    .settingsListDescription = @"settings-list-description",
//    .settingsHeader = @"settings-header",
//    .settingsBody = @"settings-body",
//    .settingsPremiumPay = @"settings-premium-pay",
//    .settingsAboutHeader = @"settings-about-header",
//    .settingsNavHeader = @"settings-nav-header",
//    
//    .logo = @"logo",
//};
//
//
//// *******************************
//// Main Colors
//// *******************************
//const struct Main Main = {
//    .headerBackground = @"header-background",
//    
//    .tint = @"main-tint",
//    
//    .localCorrect = @"local-correct",
//    .localSteal = @"local-steal",
//    .opponentCorrect = @"opponent-correct",
//    .opponentSteal = @"opponent-steal",
//    .opponentSelected = @"opponent-selected",
//    .limbo = @"limbo",
//    .limboSelected = @"limbo-selected",
//    
//    .popupBackground = @"popup-background",
//    .popupButtonDivider = @"popup-button-divider",
//    .popupButtonSelected= @"popup-button-selected",
//    
//    .puzzleBackground = @"puzzle-background",
//    .puzzleGridDivider = @"puzzle-grid-divider",
//    .puzzleEmptyBlock = @"puzzle-empty-block",
//    .puzzleSelectedClueShadow = @"puzzle-selected-clue-shadow",
//    .puzzleBlurTintColor = @"puzzle-blur-tint-color",
//    
//    .marchingAntsPrimary = @"marching-ants-primary",
//    .marchingAntsSecondary = @"marching-ants-secondary",
//    
//    .submitButtonDisabled = @"submit-button-disabled",
//    
//    .keyboardBackground = @"keyboard-background",
//    .keyboardKeyBackground = @"keyboard-key-background",
//    .keyboardKeyShadow = @"keyboard-key-shadow",
//    .keyboardDeleteKeyBackground = @"keyboard-delete-key-background",
//    .keyboardDeleteKeyShadow = @"keyboard-delete-key-shadow",
//    .keyboardPeekKeyDepressed = @"keyboard-peek-key-depressed",
//    
//    .settingsPremiumCheckboxBorder = @"settings-premium-checkbox-border",
//    .settingsIcons = @"settings-icons",
//    .settingsIconsTheme = @"settings-icons-theme",
//    .settingsListDivider = @"settings-list-divider",
//    
//    .gameListBackground = @"game-list-background",
//    .gameListHeaderDivider = @"game-list-header-divider",
//    .gameListDivider = @"game-list-divider",
//    .gameListCellSelectedBackground = @"game-list-cell-selected-background",
//    .gameListRefresh = @"game-list-refresh",
//};
//
//// *******************************
//// Text Colors
//// *******************************
//const struct TextColor TextColor = {
//    .selected = @"selected",
//    .pencil = @"pencil",
//    .pen = @"pen",
//    .limbo = @"limbo",
//    
//    .popupRegular = @"popup-regular",
//    .popupWrong = @"popup-wrong",
//    .popupPeekError = @"popup-peek-error",
//    
//    .optionsPopupDisabled = @"options-popup-disabled",
//    .optionsPopupCancel = @"options-popup-cancel",
//    
//    .tauntRetake = @"taunt-retake",
//    .tauntCancel = @"taunt-cancel",
//    
//    .clueListLabel = @"clue-list-label",
//    .clueListClue = @"clue-list-clue",
//    
//    .keyboardBarClue = @"keyboard-bar-clue",
//    .keyboardBarClueNumber = @"keyboard-bar-clue-number",
//    .keyboardCharacter = @"keyboard-character",
//    
//    .submitButtonDisabled = @"submit-button-disabled",
//    .submitButtonEnabled = @"submit-button-enabled",
//    
//    .settingsHeader = @"settings-header",
//    .settingsBody = @"settings-body",
//    
//    .logo = @"logo",
//    .gameListPlayer = @"game-list-player",
//    .gameListScore = @"game-list-score",
//    .gameListPlayerTurn = @"game-list-player-turn",
//};
//
//
//
//// *******************************
//// Clue Number Colors
//// *******************************
//const struct ClueNumberColor ClueNumberColor = {
//    .standard = @"standard",
//    .standardSelected = @"standard-selected",
//    .disabled = @"disabled",
//    .limbo = @"limbo",
//    .limboSelected = @"limbo-selected",
//    .localCorrect = @"local-correct",
//    .localSteal = @"local-steal",
//    .localSelected = @"local-selected",
//    .opponentCorrect = @"opponent-correct",
//    .opponentSteal = @"opponent-steal",
//    .opponentSelected = @"opponent-selected",
//};
//
//
//
//@implementation INThemeManager
//{
//    CWTheme *_currentTheme;
//    CWThemeColorType _currentThemeColorType;
//    NSMutableDictionary *_curThemeCache;
//    NSMutableDictionary *_rawStyles;
//}
//
//
//#pragma mark - Lifecycle
//+ (instancetype)shared
//{
//    static dispatch_once_t pred = 0;
//    __strong static id _instance = nil;
//    dispatch_once(&pred, ^{
//        _instance = [[self alloc] init];
//    });
//    return _instance;
//}
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        NSString *file = [[NSBundle mainBundle] pathForResource:@"Themes" ofType:@"plist"];
//        NSArray *rawThemes = [NSArray arrayWithContentsOfFile:file];
//        NSAssert(rawThemes.count > 0, @"No themes set in plist.");
//        
//        NSMutableArray *themes = [[NSMutableArray alloc] init];
//        for (NSDictionary *d in rawThemes) {
//            CWTheme *t = [[CWTheme alloc] initWithDictionary:d];
//            [themes addObject:t];
//        }
//        _themes = themes;
//        _currentThemeColorType = 0;
//        
//        _rawStyles = [NSMutableDictionary dictionary];
//        _curThemeCache = [NSMutableDictionary dictionary];
//        _currentTheme = [self currentTheme];
//        _currentThemeColorType = [self currentThemeColorType];
//        NSString *name = [self fullThemeNameForTheme:_currentTheme colorType:_currentThemeColorType];
//        NSString *fontName = _currentTheme.fontName;
//        [self loadThemeWithName:name fontName:fontName];
//    }
//    return self;
//}
//
//
//#pragma mark - Analytics
//- (NSDictionary *)paramsForViewThemesEvent
//{
//    NSDictionary *params = @{EventViewThemes.currentThemeName : [self fullThemeNameForTheme:_currentTheme colorType:_currentThemeColorType]};
//    return params;
//}
//
//
//#pragma mark - Theme Management
//- (void)loadThemeWithName:(NSString *)name fontName:(NSString *)fontName
//{
//    NSString *themeFilepath = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
//    NSString *fontFilepath = [[NSBundle mainBundle] pathForResource:fontName ofType:@"json"];
//    NSString *themeContents = [NSString stringWithContentsOfFile:themeFilepath encoding:NSUTF8StringEncoding error:nil];
//    NSString *fontContents = [NSString stringWithContentsOfFile:fontFilepath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSDictionary *themeDict = [NSJSONSerialization JSONObjectWithData:[themeContents dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    NSDictionary *fontDict = [NSJSONSerialization JSONObjectWithData:[fontContents dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    
//    [_rawStyles addEntriesFromDictionary:themeDict];
//    [_rawStyles addEntriesFromDictionary:fontDict];
//}
//
//- (void)setCurrentTheme:(CWTheme *)theme withColorType:(CWThemeColorType)colorType
//{
//    // If the theme has changed, clear out the cache, update the stylesheet, and post a notification
//    // that the theme has changed.
//    
//    if (![theme.name isEqualToString:_currentTheme.name] || _currentThemeColorType != colorType) {
//        _currentTheme = theme;
//        _currentThemeColorType = colorType;
//        [[NSUserDefaults standardUserDefaults] setObject:theme.name forKey:CurrentThemeName];
//        [[NSUserDefaults standardUserDefaults] setInteger:colorType forKey:CurrentThemeColorType];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        NSString *fullName = [self fullThemeNameForTheme:theme colorType:colorType];
//        [self loadThemeWithName:fullName fontName:theme.fontName];
//        
//        [_curThemeCache removeAllObjects];
//        [[NSNotificationCenter defaultCenter] postNotificationName:CWThemeChangedNotification object:nil userInfo:nil];
//    }
//}
//
//- (CWTheme *)currentTheme
//{
//    if (!_currentTheme) {
//        NSString *themeName = [[NSUserDefaults standardUserDefaults] objectForKey:CurrentThemeName];
//        if (!themeName) {
//            themeName = [_themes[0] name];
//            [[NSUserDefaults standardUserDefaults] setObject:themeName forKey:CurrentThemeName];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        
//        for (CWTheme *t in _themes) {
//            if ([t.name isEqualToString:themeName]) {
//                _currentTheme = t;
//                break;
//            }
//        }
//    }
//    return _currentTheme;
//}
//
//- (BOOL)isCurrentTheme:(CWTheme *)theme
//{
//    return [theme.name isEqualToString:_currentTheme.name];
//}
//
//- (CWThemeColorType)currentThemeColorType
//{
//    if (_currentThemeColorType == 0) {
//        _currentThemeColorType = (CWThemeColorType)[[NSUserDefaults standardUserDefaults] integerForKey:CurrentThemeColorType];
//        if (_currentThemeColorType == 0) {
//            _currentThemeColorType = CWThemeColorType_Light;
//            [[NSUserDefaults standardUserDefaults] setInteger:_currentThemeColorType forKey:CurrentThemeColorType];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//    return _currentThemeColorType;
//}
//
//- (NSString *)fullThemeNameForTheme:(CWTheme *)theme colorType:(CWThemeColorType)colorType
//{
//    NSString *colorString = (colorType == CWThemeColorType_Light) ? @"Light" : @"Dark";
//    return [NSString stringWithFormat:@"%@_%@", theme.name, colorString];
//}
//
//
//#pragma mark - Theme Info
//- (NSString *)currentThemeFullName
//{
//    return [self fullThemeNameForTheme:_currentTheme colorType:_currentThemeColorType];
//}
//
//- (NSString *)resignBannerImageName
//{
//    return (self.currentThemeColorType == CWThemeColorType_Light) ? @"resigned_light" : @"resigned_dark";
//}
//
//
//#pragma mark - Theme Queries
//- (UIColor *)colorWithProperty:(NSString *)property class:(NSString *)aClass
//{
//    UIColor *color = [self cachedValueWithProperty:property class:aClass];
//    if (!color) {
//        NSString *colorStr = _rawStyles[aClass][property];
//        color = [UIColor colorWithHexRGBString:colorStr];
//        [self setCachedValue:color withProperty:property class:aClass];
//    }
//    
//    return color;
//}
//
//- (UIColor *)mainColorWithProperty:(NSString *)property
//{
//    return [self colorWithProperty:property class:@"MainColors"];
//}
//
//- (UIColor *)textColorWithProperty:(NSString *)property
//{
//    return [self colorWithProperty:property class:@"TextColors"];
//}
//
//- (UIColor *)clueNumberColorWithProperty:(NSString *)property
//{
//    return [self colorWithProperty:property class:@"ClueNumberColors"];
//}
//
//- (UIFont *)fontWithProperty:(NSString *)property
//{
//    NSString *class = @"Fonts";
//    UIFont *font = [self cachedValueWithProperty:property class:class];
//    if (!font) {
//        NSString *rawValue = _rawStyles[class][property];
//        NSArray *components = [rawValue componentsSeparatedByString:@" "];
//        NSAssert(components.count == 2, @"Font styles should have two components <name> <size>. Error style: %@", property);
//        
//        NSString *name = components[0];
//        CGFloat size = [components[1] floatValue];
//        font = [UIFont fontWithName:name size:size];
//        [self setCachedValue:font withProperty:property class:class];
//    }
//    
//    return font;
//}
//
//
//#pragma mark - Theme Caching
//- (id)cachedValueWithProperty:(NSString *)property class:(NSString *)class
//{
//    return _curThemeCache[class][property];
//}
//
//- (void)setCachedValue:(id)value withProperty:(NSString *)property class:(NSString *)class
//{
//    NSMutableDictionary *classDict = _curThemeCache[class];
//    if (!classDict) {
//        classDict = [NSMutableDictionary dictionary];
//        _curThemeCache[class] = classDict;
//    }
//    
//    classDict[property] = value;
//}
//
//@end
