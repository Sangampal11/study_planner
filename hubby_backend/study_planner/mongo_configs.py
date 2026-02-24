# mongo_configs.py (study_planner folder mein)

from django.contrib.admin.apps import AdminConfig
from django.contrib.auth.apps import AuthConfig
from django.contrib.contenttypes.apps import ContentTypesConfig   # ← yeh sahi hai (ContentTypesConfig with 's')

class MongoAdminConfig(AdminConfig):
    default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'

class MongoAuthConfig(AuthConfig):
    default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'

class MongoContentTypesConfig(ContentTypesConfig):   # ← yahan bhi ContentTypesConfig
    default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'