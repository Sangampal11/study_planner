# studyapp/urls.py
from django.urls import path
from .views import (
    FirebaseRegisterAPIView,
    FirebaseLoginAPIView,
    LogoutAPIView,
    UserProfileAPIView,
    GenerateTimetableAPIView,
    TaskListAPIView,
    TaskDetailAPIView,
    CreateTaskAPIView
)

urlpatterns = [
    # Firebase Auth endpoints
    path('auth/register/', FirebaseRegisterAPIView.as_view(), name='firebase-register'),
    path('auth/login/', FirebaseLoginAPIView.as_view(), name='firebase-login'),
    path('auth/logout/', LogoutAPIView.as_view(), name='logout'),
    path('auth/profile/', UserProfileAPIView.as_view(), name='profile'),

    # Timetable endpoints
    path('generate-timetable/', GenerateTimetableAPIView.as_view(), name='generate-timetable'),

    # Task endpoints
    path('tasks/', TaskListAPIView.as_view(), name='task-list'),
    path('tasks/create/', CreateTaskAPIView.as_view(), name='create-task'),
    path('tasks/<str:pk>/', TaskDetailAPIView.as_view(), name='task-detail'),
]