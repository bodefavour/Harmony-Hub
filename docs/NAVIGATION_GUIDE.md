# Navigation Guide - Harmony Hub

## New Routes Added ✅

All new routes have been wired in `lib/flutter_flow/nav/nav.dart` and exported in `lib/index.dart`.

### Available Routes

| Route Name | Path | Auth Required | Widget | Parameters |
|------------|------|---------------|--------|------------|
| `Podcasts` | `/podcasts` | ✅ Yes | PodcastsWidget | None |
| `PodcastDetail` | `/podcastDetail/:podcastId` | ✅ Yes | PodcastDetailWidget | podcastId (String), podcast (JSON, optional) |
| `ArtistUpload` | `/artistUpload` | ✅ Yes | ArtistUploadWidget | None |
| `AdminDashboard` | `/adminDashboard` | ✅ Yes | AdminDashboardWidget | None |

## How to Navigate to New Screens

### From Any Widget

You can navigate to the new screens using `context.pushNamed()` from any widget:

```dart
// Navigate to Podcasts list
context.pushNamed('Podcasts');

// Navigate to specific Podcast detail (with podcast object)
context.pushNamed(
  'PodcastDetail',
  pathParameters: {'podcastId': podcast.id},
  extra: {'podcast': podcast},
);

// Navigate to Artist Upload
context.pushNamed('ArtistUpload');

// Navigate to Admin Dashboard
context.pushNamed('AdminDashboard');
```

### Example: Adding Podcast Navigation to Home Page

To add a "Browse Podcasts" button to your home page, you can add:

```dart
FlutterFlowIconButton(
  borderColor: Colors.transparent,
  borderRadius: 20.0,
  buttonSize: 40.0,
  icon: Icon(
    Icons.podcasts,
    color: FlutterFlowTheme.of(context).primary,
    size: 24.0,
  ),
  onPressed: () {
    context.pushNamed('Podcasts');
  },
)
```

### Example: Adding to Bottom Navigation Bar

To add to the existing bottom navigation in `home_page_widget.dart`, you can modify the Row around line 1930:

```dart
Row(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    // Existing Home button
    Container(
      width: 70.0,
      height: 100.0,
      child: FlutterFlowIconButton(
        icon: Icon(Icons.home, color: Color(0xFFE74B08)),
        onPressed: () {
          // Already on home
        },
      ),
    ),
    
    // ADD: Podcasts button
    Container(
      width: 70.0,
      height: 100.0,
      child: FlutterFlowIconButton(
        icon: Icon(Icons.podcasts, color: Color(0xFFE74B08)),
        onPressed: () {
          context.pushNamed('Podcasts');
        },
      ),
    ),
    
    // Existing Search button
    Container(
      width: 70.0,
      height: 100.0,
      child: FlutterFlowIconButton(
        icon: Icon(Icons.search, color: Color(0xFFE74B08)),
        onPressed: () {
          context.pushNamed('Search');
        },
      ),
    ),
    
    // Existing Library button
    Container(
      width: 70.0,
      height: 100.0,
      child: FlutterFlowIconButton(
        icon: Icon(Icons.photo_filter, color: Color(0xFFE74B08)),
        onPressed: () {
          context.pushNamed('Library');
        },
      ),
    ),
  ],
)
```

## Menu/Drawer Option

Alternatively, you can create a drawer menu in your home page:

```dart
Scaffold(
  appBar: AppBar(
    // Add menu button
    actions: [
      IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
    ],
  ),
  endDrawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
          ),
          child: Text(
            'Harmony Hub',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.podcasts),
          title: Text('Podcasts'),
          onTap: () {
            Navigator.pop(context);
            context.pushNamed('Podcasts');
          },
        ),
        ListTile(
          leading: Icon(Icons.upload_file),
          title: Text('Upload Content'),
          onTap: () {
            Navigator.pop(context);
            context.pushNamed('ArtistUpload');
          },
        ),
        ListTile(
          leading: Icon(Icons.admin_panel_settings),
          title: Text('Admin Dashboard'),
          onTap: () {
            Navigator.pop(context);
            context.pushNamed('AdminDashboard');
          },
        ),
      ],
    ),
  ),
  body: // your content
)
```

## Testing Navigation

To test that navigation works:

1. **Hot Restart** your app (not just hot reload): `flutter run --hot` then press `R`
2. Navigate to any existing page
3. Add a test button temporarily:
   ```dart
   ElevatedButton(
     onPressed: () => context.pushNamed('Podcasts'),
     child: Text('Test Podcasts'),
   )
   ```
4. Tap the button - you should navigate to the Podcasts screen

## Deep Linking

The routes support deep linking. For example:
- `yourapp://podcasts` → Opens Podcasts list
- `yourapp://podcastDetail/podcast-id-123` → Opens specific podcast
- `yourapp://artistUpload` → Opens upload form
- `yourapp://adminDashboard` → Opens admin panel

## Navigation Flow Examples

### User Flow: Discover & Listen to Podcast
1. User taps "Podcasts" from navigation
2. → `PodcastsWidget` displays with category tabs
3. User taps a podcast card
4. → `PodcastDetailWidget` opens with podcast details
5. User taps "Play" button
6. → AudioService starts playing the podcast

### Artist Flow: Upload Content
1. Artist taps "Upload" from menu/profile
2. → `ArtistUploadWidget` opens
3. Artist fills form, selects files
4. → Uploads to Supabase Storage
5. → Submit for admin review

### Admin Flow: Moderate Content
1. Admin opens "Admin Dashboard"
2. → `AdminDashboardWidget` displays pending uploads
3. Admin reviews content
4. → Approve/Reject with one tap
5. → Content published or rejected with reason

## Important Notes

- ✅ All routes require authentication (`requireAuth: true`)
- ✅ Unauthenticated users will be redirected to login
- ✅ Routes are integrated with go_router for web support
- ✅ Back button navigation works automatically
- ✅ State is preserved when navigating back

## Next Steps

1. **Add UI Elements**: Add buttons/menu items in your existing pages to navigate to new features
2. **Test Navigation**: Run the app and test each route
3. **Update Home Page**: Consider adding a "Podcasts" section to the home page
4. **Add User Profile Menu**: Add "Upload Content" option for artists in user profile
5. **Admin Access**: Add admin dashboard access for admin users only (check user role)

## Files Modified

- ✅ `lib/index.dart` - Added exports for new widgets
- ✅ `lib/flutter_flow/nav/nav.dart` - Added 4 new routes

No breaking changes to existing navigation!
