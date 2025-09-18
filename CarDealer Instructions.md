Car Dealer (SwiftUI + SwiftData)

# Description
An iOS app where users can sign in, manage a profile, browse cars from a remote JSON feed,
buy and sell cars (create local listings), like cars, and persist everything locally with SwiftData.
The UI uses LazyVStack, custom styles, alignment guides, shapes, and supports Dark Mode.
This Lab will be expanded on in Lab 3 where we will focus on Brand creation, logo generation,
thematics, native integrations and more.

Targets: iOS 17+, Swift 5.9+
Estimated time: ~3–6 hours (depends on depth)
Prereqs: SwiftUI basics; Codable; comfort with Xcode previews/simulator

# Learning Objectives
* SwiftData: Define @Model types, relationships, fetch with @Query, save data,
background imports.
* JSON (Internet): Fetch a JSON feed, decode w/ snake_case keys, map to SwiftData.
* Images: Display remote images with AsyncImage + graceful placeholder; clip with
shapes.
* LazyStacks: Build a scalable feed with ScrollView + LazyVStack + pinned headers.
* Environments: Inject apiBase and theme tokens via custom EnvironmentKey.
* Dark Mode: Use system/semantic colors; asset variants; conditional shadows.
* Custom Styles: Create ButtonStyle, ViewModifier card; apply app-wide.
* Custom Alignments: Align labels/fields with a custom AlignmentID.
* Shapes: Use RoundedRectangle, Capsule, custom badge shape.

# App requirements (acceptance criteria)
A. Authentication & Profile (local/fake)
* A Sign In screen with email/password (no real backend). On “Sign In,” store a mock
token in Keychain (or UserDefaults for simplicity) and transition to the main tabs.
●A Profile screen that shows the signed-in email and allows editing a display name and
avatar URL (string). Persist to SwiftData.
B. Data & Persistence
* Define SwiftData models for User, Car, Order, Like (or Favorite), Wishlist.
* On first run (or on pull-to-refresh), download cars.json, decode it, and upsert into
SwiftData.
* The feed renders cars from SwiftData (not directly from the network response).
C. Browse, Buy, Sell, Like
* Feed tab: ScrollView + LazyVStack grid/rows with image thumbnails, model/year/price.
* Detail screen: Larger image, full specs, “Like” and “Buy now” buttons.
* Buy flow: Creates an Order SwiftData record with a timestamp; show a confirmation.
* Sell tab: A form to create a new listing (model, year, price, image URL). Saves a new
Car in SwiftData with sellerID = current user.
* Likes: Toggle like/favorite per car (persisted). Bonus: show a “Liked” tab or badge.
D. UI/UX & Theming
* Use Dark Mode correctly (semantic colors, minimal shadow in dark).
* Create a CardStyle ViewModifier and apply it to rows and panels.
* Create a PillButtonStyle ButtonStyle and apply to primary actions.
* Use custom alignment to align labels and fields on your Profile or Sell form.
* Use Shapes to clip car images and display a price badge (e.g., Capsule top-right).
E. Environments
* Provide a custom Environment key for apiBase: URL and inject the JSON host URL at
the app root.
* Optionally provide env “tokens” (e.g., cornerRadius, spacing) and use them.

# Rubric (25 points)
* Data & Persistence (6 pts): Models, relationships, import/save logic solid.
* Network & JSON (3 pts): Downloads JSON from remote URL; decodes & maps cleanly.
* UI/UX & Performance (4 pts): Lazy feed, smooth scrolling, AsyncImage placeholders.
* Theming & Styles (3 pts): Dark Mode correctness; Card/Button styles used consistently.
* Forms & Alignment (2 pts): Profile/Sell forms align well using custom alignment.
* Environments (2 pts): apiBase + any theme tokens injected & consumed.
* Style & Documentation (2 pt): Is your code clean and documented?

# Hints & common pitfalls
* Use JSONDecoder.keyDecodingStrategy = .useDefaultKeys and explicit CodingKeys for
snake_case fields you map (image_url → imageURL).
* Don’t generate a fresh UUID() every time for ids you use as keys; use stable ids from
JSON (id field).
* If images don’t load, check http vs https (App Transport Security). Prefer https.
* Test Dark Mode in the simulator: Features → Toggle Appearance.
* Keep heavy work off the main thread; do network fetch on background by default
(URLSession is fine), then import on main actor (SwiftData UI context).
