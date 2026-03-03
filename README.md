## Moamen Project – Delivery & Orders Dashboard (Flutter)

Moamen Project is a **Flutter application** for managing delivery orders with an interactive map, price lists, and a profile/settings area.  
The app is **Arabic-first** (locale `ar`) and integrates with **Supabase** as a backend, showing orders on a map and helping couriers or operators manage active deliveries efficiently.

### Features

- **Authentication**
  - Login and registration screens.
  - Account activation handling (`AccountNotActiveScreen`).
  - Secure storage using `flutter_secure_storage`, hashed passwords with `bcrypt` (where used), and `.env` configuration.

- **Dashboard & Navigation**
  - Main `DashboardScreen` with a bottom navigation bar:
    - **الطلبات** – orders list and details.
    - **الأسعار** – price list with add/detail screens.
    - **الخريطة** – interactive map with current orders and public areas.
    - **الحساب** – profile and settings.

- **Interactive Map**
  - Built using `flutter_map` and `latlong2`.
  - Shows:
    - User location.
    - User orders as numbered markers with priority colors.
    - Public order circles and clusters.
    - Route polylines between points.
  - Edge indicators to show off-screen orders and quickly navigate to them.
  - Bottom sheet with order details and lists of public orders.

- **Orders Management**
  - Orders list, add order screen, and order details.
  - Location picker for orders.
  - Availability settings for when orders can be taken.
  - Tracking model for order status and route information.

- **Price List**
  - Price list screen with detail and add/edit screens.
  - Data models for prices and UI widgets for displaying them.

- **Profile & Settings**
  - Profile screen with user information.
  - Edit profile and settings tiles.
  - Dark/light theme toggle powered by Riverpod.

- **Admin Dashboard**
  - Admin dashboard with user details and cards.
  - Transactions list and transaction details.
  - Sorting and filters for admin data.

- **Infrastructure & Services**
  - **Supabase** integration via `SupabaseService`.
  - **Connectivity** monitoring (`connectivity_plus`) with `ConnectivityWidget`.
  - **Location** services & permissions (`geolocator`, `permission_handler`).
  - **Local storage** via `hive_ce` / `hive_ce_flutter` and `shared_preferences`.
  - **App update gate** with an `UpdateGate` screen.

- **UI/UX Enhancements**
  - Custom themes (`AppTheme`, `AppColors`) with dark/light support.
  - Loading animations (`confetti`, `flutter_spinkit`, `lottie`, `loading_animation_widget`, `AnimationWidget`).
  - Skeleton/loading states with `shimmer` and `shimmer_ai`.
  - Custom widgets: snackbars, cards, bottom sheets, image headers, buttons, full-screen images, etc.
  - Arabic fonts via `google_fonts` (e.g. Cairo).

### Tech Stack

- **Framework**: Flutter (Dart), Material Design, Arabic localization.
- **State Management**: `flutter_riverpod`, `state_notifier`.
- **Backend**: `supabase_flutter` for auth and data.
- **Mapping & Geo**:
  - `flutter_map`, `flutter_map_marker_cluster`
  - `latlong2`, `open_route_service`
  - `geolocator`, `permission_handler`
- **Storage**:
  - `hive_ce`, `hive_ce_flutter`
  - `shared_preferences`
  - `flutter_secure_storage`
- **UI / UX**:
  - `google_fonts`, `icons_plus`, `flutter_svg`, `lottie`
  - `carousel_slider`, `cached_network_image`, `image_picker`, `flutter_image_compress`
- **Other Utilities**:
  - `http`, `dartz`, `package_info_plus`, `apk_sideload`, `intl`

### Project Structure (high level)

- `lib/main.dart` – App entry point, localization, theming, Supabase init, and global wrappers for connectivity and location.
- `lib/core/` – Shared utilities, theme, services, permissions, widgets, and error handling.
- `lib/features/auth/` – Authentication screens, controllers, and models.
- `lib/features/dashboard/` – Main `DashboardScreen` and bottom navigation.
- `lib/features/map/` – Map screen, map state, map models, and map widgets.
- `lib/features/orders/` – Orders screens, controllers, models, and location picker.
- `lib/features/pricelist/` – Price list screens, controllers, and models.
- `lib/features/settings/` – Profile, edit profile, and settings state.
- `lib/features/adminDashbord/` – Admin dashboard, user details, transactions.
- `lib/features/splash/` – Splash screen, update screen, and related state.

### Screenshots

If you want to show screenshots on GitHub, you can use the existing `app screenshot/` folder and reference an image like this (update the file name to match your image):

```markdown
![App screenshot](app%20screenshot/your_screenshot_name.png)
```

Make sure the screenshot file is committed to the repository (the folder is currently untracked in git).

### Getting Started

- **Prerequisites**
  - Flutter SDK **3.10.x** or newer (compatible with `sdk: ^3.10.7`).
  - A configured **Supabase** project (URL and anon key).
  - A valid `.env` file at the project root for Supabase and any other secrets.

- **1. Clone the repository**

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd moamen_project
```

- **2. Configure environment variables**

Create a `.env` file in the project root (if not already present) and add your Supabase configuration and any other required keys:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
# Add any other keys you use in SupabaseService or elsewhere
```

- **3. Install dependencies**

```bash
flutter pub get
```

- **4. Run the app**

Connect a device or start an emulator, then run:

```bash
flutter run
```

### Localization

- Default locale: **Arabic (`ar`)**.
- Material, Widgets, and Cupertino localizations are enabled via `flutter_localizations`.

### Contributing

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/your-feature-name`.
3. Commit your changes: `git commit -m "Add your feature"`.
4. Push to your branch: `git push origin feature/your-feature-name`.
5. Open a Pull Request.

### License

Add your preferred license here (e.g. MIT, Apache-2.0) or link to a `LICENSE` file if you add one.

# moamen_project

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# moamen_project
