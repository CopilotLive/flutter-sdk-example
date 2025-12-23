# Kaily Flutter SDK

[![pub package](https://img.shields.io/pub/v/kaily_flutter_sdk.svg)](https://pub.dev/packages/kaily_flutter_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter SDK for integrating Kaily AI chatbot with dynamic tool registration and execution capabilities. This SDK provides a WebView-based implementation that works across all Flutter platforms.

## ✨ Features

- **🌐 WebView-Based Integration**: Pure Flutter implementation using WebView
- **🛠️ Dynamic Tool Registration**: Register Dart functions that the AI can call in real-time
- **👤 User Management**: Complete user context and authentication support
- **🎨 Customizable Appearance**: Full theming and styling options
- **📡 Real-time Events**: Comprehensive event system for monitoring AI interactions
- **📱 Cross-Platform**: Works on iOS, Android, Web, and Desktop

## 🚀 Quick Start

### 1. Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  kaily_flutter_sdk: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 2. Basic Setup

```dart
import 'package:kaily_flutter_sdk/kaily_flutter_sdk.dart';

void main() {
  runApp(const KailyExampleApp());
}

class KailyExampleApp extends StatelessWidget {
  const KailyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaily Flutter SDK Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  final List<String> _logs = [];
  final List<Map<String, dynamic>> _cartItems = [];

  // Example user data
  final _user = const KailyUser(
    id: 'user_123',
    name: 'John Doe',
    email: 'john.doe@example.com',
    attributes: {'tier': 'premium', 'location': 'San Francisco'},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaily Flutter SDK Example'),
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: _showInfo),
        ],
      ),
      body: Column(
        children: [
          // Status Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getStatusColor(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${_getStatusText()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Control Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _initializeKaily,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Initialize Kaily'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isInitialized ? _showKailyWidget : null,
                      child: const Text('Open Chat'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cart Items Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shopping Cart (${_cartItems.length} items)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_cartItems.isEmpty)
                        const Text('Cart is empty')
                      else
                        ..._cartItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• ${item['name']} (Qty: ${item['quantity']}) - \$${item['price']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Logs Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Logs',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => _logs.clear()),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_error != null) return Colors.red;
    if (_isInitialized) return Colors.green;
    return Colors.orange;
  }

  String _getStatusText() {
    if (_error != null) return 'Error';
    if (_isInitialized) return 'Initialized';
    if (_isLoading) return 'Initializing...';
    return 'Not Initialized';
  }

  Future<void> _initializeKaily() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _addLog('Initializing Kaily SDK...');

    try {
      // Initialize the SDK
      await KailySDK.instance.initialize(
        KailyConfig.withDefaults(
          token: 'your-kaily-token',
          user: _user,
        ).copyWith(debugMode: true),
      );

      _addLog('SDK initialized successfully');

      // Register example tools
      await _registerTools();

      // Set initial context
      await KailySDK.instance.setContext({
        'current_page': 'home',
        'cart_count': _cartItems.length,
        'user_tier': 'premium',
      });

      _addLog('Context set successfully');

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      _addLog('Kaily is ready to use!');
      _setupEventListening();

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _addLog('Initialization failed: $e');
    }
  }

  Future<void> _registerTools() async {
    // Register all tools at once using the new registerTools method
    await KailySDK.instance.registerTools([
      KailyTool(
        name: 'add_to_cart',
        description: 'Add a product to the shopping cart',
        parameters: [
          const KailyToolParameter(
            name: 'product_id',
            type: 'string',
            description: 'The ID of the product to add',
            required: true,
          ),
          const KailyToolParameter(
            name: 'product_name',
            type: 'string',
            description: 'The name of the product',
            required: true,
          ),
          const KailyToolParameter(
            name: 'price',
            type: 'number',
            description: 'The price of the product',
            required: true,
          ),
          const KailyToolParameter(
            name: 'quantity',
            type: 'number',
            description: 'The quantity to add (default: 1)',
            defaultValue: 1,
          ),
        ],
        handler: _handleAddToCart,
      ),
      KailyTool(
        name: 'get_cart_items',
        description: 'Get all items currently in the shopping cart',
        handler: _handleGetCartItems,
      ),
      KailyTool(
        name: 'remove_from_cart',
        description: 'Remove a product from the shopping cart',
        parameters: [
          const KailyToolParameter(
            name: 'product_id',
            type: 'string',
            description: 'The ID of the product to remove',
            required: true,
          ),
        ],
        handler: _handleRemoveFromCart,
      ),
      KailyTool(
        name: 'get_user_info',
        description: 'Get information about the current user',
        handler: _handleGetUserInfo,
      ),
    ]);

    _addLog('Registered ${KailySDK.instance.getRegisteredTools().length} tools at once');
  }

  Future<KailyToolResult> _handleAddToCart(Map<String, dynamic> parameters) async {
    try {
      final productId = parameters['product_id'] as String;
    final productName = parameters['product_name'] as String;
      final price = (parameters['price'] as num).toDouble();
      final quantity = (parameters['quantity'] as num?)?.toInt() ?? 1;

      // Simulate adding to cart
      final cartItem = {
        'id': productId,
        'name': productName,
        'price': price,
        'quantity': quantity,
        'added_at': DateTime.now().toIso8601String(),
      };

      setState(() {
        _cartItems.add(cartItem);
      });

      // Update context
      await KailySDK.instance.setContext({
        'current_page': 'home',
        'cart_count': _cartItems.length,
        'user_tier': 'premium',
      });

      _addLog('Added to cart: $productName (x$quantity)');

    return KailyToolResult.success(
      data: {
        'success': true,
          'product_id': productId,
          'product_name': productName,
          'quantity': quantity,
          'cart_count': _cartItems.length,
        'message': 'Successfully added $productName to your cart!',
      },
    );
    } catch (e) {
      _addLog('Add to cart failed: $e');
      return KailyToolResult.failure(
        error: 'Failed to add product to cart: $e',
      );
    }
  }

  Future<KailyToolResult> _handleGetCartItems(Map<String, dynamic> parameters) async {
    try {
      _addLog('Retrieved cart items (${_cartItems.length} items)');

      return KailyToolResult.success(
        data: {
          'items': _cartItems,
          'count': _cartItems.length,
          'total_value': _cartItems.fold<double>(
            0,
            (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
          ),
        },
      );
    } catch (e) {
      _addLog('Get cart items failed: $e');
      return KailyToolResult.failure(error: 'Failed to get cart items: $e');
    }
  }

  Future<KailyToolResult> _handleRemoveFromCart(Map<String, dynamic> parameters) async {
    try {
      final productId = parameters['product_id'] as String;

      final index = _cartItems.indexWhere((item) => item['id'] == productId);
      if (index == -1) {
        return KailyToolResult.failure(error: 'Product not found in cart');
      }

      final removedItem = _cartItems.removeAt(index);

      // Update context
      await KailySDK.instance.setContext({
        'current_page': 'home',
        'cart_count': _cartItems.length,
        'user_tier': 'premium',
      });

      setState(() {});

      _addLog('Removed from cart: ${removedItem['name']}');

      return KailyToolResult.success(
        data: {
          'success': true,
          'removed_product': removedItem,
          'cart_count': _cartItems.length,
          'message': 'Successfully removed ${removedItem['name']} from your cart!',
        },
      );
    } catch (e) {
      _addLog('Remove from cart failed: $e');
      return KailyToolResult.failure(
        error: 'Failed to remove product from cart: $e',
      );
    }
  }

  Future<KailyToolResult> _handleGetUserInfo(Map<String, dynamic> parameters) async {
    try {
      _addLog('Retrieved user info for: ${_user.name}');

      return KailyToolResult.success(
        data: {
          'user': _user.toJson(),
          'preferences': {
            'theme': 'light',
            'notifications': true,
            'language': 'en',
          },
          'stats': {
            'total_orders': 42,
            'favorite_category': 'electronics',
            'member_since': '2023-01-15',
          },
        },
      );
    } catch (e) {
      _addLog('Get user info failed: $e');
      return KailyToolResult.failure(error: 'Failed to get user info: $e');
    }
  }

  void _setupEventListening() {
    _addLog('Setting up event listening...');

    KailySDK.instance.eventStream.listen(
      (event) {
        _addLog('Event received: ${event.type.name}');
        _addLog('Event data: ${event.data}');
        _addLog('Event source: ${event.source}');

        switch (event.type) {
          case KailyEventType.conversationLoaded:
            _addLog('Conversation loaded successfully');
            break;
          case KailyEventType.conversationFailedToLoad:
            _addLog('Conversation failed to load: ${event.error}');
            break;
          case KailyEventType.toolCall:
            final toolName = event.data?['tool_name'];
            _addLog('Tool called: $toolName');
            break;
          case KailyEventType.toolResult:
            final toolName = event.data?['tool_name'];
            final success = event.data?['success'];
            _addLog('Tool result: $toolName (${success ? 'success' : 'failed'})');
            break;
          case KailyEventType.error:
            _addLog('Error: ${event.error}');
            break;
          default:
            _addLog('Other event: ${event.type.name}');
        }
      },
      onError: (error) {
        _addLog('Event stream error: $error');
      },
    );

    _addLog('Event listening setup complete');
  }

  void _showKailyWidget() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Kaily Chat')),
          body: KailyWidget(
            config: KailyConfig.withDefaults(
              token: 'your-kaily-token',
              user: _user,
            ).copyWith(debugMode: true),
            onConversationLoaded: () {
              _addLog('Widget: Conversation loaded');
            },
            onConversationFailedToLoad: (error) {
              _addLog('Widget: Conversation failed to load - $error');
            },
            onTelemetryEvent: (eventType, payload) {
              _addLog('Widget: Telemetry - $eventType');
            },
            onEvent: (event) {
              _addLog('Widget: Event - ${event.type.name}');
            },
          ),
        ),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaily Flutter SDK Example'),
        content: const Text(
          'This example demonstrates:\n\n'
          '• SDK initialization\n'
          '• Tool registration (single or multiple tools at once)\n'
          '• Event handling\n'
          '• WebView-based chat widget\n'
          '• Real-time JavaScript-Dart communication\n\n'
          'New Feature: registerTools() method:\n'
          '• Single tool: registerTools(KailyTool(...))\n'
          '• Multiple tools: registerTools([KailyTool(...), ...])\n\n'
          'Try asking the AI to:\n'
          '• "Add iPhone to my cart for \$999"\n'
          '• "Show me what\'s in my cart"\n'
          '• "Remove the iPhone from my cart"\n'
          '• "What\'s my user information?"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });

    // Keep only last 100 logs
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }
  }
}
```

## 🛠️ Advanced Usage

### Comprehensive Tool Registration

The example above demonstrates a complete e-commerce shopping cart implementation with multiple tools. Here's how to create your own tools:

```dart
await KailySDK.instance.registerTools([
  KailyTool(
    name: 'add_to_cart',
    description: 'Add a product to the shopping cart',
    parameters: [
      const KailyToolParameter(
        name: 'product_id',
        type: 'string',
        description: 'The ID of the product to add',
        required: true,
      ),
      const KailyToolParameter(
        name: 'product_name',
        type: 'string',
        description: 'The name of the product',
        required: true,
      ),
      const KailyToolParameter(
        name: 'price',
        type: 'number',
        description: 'The price of the product',
        required: true,
      ),
      const KailyToolParameter(
        name: 'quantity',
        type: 'number',
        description: 'The quantity to add (default: 1)',
        defaultValue: 1,
      ),
    ],
    handler: _handleAddToCart,
  ),
  KailyTool(
    name: 'get_cart_items',
    description: 'Get all items currently in the shopping cart',
    handler: _handleGetCartItems,
  ),
  KailyTool(
    name: 'remove_from_cart',
    description: 'Remove a product from the shopping cart',
    parameters: [
      const KailyToolParameter(
        name: 'product_id',
        type: 'string',
        description: 'The ID of the product to remove',
        required: true,
      ),
    ],
    handler: _handleRemoveFromCart,
  ),
  KailyTool(
    name: 'get_user_info',
    description: 'Get information about the current user',
    handler: _handleGetUserInfo,
  ),
]);
```

### Tool Handler Implementation

Each tool handler should return a `KailyToolResult`:

```dart
Future<KailyToolResult> _handleAddToCart(Map<String, dynamic> parameters) async {
  try {
    final productId = parameters['product_id'] as String;
    final productName = parameters['product_name'] as String;
    final price = (parameters['price'] as num).toDouble();
    final quantity = (parameters['quantity'] as num?)?.toInt() ?? 1;

    // Your business logic here
    // Update UI state, database, etc.

    return KailyToolResult.success(
      data: {
        'success': true,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'message': 'Successfully added $productName to your cart!',
      },
    );
  } catch (e) {
    return KailyToolResult.failure(
      error: 'Failed to add product to cart: $e',
    );
  }
}
```

### Event Handling

The example demonstrates comprehensive event handling with logging and UI updates:

```dart
void _setupEventListening() {
  KailySDK.instance.eventStream.listen(
    (event) {
      _addLog('Event received: ${event.type.name}');
      _addLog('Event data: ${event.data}');
      _addLog('Event source: ${event.source}');

      switch (event.type) {
        case KailyEventType.conversationLoaded:
          _addLog('Conversation loaded successfully');
          break;
        case KailyEventType.conversationFailedToLoad:
          _addLog('Conversation failed to load: ${event.error}');
          break;
        case KailyEventType.toolCall:
          final toolName = event.data?['tool_name'];
          _addLog('Tool called: $toolName');
          break;
        case KailyEventType.toolResult:
          final toolName = event.data?['tool_name'];
          final success = event.data?['success'];
          _addLog('Tool result: $toolName (${success ? 'success' : 'failed'})');
          break;
        case KailyEventType.error:
          _addLog('Error: ${event.error}');
          break;
        default:
          _addLog('Other event: ${event.type.name}');
      }
    },
    onError: (error) {
      _addLog('Event stream error: $error');
    },
  );
}
```

### Widget Event Callbacks

The `KailyWidget` also supports direct event callbacks:

```dart
KailyWidget(
  config: config,
  onConversationLoaded: () {
    print('Widget: Conversation loaded');
  },
  onConversationFailedToLoad: (error) {
    print('Widget: Conversation failed to load - $error');
  },
  onTelemetryEvent: (eventType, payload) {
    print('Widget: Telemetry - $eventType');
  },
  onEvent: (event) {
    print('Widget: Event - ${event.type.name}');
  },
)
```

### Context Management

The example shows dynamic context updates that keep the AI informed about your app's current state:

```dart
// Initial context setup
await KailySDK.instance.setContext({
  'current_page': 'home',
  'cart_count': _cartItems.length,
  'user_tier': 'premium',
});

// Update context when cart changes
await KailySDK.instance.setContext({
  'current_page': 'home',
  'cart_count': _cartItems.length,
  'user_tier': 'premium',
});
```

Context is automatically updated in the example when:

- Items are added to the cart
- Items are removed from the cart
- The user navigates to different pages

This ensures the AI always has current information about your app's state.

### UI Features and Debugging

The example includes several UI features that make development and debugging easier:

#### Status Indicators

- **Color-coded status bar**: Green (initialized), Orange (loading), Red (error)
- **Real-time status updates**: Shows current SDK state
- **Error display**: Clear error messages when initialization fails

#### Comprehensive Logging

- **Timestamped logs**: Each log entry includes a timestamp
- **Real-time updates**: Logs appear immediately as events occur
- **Log management**: Automatic cleanup (keeps last 100 logs)
- **Clear functionality**: Users can clear logs manually

#### Interactive Elements

- **Loading states**: Buttons show loading indicators during initialization
- **Disabled states**: Buttons are disabled when appropriate
- **Info dialog**: Helpful information about the example features

#### Live Data Display

- **Shopping cart**: Real-time display of cart items
- **Dynamic updates**: UI updates immediately when tools are called
- **State management**: Proper Flutter state management throughout

### Custom Appearance

Customize the chat widget appearance:

```dart
KailyWidget(
  config: KailyConfig.withDefaults(
    token: 'your-token',
    user: user,
  ).copyWith(
    appearance: KailyAppearance(
      primaryColor: Colors.blue,
      backgroundColor: Colors.white,
      title: 'My Assistant',
      showHeader: true,
    ),
  ),
)
```

## 🎯 Example App Features

The comprehensive example app demonstrates all major SDK features:

### What You Can Try

Once the SDK is initialized, you can ask the AI to:

- **"Add iPhone to my cart for $999"** - Demonstrates tool calling with parameters
- **"Show me what's in my cart"** - Shows data retrieval tools
- **"Remove the iPhone from my cart"** - Demonstrates item removal
- **"What's my user information?"** - Shows user data access
- **"Add 2 laptops to my cart for $1500 each"** - Demonstrates quantity handling

### Key Features Demonstrated

- ✅ **SDK Initialization** with error handling and loading states
- ✅ **Multiple Tool Registration** with comprehensive parameters
- ✅ **Real-time Event Handling** with detailed logging
- ✅ **Dynamic Context Updates** that keep AI informed
- ✅ **UI State Management** with live updates
- ✅ **Error Handling** with user-friendly messages
- ✅ **Debug Mode** with comprehensive logging
- ✅ **Shopping Cart Logic** as a practical business use case

### Example App Structure

```
HomePage
├── Status Bar (color-coded status)
├── Control Buttons (Initialize/Open Chat)
├── Shopping Cart Display (live data)
└── Logs Section (real-time debugging)
```

## 📱 Platform Setup

### Required Permissions

The Kaily Flutter SDK requires specific permissions for WebView functionality and voice features. **No manual plugin registration is needed** - Flutter automatically handles this when you add the SDK dependency.

#### 🔧 Plugin Registration

**Automatic Setup:** The SDK automatically includes and registers the following plugins:

- `flutter_inappwebview` - For WebView functionality
- `permission_handler` - For microphone permissions

Flutter will automatically generate the required plugin registration files when you run `flutter pub get`.

#### 📱 Android Setup

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions for WebView functionality -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

    <!-- Required for voice features (microphone access) -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

    <!-- WebView hardware acceleration -->
    <uses-feature android:name="android.hardware.touchscreen" android:required="false" />

    <application
        android:label="your_app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:networkSecurityConfig="@xml/network_security_config"
        android:enableOnBackInvokedCallback="true">
        <!-- Your app configuration -->
    </application>
</manifest>
```

**Important Notes for Android:**

- The `INTERNET` permission is required for WebView to load web content
- `RECORD_AUDIO` and `MODIFY_AUDIO_SETTINGS` are required for voice features
- The SDK will automatically request microphone permission when needed

#### 🍎 iOS Setup

Add the following permissions to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing app configuration -->

    <!-- Required for WebView network access -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
        <key>NSAllowsArbitraryLoadsInWebContent</key>
        <true/>
    </dict>

    <!-- Required for microphone access (voice features) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app uses the microphone for voice interactions with Kaily AI assistant.</string>

    <!-- Optional: For speech recognition -->
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This app uses speech recognition for voice commands with Kaily AI assistant.</string>
</dict>
</plist>
```

**Important Notes for iOS:**

- `NSAppTransportSecurity` allows WebView to load HTTP content (required for some web services)
- `NSMicrophoneUsageDescription` is required for microphone access - customize the description for your app
- `NSSpeechRecognitionUsageDescription` is optional but recommended for speech features
- The SDK will automatically request microphone permission when needed

#### 🌐 Web Setup

For Flutter Web, no additional permissions are required. The browser will handle microphone permissions automatically when the user interacts with voice features.

#### 🖥️ Desktop Setup

For Flutter Desktop (Windows, macOS, Linux), no additional permissions are required. The system will handle microphone permissions automatically.

### 🎤 Voice Features Integration

The SDK automatically handles microphone permission requests when users interact with voice features in the WebView. Here's how it works:

1. **Automatic Permission Request**: When a user clicks the microphone button in the WebView, the SDK automatically requests microphone permission
2. **User-Friendly Dialogs**: If permission is denied, the SDK shows helpful dialogs to guide users to app settings
3. **Web Widget Notification**: The web widget is automatically notified of permission status changes

**No additional code is required** - the SDK handles all permission logic internally.

### 🔍 Troubleshooting Permissions

If voice features aren't working:

1. **Check Permissions**: Ensure the required permissions are added to your platform files
2. **Test on Device**: Test on a physical device (permissions don't work in simulators)
3. **Check App Settings**: Verify permissions are granted in device settings
4. **Debug Mode**: Enable debug mode in your KailyConfig to see permission request logs

```dart
KailyConfig.withDefaults(
  token: 'your-token',
  user: user,
  debugMode: true, // Enable debug logging
)
```

## 🧪 Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kaily_flutter_sdk/kaily_flutter_sdk.dart';

void main() {
  test('should initialize with valid config', () async {
    final config = KailyConfig.withDefaults(
      token: 'test-token',
      user: KailyUser(id: 'test', name: 'Test User'),
    );

    await KailySDK.instance.initialize(config);
    expect(KailySDK.instance.isInitialized, isTrue);
  });
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by the Kaily team
