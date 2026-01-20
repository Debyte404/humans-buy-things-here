import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

if (!serviceAccountPath) {
  console.warn('FIREBASE_SERVICE_ACCOUNT_PATH not set in .env');
} else {
  try {
    const serviceAccount = JSON.parse(
      readFileSync(resolve(serviceAccountPath), 'utf8')
    );

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log('Firebase Admin SDK initialized');
  } catch (error) {
    console.error(`Error initializing Firebase Admin SDK: ${error.message}`);
    console.warn('Authentication middleware will fail until Firebase is configured.');
  }
}

export default admin;
