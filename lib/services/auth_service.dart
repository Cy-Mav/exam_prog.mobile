import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un compte ou se connecter
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      // Si le compte n'existe pas, on le crée (Gain de temps !)
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    }
  }

  // Déconnexion (Point 1 du barème)
  Future<void> logout() async => await _auth.signOut();
}
