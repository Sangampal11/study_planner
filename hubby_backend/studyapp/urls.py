# studyapp/urls.py
from django.urls import path
from .views import GenerateTimetableAPIView, TaskListAPIView  # name bhi correct kiya

urlpatterns = [
    path('generate-timetable/', GenerateTimetableAPIView.as_view(), name='generate-timetable'),
    path('tasks/',TaskListAPIView.as_view(),name='task-list'),  # naya endpoint for tasks list
]