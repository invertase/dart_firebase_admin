const { initializeApp } = require("firebase/app");
const {
  getAuth,
  signInWithEmailAndPassword,
  signOut,
} = require("firebase/auth");

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCyxPmn7XCrAgnW2AnDjr9VWWXJ1AX-ouQ",
  authDomain: "dart-firebase-admin.firebaseapp.com",
  databaseURL:
    "https://dart-firebase-admin-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "dart-firebase-admin",
  storageBucket: "dart-firebase-admin.firebasestorage.app",
  messagingSenderId: "559949546715",
  appId: "1:559949546715:web:86bc35cdf9e2633c0ab8fe",
};

const firebase = initializeApp(firebaseConfig);
const auth = getAuth(firebase);

async function main() {
  try {
    auth.setPersistence("NONE");

    const user = await signInWithEmailAndPassword(
      auth,
      "foo@google.com",
      "123456"
    );

    const token = await user.user.getIdToken(true);
    console.log(token);
  } finally {
    await signOut(auth);
  }
}
main();
