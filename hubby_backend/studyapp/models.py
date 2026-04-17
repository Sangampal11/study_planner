from django.db import models
from django.contrib.auth.models import User

class Task(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tasks')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    completed = models.BooleanField(default=False)
    date = models.CharField(max_length=10, blank=True, null=True)          # 'YYYY-MM-DD'
    start_time = models.CharField(max_length=5, blank=True)     # 'HH:MM'
    end_time = models.CharField(max_length=5, blank=True)       # 'HH:MM'
    subject = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.user.username}"