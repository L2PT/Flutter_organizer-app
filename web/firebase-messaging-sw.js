// Import and configure the Firebase SDK
// These scripts are made available when the app is served or deployed on Firebase Hosting
// If you do not serve/host your project using Firebase Hosting see https://firebase.google.com/docs/web/setup
importScripts('https://www.gstatic.com/firebasejs/8.3.2/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.3.2/firebase-messaging.js');

var firebaseConfig = {
  apiKey: "AIzaSyD3A8jbx8IRtXvnmoGSwJy2VyRCvo0yjGk",
  authDomain: "com-l2pt-venturiautospurghi.firebaseapp.com",
  databaseURL: "https://com-l2pt-venturiautospurghi.firebaseio.com",
  projectId: "com-l2pt-venturiautospurghi",
  storageBucket: "com-l2pt-venturiautospurghi.appspot.com",
  messagingSenderId: "964614131015",
  appId: "1:964614131015:web:8a10af66f5b15bad589062"
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// If you would like to customize notifications that are received in the
// background (Web app is closed or not in browser focus) then you should
// implement this optional method.
// Keep in mind that FCM will still show notification messages automatically 
// and you should use data messages for custom notifications.
// For more info see: 
// https://firebase.google.com/docs/cloud-messaging/concept-options
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = 'Background Message Title';
  const notificationOptions = {
    body: 'Background Message body.',
    icon: '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle,
    notificationOptions);
});