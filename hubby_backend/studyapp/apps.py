from django.apps import AppConfig

class StudyappConfig(AppConfig):
    default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'
    name = 'studyapp'