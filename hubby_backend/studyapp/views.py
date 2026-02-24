# studyapp/views.py
from dotenv import load_dotenv
from .models import Task
from .serializers import TaskSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from datetime import datetime, timedelta
from dateutil.parser import parse
import random
import json
import os
import google.generativeai as genai
from google.generativeai import configure, GenerativeModel

# Configure Gemini API
configure(api_key=os.getenv("GEMINI_API_KEY"))

load_dotenv()

class GenerateTimetableAPIView(APIView):
    def post(self, request):
        try:
            exam_date_str = request.data.get('exam_date')
            daily_hours = float(request.data.get('daily_hours', 4.0))
            subjects_data = request.data.get('subjects', [])
            strength = request.data.get('strength', 'Moderate')
            class_level = request.data.get('class_level', '12').strip()

            print(f"DEBUG: Received - exam_date={exam_date_str}, hours={daily_hours}, class={class_level}, subjects={subjects_data}, strength={strength}")

            if not exam_date_str or not subjects_data:
                return Response({"error": "exam_date aur subjects zaroori hain"}, status=400)

            if strength not in ['Weak', 'Moderate', 'Easy']:
                return Response({"error": "strength must be Weak, Moderate or Easy"}, status=400)

            exam_date = parse(exam_date_str).date()
            today = datetime.now().date()
            days_left = (exam_date - today).days
            if days_left <= 0:
                return Response({"error": "Exam date future mein honi chahiye"}, status=400)

            # Subject names ko string mein convert kar
            subject_names = ", ".join([s['name'].strip() for s in subjects_data]) if subjects_data else "Unknown"
            main_subject = subjects_data[0]['name'].strip() if subjects_data else "Unknown"

            # Gemini prompt – refined, strength ke hisaab se time adjust
            prompt = f"""
    You are an expert NCERT Class {class_level} CBSE study planner for {subject_names}.
    Exam date: {exam_date_str}
    Daily study hours: {daily_hours}
    Subject strength: {strength} (Weak: 3x time, Moderate: 2x time, Easy: 1x time)

    Create complete realistic timetable for the entire subject(s).
    - Cover all major chapters in NCERT Class 12 {subject_names}
    - Break each chapter into 1-hour daily tasks: read theory, solve examples, exercises, revision
    - Adjust time/slots based on strength (more for weak topics)
    - Include short breaks every 3-4 slots
    - Last 20% time: full revision + practice questions + mock tests
    - Dates MUST be in "YYYY-MM-DD" format, start from {today.isoformat()} to exam date
    - "start_time" and "end_time" in "HH:MM" format (e.g., "09:00", "10:00")
    - Return ONLY valid JSON array (no extra text, no markdown):
    [
    {{
        "title": "Ch1: Relations and Functions - Types of Relations",
        "description": "Read theory + solve Ex 1.1 Q1-5",
        "date": "2026-02-15",
        "start_time": "09:00",
        "end_time": "10:00",
        "subject": "{main_subject}",
        "chapter": 1
    }}
    - Every task MUST have "subject": "{main_subject}"
    - Do not change or omit the subject name
    ]
    """

            # Gemini call – gemini-2.5-flash use kar (tere list mein available hai)
            model = genai.GenerativeModel('gemini-3-flash-preview')  # ← Yeh update kiya
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    response_mime_type="application/json"
                )
            )

            ai_response = response.text.strip()
            print(f"DEBUG: Gemini response (first 300 chars): {ai_response[:300]}...")

            # Parse JSON
            try:
                parsed = json.loads(ai_response)
                tasks_list = parsed if isinstance(parsed, list) else parsed.get("tasks", [])
                if not isinstance(tasks_list, list):
                    raise ValueError("Response is not a JSON array/list")
            except Exception as e:
                print(f"JSON parse error: {e}\nRaw response: {ai_response}")
                return Response({"error": "Gemini response invalid JSON"}, status=500)

            # Save tasks to DB with default values
            saved_count = 0
            tasks_data = []
            for task_data in tasks_list:
                try:
                    # Default values agar missing
                    date_value = task_data.get('date') or today.isoformat()
                    start_time_value = task_data.get('start_time') or "09:00"
                    end_time_value = task_data.get('end_time') or "10:00"

                    task = Task.objects.create(
                        title=task_data.get('title', 'Untitled Task'),
                        description=task_data.get('description', ''),
                        date=date_value,
                        start_time=start_time_value,
                        end_time=end_time_value,
                        subject=main_subject,
                        completed=False,
                    )
                    saved_count += 1
                    print(f"✅ Gemini Task saved: {task.title} (Date: {date_value})")
                    tasks_data.append(TaskSerializer(task).data)
                except Exception as e:
                    print(f"Save error: {e}")

            print(f"DEBUG: Total saved: {saved_count}/{len(tasks_list)}")

            return Response({
                "message": f"Timetable generated for {subject_names}! {saved_count} tasks saved",
                "total_tasks": saved_count,
                "tasks": tasks_data
            }, status=201)

        except Exception as e:
            import traceback
            traceback.print_exc()
            print(f"❌ Overall error: {str(e)}")
            return Response({"error": str(e)}, status=500)
    # TaskListAPIView same rahega
class TaskListAPIView(APIView):
    def get(self, request):
        try:
            print("DEBUG: Fetching tasks from DB...")
            tasks = Task.objects.all()
            count = tasks.count()
            print(f"DEBUG: DB returned {count} tasks")
            serializer = TaskSerializer(tasks, many=True)
            unique_subjects = tasks.values_list('subject', flat=True).distinct()
            print(f"DEBUG: Unique subjects in DB: {list(unique_subjects)}")
            return Response({
                "tasks": serializer.data,
                "total": count,
                "pending": tasks.filter(completed=False).count(),
                "completed": tasks.filter(completed=True).count(),
            })
        except Exception as e:
            import traceback
            print("TASK LIST ERROR:")
            traceback.print_exc()
            return Response({
                "error": str(e),
                "detail": "Check server logs for full traceback"
            }, status=500)