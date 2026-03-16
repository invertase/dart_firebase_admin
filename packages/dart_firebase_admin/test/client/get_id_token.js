/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
