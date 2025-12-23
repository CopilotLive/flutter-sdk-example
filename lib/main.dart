import 'dart:developer' as developer;

import 'package:flutter/material.dart';
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
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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

                // Cart Items
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
          token:
              'your-kaily-token', // Example token from the provided script
          user: _user,
        ).copyWith(debugMode: true),
      );

      _addLog('SDK initialized successfully');

      // Register example tools
      await _registerTools();

      // Event listening will be set up after WebView bridge is initialized

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

    _addLog(
      'Registered ${KailySDK.instance.getRegisteredTools().length} tools at once',
    );
  }

  Future<KailyToolResult> _handleAddToCart(
    Map<String, dynamic> parameters,
  ) async {
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

  Future<KailyToolResult> _handleGetCartItems(
    Map<String, dynamic> parameters,
  ) async {
    try {
      _addLog('Retrieved cart items (${_cartItems.length} items)');

      return KailyToolResult.success(
        data: {
          'items': _cartItems,
          'count': _cartItems.length,
          'total_value': _cartItems.fold<double>(
            0,
            (sum, item) =>
                sum + (item['price'] as double) * (item['quantity'] as int),
          ),
        },
      );
    } catch (e) {
      _addLog('Get cart items failed: $e');
      return KailyToolResult.failure(error: 'Failed to get cart items: $e');
    }
  }

  Future<KailyToolResult> _handleRemoveFromCart(
    Map<String, dynamic> parameters,
  ) async {
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
          'message':
              'Successfully removed ${removedItem['name']} from your cart!',
        },
      );
    } catch (e) {
      _addLog('Remove from cart failed: $e');
      return KailyToolResult.failure(
        error: 'Failed to remove product from cart: $e',
      );
    }
  }

  Future<KailyToolResult> _handleGetUserInfo(
    Map<String, dynamic> parameters,
  ) async {
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
            developer.log('Conversation loaded successfully');
            break;
          case KailyEventType.conversationFailedToLoad:
            developer.log('Conversation failed to load: ${event.error}');
            break;
          case KailyEventType.toolCall:
            final toolName = event.data?['tool_name'];
            developer.log('Tool called: $toolName');
            break;
          case KailyEventType.toolResult:
            final toolName = event.data?['tool_name'];
            final success = event.data?['success'];
            developer.log(
              'Tool result: $toolName (${success ? 'success' : 'failed'})',
            );
            break;
          case KailyEventType.error:
            developer.log('Error: ${event.error}');
            break;
          default:
            developer.log('Other event: ${event.type.name}');
        }
      },
      onError: (error) {
        developer.log('Event stream error: $error');
      },
    );

    developer.log('Event listening setup complete');
  }

  void _showKailyWidget() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: const Text('Kaily Chat')),
              body: KailyWidget(
                config: KailyConfig.withDefaults(
                  token: 'your-kaily-token',
                  user: _user,
                ).copyWith(debugMode: true),
                onConversationLoaded: () {
                  developer.log(
                    'Widget: Conversation loaded',
                    name: KailyConstants.logTagSDK,
                  );
                  // Set up event listening now that the WebView is ready
                },
                onConversationFailedToLoad: (error) {
                  developer.log(
                    'Widget: Conversation failed to load - $error',
                    name: KailyConstants.logTagSDK,
                    error: error,
                  );
                },
                onTelemetryEvent: (eventType, payload) {
                  developer.log(
                    'Widget: Telemetry - $eventType',
                    name: KailyConstants.logTagSDK,
                  );
                },
                onEvent: (event) {
                  developer.log(
                    'Widget: Event - ${event.type.name}',
                    name: KailyConstants.logTagSDK,
                  );
                },
              ),
            ),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
