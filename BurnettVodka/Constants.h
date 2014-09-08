#define kNotificationRecipeAddedToFavorite @"NotificationRecipeAddedToFavorite"
#define kNotificationRecipeRemovedFromFavoriteFromFavoriteTab @"NotificationRecipeRemovedFromFavoriteFromFavoriteTab"
#define kNotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen @"NotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen"
#define kNotificationRecipeRatingsChanged @"NotificationRecipeRatingsChanged"
#define kNotificationNewFeaturedRecipesDownloaded @"NotificationNewFeaturedRecipesDownloaded"

#define IS_IOS7_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)

#define kDirectoryNameForFeaturedRecipesData @"FeaturedRecipes"


#define kFileNameForFeaturedRecipesJSON @"featured_recipes.json"

#define kAPIServerPathNew @"http://facebook.heavenhill.com/burnetts/recipe_api/2014/"

#define kAPIServerPath @"http://facebook.heavenhill.com/burnetts/recipe_api/2014"

#define kGetAllRecipes @"http://facebook.heavenhill.com/burnetts/recipe_api/2014/get_all_recipes.php"
#define kGetRecipesUpdates @"http://facebook.heavenhill.com/burnetts/recipe_api/2014/get_all_recipes.php?last_updated_date="
#define kRecipeBaseURL @"http://burnettsvodka.com/mobile_app/images/recipes/"


#define kGetAllFlavors @"http://facebook.heavenhill.com/burnetts/recipe_api/2014/get_all_flavors.php"
#define kGetFlavoeUpdates @"http://facebook.heavenhill.com/burnetts/recipe_api/2014/get_all_flavors.php?last_updated_date="
#define kFlavorsBaseURL @"http://burnettsvodka.com/mobile_app/images/flavors/"

#define kDisableAgeGateForDevelopment 0
#define kEnableWDAAppTrackerLoggingForDevelopment 0


#define kWDAAppTrackerAppID @"9FEEC719-5682-4388-B8D4-193619F062C0"




#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#ifdef IS_IOS7_AND_UP
#define kAppURL @"itms-apps://itunes.apple.com/app/id719047616"
#else
#define kAppURL @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=719047616"
#endif