from rest_framework import serializers
from .models import Task

class TaskSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='pk', read_only=True)
    class Meta:
        model=Task
        fields=['id','title','description','completed','created_at','subject','date','start_time','end_time']