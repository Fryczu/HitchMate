const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.https.onCall((data, context) => {
  const userId = data.userId;

  return admin.firestore().collection("users").doc(userId).get()
      .then((snapshot) => {
        const userToken = snapshot.data().fcmToken;

        const payload = {
          notification: {
            title: "Masz nową wiadomość!",
            body: "Ktoś pomachał Ci na mapie!",
          },
        };

        return admin.messaging().sendToDevice(userToken, payload);
      })
      .then(() => {
        return {success: true};
      })
      .catch((error) => {
        console.error(error);
        return {success: false};
      });
});

