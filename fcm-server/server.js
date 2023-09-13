const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const serviceAccount = require('./hitchmate-ad490-firebase-adminsdk-nh6sk-b1d6365ee8.json');

// Inicjalizacja Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(bodyParser.json()); // Aby obsługiwać żądania JSON

// Funkcja do wysyłania powiadomień
function sendNotification(fcmToken, payload) {
  admin.messaging().sendToDevice(fcmToken, payload)
    .then(response => {
      console.log('Successfully sent message:', response);
    })
    .catch(error => {
      console.log('Error sending message:', error);
    });
}

// Endpoint do zapisywania tokena (przykładowy)
app.post('/api/save-token', (req, res) => {
    const token = req.body.token;
    
    if (!token) {
        return res.status(400).send({error: 'Token is missing'});
    }
    
    // W tym miejscu można zdecydować się na zapisanie tokena w bazie danych, ale w przykładzie zakładamy, że tylko logujemy go
    console.log("Otrzymano token: ", token);

    // Opcjonalnie: wysyłanie próbnego powiadomienia do otrzymanego tokena
    const samplePayload = {
      notification: {
        title: 'Tytuł powiadomienia',
        body: 'Treść powiadomienia'
      }
    };
    sendNotification(token, samplePayload);
    
    res.send({success: true});
});

const PORT = 3000; 
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

