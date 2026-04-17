/// MediSync — auth_onboarding feature barrel export.
///
/// Import this single file to access entities, use-cases, providers,
/// and screens from the auth_onboarding module.
library auth_onboarding;

// ── Domain ───────────────────────────────────────────────────────────────────
export 'domain/entities/medical_staff_entity.dart';
export 'domain/entities/clinic_entity.dart';
export 'domain/entities/invite_entity.dart';

export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/clinic_repository.dart';
export 'domain/repositories/invite_repository.dart';

export 'domain/usecases/sign_in_with_google.dart';
export 'domain/usecases/sign_up_with_email.dart';
export 'domain/usecases/login_with_email.dart';
export 'domain/usecases/logout.dart';
export 'domain/usecases/create_clinic.dart';
export 'domain/usecases/add_staff.dart';
export 'domain/usecases/accept_invite.dart';
export 'domain/usecases/upload_documents.dart';
export 'domain/usecases/switch_clinic.dart';

// ── Data ─────────────────────────────────────────────────────────────────────
export 'data/models/medical_staff_model.dart';
export 'data/models/clinic_model.dart';
export 'data/models/invite_model.dart';

// ── Presentation ─────────────────────────────────────────────────────────────
export 'presentation/providers/auth_provider.dart';
export 'presentation/providers/user_provider.dart';
export 'presentation/providers/clinic_provider.dart';
export 'presentation/providers/invite_provider.dart';

export 'presentation/screens/splash_screen.dart';
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/register_screen.dart';
export 'presentation/screens/role_selection_screen.dart';
export 'presentation/screens/clinic_creation_screen.dart';
export 'presentation/screens/staff_invite_screen.dart';
export 'presentation/screens/document_upload_screen.dart';
export 'presentation/screens/clinic_switcher_screen.dart';

export 'presentation/widgets/auth_form_card.dart';
export 'presentation/widgets/clinic_card.dart';
export 'presentation/widgets/document_upload_tile.dart';
export 'presentation/widgets/google_sign_in_button.dart';
export 'presentation/widgets/invite_tile.dart';
export 'presentation/widgets/role_selection_card.dart';
