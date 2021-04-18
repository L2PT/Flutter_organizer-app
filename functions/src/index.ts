import * as functions from "firebase-functions";

const axios = require('axios');

exports.getDataFromUrl = functions.https.onCall(async (data, context) => {
    const url = data.url;
    try {
        const info = await axios.get(url);
        return info.data;
    } catch (error) {
        return (error);
    }
});
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
