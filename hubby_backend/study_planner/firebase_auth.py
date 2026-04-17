"""
Firebase Authentication Utility
Handles Firebase user authentication and token verification
"""

import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth as firebase_auth
from django.contrib.auth.models import User
from rest_framework.exceptions import AuthenticationFailed
from dotenv import load_dotenv

load_dotenv()

# Initialize Firebase Admin SDK
def init_firebase():
    """Initialize Firebase Admin SDK with service account credentials"""
    if not firebase_admin._apps:
        # Try to load from serviceAccountKey.json first
        service_account_key_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)), 
            'serviceAccountKey.json'
        )
        
        if os.path.exists(service_account_key_path):
            try:
                cred = credentials.Certificate(service_account_key_path)
                firebase_admin.initialize_app(cred)
                print(f"✅ Firebase initialized with {service_account_key_path}")
                return
            except Exception as e:
                print(f"❌ Failed to initialize with JSON file: {e}")
        
        # Fallback: Build credentials from environment variables
        firebase_creds = {
            "type": os.getenv("FIREBASE_TYPE", "service_account"),
            "project_id": os.getenv("FIREBASE_PROJECT_ID"),
            "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
            "private_key": os.getenv("FIREBASE_PRIVATE_KEY", "").replace("\\n", "\n"),
            "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
            "client_id": os.getenv("FIREBASE_CLIENT_ID"),
            "auth_uri": os.getenv("FIREBASE_AUTH_URI", "https://accounts.google.com/o/oauth2/auth"),
            "token_uri": os.getenv("FIREBASE_TOKEN_URI", "https://oauth2.googleapis.com/token"),
            "auth_provider_x509_cert_url": os.getenv("FIREBASE_AUTH_PROVIDER_X509_CERT_URL", "https://www.googleapis.com/oauth2/v1/certs"),
            "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_X509_CERT_URL"),
        }
        
        cred = credentials.Certificate(firebase_creds)
        firebase_admin.initialize_app(cred)


# Call init on import
try:
    init_firebase()
except Exception as e:
    print(f"⚠️  Warning: Firebase initialization failed: {e}")


def verify_firebase_token(token):
    """
    Verify Firebase ID token and return decoded token data
    
    Args:
        token: Firebase ID token from frontend
        
    Returns:
        Decoded token data with user info
        
    Raises:
        AuthenticationFailed: If token is invalid
    """
    try:
        decoded_token = firebase_auth.verify_id_token(token)
        return decoded_token
    except firebase_auth.InvalidIdTokenError:
        raise AuthenticationFailed("Invalid Firebase token")
    except firebase_auth.ExpiredIdTokenError:
        raise AuthenticationFailed("Firebase token expired")
    except Exception as e:
        raise AuthenticationFailed(f"Token verification failed: {str(e)}")


def get_or_create_django_user(firebase_user_data):
    """
    Get or create a Django User from Firebase user data
    
    Args:
        firebase_user_data: Decoded Firebase token data
        
    Returns:
        Django User instance
    """
    firebase_uid = firebase_user_data.get('uid')
    email = firebase_user_data.get('email', '')
    display_name = firebase_user_data.get('name', email.split('@')[0])
    
    # Try to get existing user by email
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        # Create new user
        username = firebase_uid[:30]  # Firebase UID might be long, truncate
        user = User.objects.create_user(
            username=username,
            email=email,
            first_name=display_name[:30] if display_name else ''
        )
    
    return user


def create_firebase_user(email, password, display_name=''):
    """
    Create a new Firebase user
    
    Args:
        email: User email
        password: User password
        display_name: User display name
        
    Returns:
        Firebase user data
    """
    try:
        firebase_user = firebase_auth.create_user(
            email=email,
            password=password,
            display_name=display_name
        )
        return firebase_user
    except firebase_auth.EmailAlreadyExistsError:
        raise AuthenticationFailed("Email already registered")
    except Exception as e:
        raise AuthenticationFailed(f"Failed to create user: {str(e)}")


def delete_firebase_user(firebase_uid):
    """Delete Firebase user by UID"""
    try:
        firebase_auth.delete_user(firebase_uid)
    except Exception as e:
        print(f"Failed to delete Firebase user: {str(e)}")


def verify_firebase_token(token):
    """
    Verify Firebase ID token and return decoded token data
    
    Args:
        token: Firebase ID token from frontend
        
    Returns:
        Decoded token data with user info
        
    Raises:
        AuthenticationFailed: If token is invalid
    """
    try:
        decoded_token = firebase_auth.verify_id_token(token)
        return decoded_token
    except firebase_auth.InvalidIdTokenError:
        raise AuthenticationFailed("Invalid Firebase token")
    except firebase_auth.ExpiredIdTokenError:
        raise AuthenticationFailed("Firebase token expired")
    except Exception as e:
        raise AuthenticationFailed(f"Token verification failed: {str(e)}")


def get_or_create_django_user(firebase_user_data):
    """
    Get or create a Django User from Firebase user data
    
    Args:
        firebase_user_data: Decoded Firebase token data
        
    Returns:
        Django User instance
    """
    firebase_uid = firebase_user_data.get('uid')
    email = firebase_user_data.get('email', '')
    display_name = firebase_user_data.get('name', email.split('@')[0])
    
    # Try to get existing user by email
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        # Create new user
        username = firebase_uid[:30]  # Firebase UID might be long, truncate
        user = User.objects.create_user(
            username=username,
            email=email,
            first_name=display_name[:30] if display_name else ''
        )
    
    return user


def create_firebase_user(email, password, display_name=''):
    """
    Create a new Firebase user
    
    Args:
        email: User email
        password: User password
        display_name: User display name
        
    Returns:
        Firebase user data
    """
    try:
        firebase_user = firebase_auth.create_user(
            email=email,
            password=password,
            display_name=display_name
        )
        return firebase_user
    except firebase_auth.EmailAlreadyExistsError:
        raise AuthenticationFailed("Email already registered")
    except Exception as e:
        raise AuthenticationFailed(f"Failed to create user: {str(e)}")


def delete_firebase_user(firebase_uid):
    """Delete Firebase user by UID"""
    try:
        firebase_auth.delete_user(firebase_uid)
    except Exception as e:
        print(f"Failed to delete Firebase user: {str(e)}")
