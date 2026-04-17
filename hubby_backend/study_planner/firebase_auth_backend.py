"""
Firebase Token Authentication for Django REST Framework
"""

from rest_framework.authentication import TokenAuthentication
from rest_framework.exceptions import AuthenticationFailed
from study_planner.firebase_auth import verify_firebase_token, get_or_create_django_user


class FirebaseAuthentication(TokenAuthentication):
    """
    Firebase token authentication for REST API
    Expects Authorization header: "Bearer <firebase_id_token>"
    """
    keyword = 'Bearer'

    def authenticate(self, request):
        auth = request.META.get('HTTP_AUTHORIZATION', '').split()

        if not auth or auth[0].lower() != self.keyword.lower():
            return None

        if len(auth) == 1:
            raise AuthenticationFailed('Invalid token header. No credentials provided.')
        elif len(auth) > 2:
            raise AuthenticationFailed('Invalid token header. Token string should not contain spaces.')

        token = auth[1]

        try:
            # Verify Firebase token
            firebase_user_data = verify_firebase_token(token)
            
            # Get or create Django user
            user = get_or_create_django_user(firebase_user_data)
            
            return (user, token)
        except AuthenticationFailed as e:
            raise e
        except Exception as e:
            raise AuthenticationFailed(f'Invalid token: {str(e)}')

    def authenticate_header(self, request):
        return self.keyword
