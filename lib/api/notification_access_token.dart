import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "pushnotifications-8858c",
          "private_key_id": "f95c3c35a7e7149070ea374186832e18fdbb8992",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC5+KWQK6pQKVlV\nHg0MVTuCidWXLBXMpqqF3qMgC81fZks2GgLwwplPBeRpjy63kuPLUkGqLUUuO1yQ\nfWGpv4G/6k/635m+aWRGMEyZNYctgfAxJmfE7tOQSGLW4b0HtPue9jsedImgTYvk\nM+aviSv8QpmzdL67cBZhWjX04aiWyJQ8BubJSG+6Wo6E+kQCjsn8k6x6cfpJfv0l\n3kd8Y9ZpoLvZcFU8gVwv2h9Hb+6fDMxg8EqdE8737zyxVwrU7dlsJSzf6NzroYlL\nqBEQ4KhYu056cvlWP/0ynKjExRaH1d5tNkHcDZq/bcy6TVu7vyXj/hhUkVOBgWkY\n+Ca+ObFzAgMBAAECggEAAsma/wiN2qUUBWDtmc65P/aoRfDPjta8su79tkrsVCQT\nYoc3SLvnUmDokJB93HCONjZQbP2VY4uuPS2JRjhsTcp0UnKsOkdtd66Hp2WUViFJ\neWMgUQ+yCh/w+KmU4hsGCSxFrJTbRJTaUPGvi9gG2cF3I6fPUr3rsp/d3oLMunMr\n9RFSA/iKFGIOY0Zvx7jMGb7QcysbtJarltBCA64pQypsO4s0l3dCVyGfCAv/WeKV\nn5NinXsziW2snrA97tX7RHDTJ3Vx3OR6yL6uri2C5iCrJPqJENWSQrTUkxR64O14\nR6+Pl220xkPfEAn+00zKhKrqzTJ09V+DaOva2N9/4QKBgQD4WDrsj3I2jUEx9jSK\nZHhJ7b5AbG9BbIZMA48os4V++oraoxGdcrZBLk44QOorEmS/ZhvQM7skymab15w+\nrCw7A+exStc7r5oBX3/aICvoQRrRTchn/5A0xUx84/170Ott91yIYRYmCEENo/sQ\nGouQh2aWeKpdFJ70xCpu6vs88QKBgQC/tDUnJcynmwnfNSubWJ3jCG16IcIJ0Pj+\nO80fq1/gbStn9A/6756t+MhoMqTYg+ZKF9d4A5W6bor2D3M65Ug8vpAc6L2Lbfnj\n23GYGFrSbb0r3wC6raYz5bBC1aV52+roCXsNkkGs1vlScE00npvJGjK0eSceFNnp\nOqyYRrAkowKBgCYPf5hZs6tgoqlBjnPXSggqg4nkFHj2ZO6pbPtT6BW52CYB7+Ut\ne3kp25sLd9f6Da63u3OBOiE9U9R2it+gC3dP9eZaDfp7wyKKvFF1tMT3lWCWhyxJ\nIpSz2DEbz/F1518HFgtgtcBGa5Hnm8awCsuvtK1C+Pki++mPVuGA6dhBAoGANCMu\n0ZbWMj9YT/yF/5n6VuTT4YOM4l6TWZGqGBLj4IXQaFVYg0boQSiIWM5tRvWYjE4v\nq9RNxIaMBJ/vFvWE0ACD8VjbNDCU5gOowVTeXpy59lSQPjU8HqE5bvPsLVhCaxko\n/mfotLlC1cj1NnpspCUb5TmOCgBhw6zRhBi1j0ECgYEAh8XFn/LWaawqk5Aahe+9\nxIYrfU6g6ey1EG73PUZ7foAz/cAcf2xMbarw1gxna1Ohec/sCmajLetA1AHjOtGF\nKoBgGTcsGrnGUIkuECcHzFuh+KOa9TNRW8eK1ftL8J0dG6D1I+b6+prUVsZVUXm6\ntcQVAzGhuosVlVn9Pai6wSI=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-zllvj@pushnotifications-8858c.iam.gserviceaccount.com",
          "client_id": "111013475683567888753",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zllvj%40pushnotifications-8858c.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
