/// Tag UI package.
///
/// Provides Flutter UI components for tag management including:
/// - Pages for listing and managing tags
/// - Reusable widgets for displaying and selecting tags
/// - ViewModels for state management
///
/// This package depends on:
/// - `tag_shared` for domain models and business logic
/// - `tag_client` for API communication
library;

// Module
export 'tag_module.dart';

// ViewModels
export 'ui/view_models/tag_view_model.dart';

// Pages
export 'ui/pages/tag_list_page.dart';
export 'ui/pages/tag_form_page.dart';

// Widgets
export 'ui/widgets/tag_card.dart';
export 'ui/widgets/tag_chip.dart';
export 'ui/widgets/tag_selector.dart';
