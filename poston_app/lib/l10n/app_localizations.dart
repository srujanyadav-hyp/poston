import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @language_settings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get language_settings;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatbot.
  ///
  /// In en, this message translates to:
  /// **'Chatbot'**
  String get chatbot;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @no_email.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get no_email;

  /// No description provided for @error_signing_out.
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get error_signing_out;

  /// No description provided for @admin_panel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_panel;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome_back;

  /// No description provided for @account_created.
  ///
  /// In en, this message translates to:
  /// **'Account created!'**
  String get account_created;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpected_error;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @toggle_mode.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get toggle_mode;

  /// No description provided for @switch_to_signin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switch_to_signin;

  /// No description provided for @sign_in_button.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in_button;

  /// No description provided for @sign_up_button.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up_button;

  /// No description provided for @sign_out_button.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out_button;

  /// No description provided for @upload_service.
  ///
  /// In en, this message translates to:
  /// **'Upload Service'**
  String get upload_service;

  /// No description provided for @upload_banner.
  ///
  /// In en, this message translates to:
  /// **'Upload Banner'**
  String get upload_banner;

  /// No description provided for @service_title.
  ///
  /// In en, this message translates to:
  /// **'Service Title'**
  String get service_title;

  /// No description provided for @sub_heading.
  ///
  /// In en, this message translates to:
  /// **'Sub Heading'**
  String get sub_heading;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @map_link.
  ///
  /// In en, this message translates to:
  /// **'Map Link'**
  String get map_link;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @select_category.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get select_category;

  /// No description provided for @temple_information.
  ///
  /// In en, this message translates to:
  /// **'Temple Information'**
  String get temple_information;

  /// No description provided for @tirupati.
  ///
  /// In en, this message translates to:
  /// **'Tirupati'**
  String get tirupati;

  /// No description provided for @sabarimala.
  ///
  /// In en, this message translates to:
  /// **'SABARIMALA'**
  String get sabarimala;

  /// No description provided for @cabs_and_travels.
  ///
  /// In en, this message translates to:
  /// **'Cabs and Travels'**
  String get cabs_and_travels;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @petrol_bunks.
  ///
  /// In en, this message translates to:
  /// **'Petrol Bunks'**
  String get petrol_bunks;

  /// No description provided for @earn_with_us.
  ///
  /// In en, this message translates to:
  /// **'Earn with us'**
  String get earn_with_us;

  /// No description provided for @contact_and_chat.
  ///
  /// In en, this message translates to:
  /// **'Contact and chat'**
  String get contact_and_chat;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get select_image;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @banner_title.
  ///
  /// In en, this message translates to:
  /// **'Banner Title'**
  String get banner_title;

  /// No description provided for @banner_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Banner Subtitle'**
  String get banner_subtitle;

  /// No description provided for @discount_value.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get discount_value;

  /// No description provided for @discount_text.
  ///
  /// In en, this message translates to:
  /// **'Discount Text'**
  String get discount_text;

  /// No description provided for @button_text.
  ///
  /// In en, this message translates to:
  /// **'Button Text'**
  String get button_text;

  /// No description provided for @button_link.
  ///
  /// In en, this message translates to:
  /// **'Button Link'**
  String get button_link;

  /// No description provided for @devotion_app.
  ///
  /// In en, this message translates to:
  /// **'Devotion App'**
  String get devotion_app;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light_mode;

  /// No description provided for @continue_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continue_with_google;

  /// No description provided for @or_email.
  ///
  /// In en, this message translates to:
  /// **'or with email'**
  String get or_email;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @password_reset_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get password_reset_sent;

  /// No description provided for @account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get account_settings;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @see_more.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get see_more;

  /// No description provided for @see_less.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get see_less;

  /// No description provided for @read_more.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get read_more;

  /// No description provided for @read_less.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get read_less;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;

  /// No description provided for @add_service.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get add_service;

  /// No description provided for @manage_services.
  ///
  /// In en, this message translates to:
  /// **'Manage Services'**
  String get manage_services;

  /// No description provided for @add_promo_banner.
  ///
  /// In en, this message translates to:
  /// **'Add Promo Banner'**
  String get add_promo_banner;

  /// No description provided for @manage_banners.
  ///
  /// In en, this message translates to:
  /// **'Manage Banners'**
  String get manage_banners;

  /// No description provided for @which_service.
  ///
  /// In en, this message translates to:
  /// **'Which Service?'**
  String get which_service;

  /// No description provided for @upload_image_text.
  ///
  /// In en, this message translates to:
  /// **'Upload Image:'**
  String get upload_image_text;

  /// No description provided for @confirm_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete_title;

  /// No description provided for @confirm_delete_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirm_delete_msg;

  /// No description provided for @no_services.
  ///
  /// In en, this message translates to:
  /// **'No services found.'**
  String get no_services;

  /// No description provided for @no_banners.
  ///
  /// In en, this message translates to:
  /// **'No banners found.'**
  String get no_banners;

  /// No description provided for @darshan_assistant.
  ///
  /// In en, this message translates to:
  /// **'Darshan Assistant'**
  String get darshan_assistant;

  /// No description provided for @error_communicating.
  ///
  /// In en, this message translates to:
  /// **'Error communicating with server. Please try again.'**
  String get error_communicating;

  /// No description provided for @item_deleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully!'**
  String get item_deleted;

  /// No description provided for @error_deleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting item: '**
  String get error_deleting;

  /// No description provided for @select_image_text.
  ///
  /// In en, this message translates to:
  /// **'Tap to select an image from Gallery'**
  String get select_image_text;

  /// No description provided for @unable_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete: Item ID not found'**
  String get unable_to_delete;

  /// No description provided for @service_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Service uploaded successfully!'**
  String get service_uploaded;

  /// No description provided for @banner_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Promo Banner uploaded successfully!'**
  String get banner_uploaded;

  /// No description provided for @select_bg_image.
  ///
  /// In en, this message translates to:
  /// **'Please select a background image for the banner'**
  String get select_bg_image;

  /// No description provided for @select_service_image.
  ///
  /// In en, this message translates to:
  /// **'Please select a service image first'**
  String get select_service_image;

  /// No description provided for @valid_coords.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid latitude and longitude values'**
  String get valid_coords;

  /// No description provided for @both_coords.
  ///
  /// In en, this message translates to:
  /// **'Please enter both latitude and longitude'**
  String get both_coords;

  /// No description provided for @banner_title_label.
  ///
  /// In en, this message translates to:
  /// **'Banner Title:'**
  String get banner_title_label;

  /// No description provided for @banner_subtitle_label.
  ///
  /// In en, this message translates to:
  /// **'Banner Subtitle:'**
  String get banner_subtitle_label;

  /// No description provided for @discount_value_label.
  ///
  /// In en, this message translates to:
  /// **'Discount Value:'**
  String get discount_value_label;

  /// No description provided for @discount_text_label.
  ///
  /// In en, this message translates to:
  /// **'Discount Text:'**
  String get discount_text_label;

  /// No description provided for @button_text_label.
  ///
  /// In en, this message translates to:
  /// **'Button Text:'**
  String get button_text_label;

  /// No description provided for @button_link_label.
  ///
  /// In en, this message translates to:
  /// **'Button Link (Optional):'**
  String get button_link_label;

  /// No description provided for @bg_image_label.
  ///
  /// In en, this message translates to:
  /// **'Background Image (Required):'**
  String get bg_image_label;

  /// No description provided for @icon_image_label.
  ///
  /// In en, this message translates to:
  /// **'Transparent Icon Image (Optional):'**
  String get icon_image_label;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search Temples, Cities, Directions...'**
  String get search_hint;

  /// No description provided for @venkateswara.
  ///
  /// In en, this message translates to:
  /// **'VENKATESWARA'**
  String get venkateswara;

  /// No description provided for @type_to_search.
  ///
  /// In en, this message translates to:
  /// **'Type to search for real places...'**
  String get type_to_search;

  /// No description provided for @view_on_map.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get view_on_map;

  /// No description provided for @location_na.
  ///
  /// In en, this message translates to:
  /// **'Location N/A'**
  String get location_na;

  /// No description provided for @image_missing.
  ///
  /// In en, this message translates to:
  /// **'Image missing'**
  String get image_missing;

  /// No description provided for @temples_info.
  ///
  /// In en, this message translates to:
  /// **'🛕 Temples Information'**
  String get temples_info;

  /// No description provided for @hotels_label.
  ///
  /// In en, this message translates to:
  /// **'🏨 Hotels'**
  String get hotels_label;

  /// No description provided for @cabs_label.
  ///
  /// In en, this message translates to:
  /// **'🚕 Cabs & Travels'**
  String get cabs_label;

  /// No description provided for @parking_label.
  ///
  /// In en, this message translates to:
  /// **'🅿️ Parking Spots'**
  String get parking_label;

  /// No description provided for @petrol_label.
  ///
  /// In en, this message translates to:
  /// **'⛽ Petrol Bunks'**
  String get petrol_label;

  /// No description provided for @earn_label.
  ///
  /// In en, this message translates to:
  /// **'🤝 Earn with us'**
  String get earn_label;

  /// No description provided for @contact_label.
  ///
  /// In en, this message translates to:
  /// **'💬 Contact & Chat'**
  String get contact_label;

  /// No description provided for @ganesh_temple.
  ///
  /// In en, this message translates to:
  /// **'✨ Renowned Ganesh Temple'**
  String get ganesh_temple;

  /// No description provided for @rahu_ketu.
  ///
  /// In en, this message translates to:
  /// **'✨ Famous for Rahu-Ketu Pooja'**
  String get rahu_ketu;

  /// No description provided for @vishnu_temple.
  ///
  /// In en, this message translates to:
  /// **'✨ Historic Vishnu Temple'**
  String get vishnu_temple;

  /// No description provided for @marriage_blessings.
  ///
  /// In en, this message translates to:
  /// **'✨ Known for Marriage Blessings'**
  String get marriage_blessings;

  /// No description provided for @shiva_temple.
  ///
  /// In en, this message translates to:
  /// **'✨ Sacred Shiva Temple'**
  String get shiva_temple;

  /// No description provided for @famous_temples.
  ///
  /// In en, this message translates to:
  /// **'Famous Temples'**
  String get famous_temples;

  /// No description provided for @view_all_small.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all_small;

  /// No description provided for @tirumala_desc.
  ///
  /// In en, this message translates to:
  /// **'Tirumala Tirupati Devasthanams'**
  String get tirumala_desc;

  /// No description provided for @ayyappa_desc.
  ///
  /// In en, this message translates to:
  /// **'Ayyappa Swamy Songs'**
  String get ayyappa_desc;

  /// No description provided for @our_services.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get our_services;

  /// No description provided for @worldwide_locations.
  ///
  /// In en, this message translates to:
  /// **'Worldwide Locations'**
  String get worldwide_locations;

  /// No description provided for @find_best_stays.
  ///
  /// In en, this message translates to:
  /// **'Find Best Stays'**
  String get find_best_stays;

  /// No description provided for @book_rides_easily.
  ///
  /// In en, this message translates to:
  /// **'Book Rides Easily'**
  String get book_rides_easily;

  /// No description provided for @find_safe_parking.
  ///
  /// In en, this message translates to:
  /// **'Find Safe Parking Nearby'**
  String get find_safe_parking;

  /// No description provided for @locate_fuel_stations.
  ///
  /// In en, this message translates to:
  /// **'Locate Fuel Stations'**
  String get locate_fuel_stations;

  /// No description provided for @join_our_network.
  ///
  /// In en, this message translates to:
  /// **'Join our network'**
  String get join_our_network;

  /// No description provided for @support_24_7.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support_24_7;

  /// No description provided for @choose_language.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get choose_language;

  /// No description provided for @language_desc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to view content and receive assistance in.'**
  String get language_desc;

  /// No description provided for @save_preferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get save_preferences;

  /// No description provided for @open_daily.
  ///
  /// In en, this message translates to:
  /// **'Open Daily'**
  String get open_daily;

  /// No description provided for @official_website.
  ///
  /// In en, this message translates to:
  /// **'Official Website'**
  String get official_website;

  /// No description provided for @special_darshan.
  ///
  /// In en, this message translates to:
  /// **'Special Darshan'**
  String get special_darshan;

  /// No description provided for @dress_code.
  ///
  /// In en, this message translates to:
  /// **'Dress Code'**
  String get dress_code;

  /// No description provided for @dress_code_desc.
  ///
  /// In en, this message translates to:
  /// **'Men: Dhoti / Shirt / Pants\nWomen: Saree / Chudidar / Traditional Wear'**
  String get dress_code_desc;

  /// No description provided for @accommodation_available.
  ///
  /// In en, this message translates to:
  /// **'Accommodation Available'**
  String get accommodation_available;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @overview_desc.
  ///
  /// In en, this message translates to:
  /// **'Discover the history, architecture, and spirituality of this famous temple. Plan your visit to experience peace and devotion.'**
  String get overview_desc;

  /// No description provided for @explore_btn.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore_btn;

  /// No description provided for @nearby_temples.
  ///
  /// In en, this message translates to:
  /// **'Nearby / Similar Temples'**
  String get nearby_temples;

  /// No description provided for @sabarimala_loc.
  ///
  /// In en, this message translates to:
  /// **'Sabarimala, Kerala'**
  String get sabarimala_loc;

  /// No description provided for @tirumala_loc.
  ///
  /// In en, this message translates to:
  /// **'Tirumala, Andhra Pradesh'**
  String get tirumala_loc;

  /// No description provided for @kanipakam.
  ///
  /// In en, this message translates to:
  /// **'Kanipakam Vinayaka Temple'**
  String get kanipakam;

  /// No description provided for @kanipakam_desc.
  ///
  /// In en, this message translates to:
  /// **'✨ Renowned Ganesh Temple'**
  String get kanipakam_desc;

  /// No description provided for @chittoor.
  ///
  /// In en, this message translates to:
  /// **'Chittoor'**
  String get chittoor;

  /// No description provided for @srikalahasti.
  ///
  /// In en, this message translates to:
  /// **'Srikalahasti Temple'**
  String get srikalahasti;

  /// No description provided for @rahu_ketu_pooja.
  ///
  /// In en, this message translates to:
  /// **'✨ Famous for Rahu-Ketu Pooja'**
  String get rahu_ketu_pooja;

  /// No description provided for @srikalahasti_loc.
  ///
  /// In en, this message translates to:
  /// **'Srikalahasti'**
  String get srikalahasti_loc;

  /// No description provided for @govindaraja.
  ///
  /// In en, this message translates to:
  /// **'Sri Govindaraja Swamy Temple'**
  String get govindaraja;

  /// No description provided for @vishnu_historic.
  ///
  /// In en, this message translates to:
  /// **'✨ Historic Vishnu Temple'**
  String get vishnu_historic;

  /// No description provided for @kalyana_venkateswara.
  ///
  /// In en, this message translates to:
  /// **'Sri Kalyana Venkateswara Temple'**
  String get kalyana_venkateswara;

  /// No description provided for @marriage_blessings_desc.
  ///
  /// In en, this message translates to:
  /// **'✨ Known for Marriage Blessings'**
  String get marriage_blessings_desc;

  /// No description provided for @srinivasa_mangapuram.
  ///
  /// In en, this message translates to:
  /// **'Srinivasa Mangapuram'**
  String get srinivasa_mangapuram;

  /// No description provided for @kapila_theertham.
  ///
  /// In en, this message translates to:
  /// **'Kapila Theertham Temple'**
  String get kapila_theertham;

  /// No description provided for @sacred_shiva.
  ///
  /// In en, this message translates to:
  /// **'✨ Sacred Shiva Temple'**
  String get sacred_shiva;

  /// No description provided for @about_this_service.
  ///
  /// In en, this message translates to:
  /// **'About this Service'**
  String get about_this_service;

  /// No description provided for @explore_listings_desc.
  ///
  /// In en, this message translates to:
  /// **'Explore the best listings for {title}. Browse through top-rated options available in your area.'**
  String explore_listings_desc(Object title);

  /// No description provided for @available_listings.
  ///
  /// In en, this message translates to:
  /// **'Available Listings'**
  String get available_listings;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @promo_title.
  ///
  /// In en, this message translates to:
  /// **'Special Darshan Offers'**
  String get promo_title;

  /// No description provided for @promo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Darshan & Pooja'**
  String get promo_subtitle;

  /// No description provided for @promo_discount_text.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get promo_discount_text;

  /// No description provided for @promo_button_text.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get promo_button_text;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
