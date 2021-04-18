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


class CustomPushEvent extends Event {
    constructor(data) {
        super('push')

        Object.assign(this, data)
        this.custom = true
    }
}

/*
 * Overrides push notification data, to avoid having 'notification' key and firebase blocking
 * the message handler from being called
 */
self.addEventListener('push', (e) => {
    console.log("PUSH");
    // Skip if event is our own custom event
    if (e.custom) return;

    // Kep old event data to override
    let oldData = e.data

    // Create a new event to dispatch, pull values from notification key and put it in data key,
    // and then remove notification key
    let newEvent = new CustomPushEvent({
        data: {
            ehheh: oldData.json(),
            json() {
                let newData = oldData.json()
                newData.data = {
                    ...newData.data,
                    ...newData.notification
                }
                delete newData.notification
                return newData
            },
        },
        waitUntil: e.waitUntil.bind(e),
    })

    // Stop event propagation
    e.stopImmediatePropagation()

    // Dispatch the new wrapped event
    dispatchEvent(newEvent)
});

self.addEventListener('notificationclick', (event) => {
  console.log("NOTIFICA CLICCATA LISTENER");
  let url = event.notification.data.url;
  event.notification.close();
  event.waitUntil(
      clients.matchAll({type: 'window'}).then( windowClients => {
      // Check if there is already a window/tab open with the target URL
          for (var i = 0; i < windowClients.length; i++) {
              var client = windowClients[i];
              // If so, just focus it.
              if (client.url === url && 'focus' in client) {
                  return client.focus();
              }
          }
          // If not, then open the target URL in a new window/tab.
          if (clients.openWindow) {
              return clients.openWindow(url);
          }
      })
  );
});



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
  const notificationTitle = payload.data.title.split("\"")[1];
  const notificationOptions = {
    body: payload.data.title.split("\"")[0],
    icon: '../assets/icona-app.png',
    data: { url:'https://gestionaleventuribruno.it/#/' },
  };

  self.registration.showNotification(notificationTitle,notificationOptions);
});

