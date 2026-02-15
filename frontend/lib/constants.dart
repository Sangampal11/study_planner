// lib/constants.dart

/// Backend API ka base URL
///
/// Android Emulator ke liye: 'http://10.0.2.2:8000/api/'
/// Real device (same WiFi pe) ke liye: laptop ka local IP daal (jaise 'http://192.168.1.5:8000/api/')
/// Deploy hone ke baad: 'https://your-backend-domain.com/api/'
const String baseUrl = 'http://10.0.2.2:8000';

/// Agar future mein auth token chahiye to yahan headers define kar sakte hain
const Map<String, String> defaultHeaders = {
  'Content-Type': 'application/json',
  // 'Authorization': 'Bearer your_token_here', // baad mein add kar lenge
};