import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auth_server/src/service/auth_service.dart';
import 'package:auth_server/src/repository/auth_repository.dart';
import 'package:user_server/user_server.dart';
import 'package:core_server/core_server.dart';
import 'package:auth_shared/auth_shared.dart';
import 'package:user_shared/user_shared.dart';
import 'package:auth_server/src/database/auth_database.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockEmailService extends Mock implements EmailService {}

class MockSecurityService extends Mock implements SecurityService<dynamic> {}

class MockCryptService extends Mock implements CryptService {}

void main() {
  late AuthService authService;
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;
  late MockEmailService mockEmailService;
  late MockSecurityService mockSecurityService;
  late MockCryptService mockCryptService;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    mockEmailService = MockEmailService();
    mockSecurityService = MockSecurityService();
    mockCryptService = MockCryptService();

    authService = AuthService(
      authRepo: mockAuthRepo,
      userRepo: mockUserRepo,
      // resourcePermissionRepo is not in constructor shown in file, only auth, user, security, crypt, email.
      // Wait, AuthService constructor in file:
      // AuthService({required AuthRepository authRepo, required UserRepository userRepo, required SecurityService securityService, required CryptService cryptService, required EmailService emailService, ...})
      // It does NOT invoke ResourcePermissionService/Repository.
      securityService: mockSecurityService,
      cryptService: mockCryptService,
      emailService: mockEmailService,
    );

    // Register fallback values if needed
    registerFallbackValue(
      UserCreate(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password',
        name: 'Test User',
      ),
    );
    registerFallbackValue(UserCredentialsCompanion());
    registerFallbackValue(RefreshTokensCompanion());
  });

  group('AuthService - Login', () {
    test('should login successfully with valid credentials', () async {
      // Arrange
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password',
      );
      final user = UserDetails.create(
        id: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: 'Test User',
        email: 'test@example.com',
        username: 'testuser',
        role: UserRole.user,
      );
      // UserCredential (Drift generated)
      final credentials = UserCredential(
        id: 'cred-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        isActive: true,
        userId: 'user-123',
        passwordHash: 'hashed_password',
        failedAttempts: 0,
      );

      when(
        () => mockUserRepo.findByEmail('test@example.com'),
      ).thenAnswer((_) async => Success(user));

      when(
        () => mockAuthRepo.getCredentials('user-123'),
      ).thenAnswer((_) async => credentials);

      when(
        () => mockCryptService.verify('password', 'hashed_password'),
      ).thenReturn(true);

      when(
        () => mockAuthRepo.resetFailedAttempts('user-123'),
      ).thenAnswer((_) async => Future.value());

      // Mock generateToken (JWT) properly
      when(
        () => mockSecurityService.generateToken(any(), any()),
      ).thenAnswer((_) async => Success('fake_token'));

      when(
        () => mockAuthRepo.saveRefreshToken(any()),
      ).thenAnswer((_) async => Future.value()); // void return

      when(
        () => mockAuthRepo.updateLastLogin('user-123'),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await authService.login(request);

      // Assert
      expect(result.isSuccess, isTrue);
      final response = (result as Success<AuthResponse>).value;

      // Since we mocked generateToken to return 'fake_token' for both access and refresh
      expect(response.tokens.accessToken, 'fake_token');
      expect(response.tokens.refreshToken, 'fake_token');
      expect(response.user.id, 'user-123');

      verify(() => mockAuthRepo.saveRefreshToken(any())).called(1);
    });

    test('should fail when user is not found', () async {
      // Arrange
      final request = LoginRequest(
        email: 'unknown@example.com',
        password: 'password',
      );

      when(
        () => mockUserRepo.findByEmail('unknown@example.com'),
      ).thenAnswer((_) async => Failure(DataException('User not found')));

      // Act
      final result = await authService.login(request);

      // Assert
      expect(result.isFailure, isTrue);
      // Check error type
      final failure = result as Failure;
      expect(failure.error, isA<UnauthorizedException>());
      expect(
        (failure.error as UnauthorizedException).message,
        contains('Credenciais inválidas'),
      );
    });

    test('should fail with invalid password', () async {
      // Arrange
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'wrong_password',
      );
      final user = UserDetails.create(
        id: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: 'Test User',
        email: 'test@example.com',
        username: 'testuser',
        role: UserRole.user,
      );
      final credentials = UserCredential(
        id: 'cred-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        isActive: true,
        userId: 'user-123',
        passwordHash: 'hashed_password',
        failedAttempts: 0,
      );

      when(
        () => mockUserRepo.findByEmail('test@example.com'),
      ).thenAnswer((_) async => Success(user));

      when(
        () => mockAuthRepo.getCredentials('user-123'),
      ).thenAnswer((_) async => credentials);

      when(
        () => mockCryptService.verify('wrong_password', 'hashed_password'),
      ).thenReturn(false);

      when(
        () => mockAuthRepo.incrementFailedAttempts('user-123'),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await authService.login(request);

      // Assert
      expect(result.isFailure, isTrue);
      final failure = result as Failure;
      expect(failure.error, isA<UnauthorizedException>());

      verify(() => mockAuthRepo.incrementFailedAttempts('user-123')).called(1);
    });
  });

  group('AuthService - Register', () {
    test('should register successfully', () async {
      // Arrange
      final registerRequest = RegisterRequest(
        name: 'New User',
        email: 'new@example.com',
        username: 'newuser',
        password: 'password123',
      );

      final savedUser = UserDetails.create(
        id: 'user-new',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: 'New User',
        email: 'new@example.com',
        username: 'newuser',
        role: UserRole.user,
        emailVerified: false,
      );

      // User creation mock
      when(
        () => mockUserRepo.create(any()),
      ).thenAnswer((_) async => Success(savedUser));

      // Hashing
      when(
        () => mockCryptService.generateHash('password123'),
      ).thenReturn('hashed_pwd');

      // Save credentials
      when(
        () => mockAuthRepo.saveCredentials(any()),
      ).thenAnswer((_) async => Future.value());

      // Token Generation
      when(
        () => mockSecurityService.generateToken(any(), any()),
      ).thenAnswer((_) async => Success('token_123'));

      when(
        () => mockAuthRepo.saveRefreshToken(any()),
      ).thenAnswer((_) async => Future.value());

      // Email verification
      when(
        () => mockEmailService.sendVerificationEmail(
          to: 'new@example.com',
          userName: 'New User',
          verificationLink: any(named: 'verificationLink'),
        ),
      ).thenAnswer((_) async => Success(null));

      // Act
      final result = await authService.register(registerRequest);

      // Assert
      expect(result.isSuccess, isTrue);
      final response = (result as Success<AuthResponse>).value;
      expect(response.user.email, 'new@example.com');

      verify(() => mockUserRepo.create(any())).called(1);
      verify(() => mockAuthRepo.saveCredentials(any())).called(1);
      verify(
        () => mockEmailService.sendVerificationEmail(
          to: any(named: 'to'),
          userName: any(named: 'userName'),
          verificationLink: any(named: 'verificationLink'),
        ),
      ).called(1);
    });
  });
}
