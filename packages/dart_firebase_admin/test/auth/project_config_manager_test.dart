import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:test/test.dart';

import '../mock_service_account.dart';

void main() {
  group('ProjectConfigManager', () {
    test('projectConfigManager getter returns same instance', () {
      final app = _createMockApp();
      final auth = Auth(app);

      final projectConfigManager1 = auth.projectConfigManager;
      final projectConfigManager2 = auth.projectConfigManager;

      expect(identical(projectConfigManager1, projectConfigManager2), isTrue);
    });

    test('projectConfigManager is instance of ProjectConfigManager', () {
      final app = _createMockApp();
      final auth = Auth(app);

      final projectConfigManager = auth.projectConfigManager;

      expect(projectConfigManager, isA<ProjectConfigManager>());
    });

    test('can access getProjectConfig method', () {
      final app = _createMockApp();
      final auth = Auth(app);
      final projectConfigManager = auth.projectConfigManager;

      // Method should exist and be callable (will fail at runtime without server)
      expect(projectConfigManager.getProjectConfig, isA<Function>());
    });

    test('can access updateProjectConfig method', () {
      final app = _createMockApp();
      final auth = Auth(app);
      final projectConfigManager = auth.projectConfigManager;

      // Method should exist and be callable (will fail at runtime without server)
      expect(projectConfigManager.updateProjectConfig, isA<Function>());
    });

    test(
      'multiple Auth instances have separate ProjectConfigManager instances',
      () {
        final app1 = FirebaseApp.initializeApp(
          name: 'test-app-1',
          options: AppOptions(
            projectId: 'test-project-1',
            credential: Credential.fromServiceAccountParams(
              clientId: 'test-client-id',
              privateKey: mockPrivateKey,
              email: mockClientEmail,
              projectId: 'test-project-1',
            ),
          ),
        );

        final app2 = FirebaseApp.initializeApp(
          name: 'test-app-2',
          options: AppOptions(
            projectId: 'test-project-2',
            credential: Credential.fromServiceAccountParams(
              clientId: 'test-client-id',
              privateKey: mockPrivateKey,
              email: mockClientEmail,
              projectId: 'test-project-2',
            ),
          ),
        );

        final auth1 = Auth(app1);
        final auth2 = Auth(app2);

        final projectConfigManager1 = auth1.projectConfigManager;
        final projectConfigManager2 = auth2.projectConfigManager;

        expect(
          identical(projectConfigManager1, projectConfigManager2),
          isFalse,
        );

        // Cleanup
        app1.close();
        app2.close();
      },
    );
  });
}

FirebaseApp _createMockApp() {
  return FirebaseApp.initializeApp(
    options: AppOptions(
      projectId: 'test-project',
      credential: Credential.fromServiceAccountParams(
        clientId: 'test-client-id',
        privateKey: mockPrivateKey,
        email: mockClientEmail,
        projectId: 'test-project',
      ),
    ),
  );
}
