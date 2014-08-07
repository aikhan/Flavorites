#define kNotificationRecipeAddedToFavorite @"NotificationRecipeAddedToFavorite"
#define kNotificationRecipeRemovedFromFavoriteFromFavoriteTab @"NotificationRecipeRemovedFromFavoriteFromFavoriteTab"
#define kNotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen @"NotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen"
#define kNotificationRecipeRatingsChanged @"NotificationRecipeRatingsChanged"
#define kNotificationNewFeaturedRecipesDownloaded @"NotificationNewFeaturedRecipesDownloaded"


#define kDirectoryNameForFeaturedRecipesData @"FeaturedRecipes"


#define kFileNameForFeaturedRecipesJSON @"featured_recipes.json"

#define kAPIServerPathNew @"http://secure.xm0001.net/heavenhill/burnetts/recipe_api"

#define kAPIServerPath @"https://facebook.heavenhill.com/burnetts/recipe_api"

#define kGetAllRecipes @"http://secure.xm0001.net/heavenhill/burnetts/recipe_api/get_all_recipes.php"
#define kGetRecipesUpdates @"http://secure.xm0001.net/heavenhill/burnetts/recipe_api/get_all_recipes.php?last_updated_date="
#define kRecipeBaseURL @"http://burnetts14.xm0001.com/mobile_app/images/recipes/"


#define kGetAllFlavors @"http://secure.xm0001.net/heavenhill/burnetts/recipe_api/get_all_flavors.php"
#define kGetFlavoeUpdates @"http://secure.xm0001.net/heavenhill/burnetts/recipe_api/get_all_flavors.php?last_updated_date="
#define kFlavorsBaseURL @"http://burnetts14.xm0001.com/mobile_app/images/flavors/"

#define kDisableAgeGateForDevelopment 0
#define kEnableWDAAppTrackerLoggingForDevelopment 0


#define kWDAAppTrackerAppID @"9FEEC719-5682-4388-B8D4-193619F062C0"




#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)