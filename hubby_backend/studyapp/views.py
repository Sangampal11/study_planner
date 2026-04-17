# studyapp/views.py
from dotenv import load_dotenv
from .models import Task
from .serializers import TaskSerializer, RegisterSerializer, UserSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status
from datetime import datetime, timedelta
from dateutil.parser import parse
import random
import re
import json
import traceback
import os
import google.generativeai as genai
from google.generativeai import configure, GenerativeModel
from django.contrib.auth.models import User

# Configure Gemini API
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

load_dotenv()

class FirebaseRegisterAPIView(APIView):
    """User registration endpoint with email/password"""
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            email = request.data.get('email')
            password = request.data.get('password')
            password2 = request.data.get('password2')
            
            if not email or not password or not password2:
                return Response({
                    'error': 'Email and passwords are required'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            if password != password2:
                return Response({
                    'error': 'Passwords do not match'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            if len(password) < 6:
                return Response({
                    'error': 'Password must be at least 6 characters'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Check if user already exists
            if User.objects.filter(email=email).exists():
                return Response({
                    'error': 'Email already registered'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Create user
            username = email.split('@')[0]  # Use email prefix as username
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password
            )
            
            # Generate token
            from rest_framework_simplejwt.tokens import RefreshToken
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'message': 'User registered successfully',
                'user': UserSerializer(user).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)


class FirebaseLoginAPIView(APIView):
    """User login endpoint with email/password"""
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            email = request.data.get('email')
            password = request.data.get('password')
            
            if not email or not password:
                return Response({
                    'error': 'Email and password are required'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Find user by email
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({
                    'error': 'Invalid email or password'
                }, status=status.HTTP_401_UNAUTHORIZED)
            
            # Check password
            if not user.check_password(password):
                return Response({
                    'error': 'Invalid email or password'
                }, status=status.HTTP_401_UNAUTHORIZED)
            
            # Generate token
            from rest_framework_simplejwt.tokens import RefreshToken
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'message': 'Login successful',
                'user': UserSerializer(user).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)


class UserProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LogoutAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response({
            'message': 'Logout successful'
        }, status=status.HTTP_200_OK)

class GenerateTimetableAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            exam_date_str = request.data.get('exam_date')
            daily_hours = float(request.data.get('daily_hours', 4.0))
            subjects_data = request.data.get('subjects', [])
            strength = request.data.get('strength', 'Moderate')
            class_level = request.data.get('class_level', '12').strip()

            print("API KEY:", os.getenv("GEMINI_API_KEY"))

            print(f"DEBUG: Received - exam_date={exam_date_str}, hours={daily_hours}, class={class_level}, subjects={subjects_data}, strength={strength}")

            # ✅ Validation
            if not exam_date_str or not subjects_data:
                return Response({"error": "exam_date aur subjects zaroori hain"}, status=400)

            if strength not in ['Weak', 'Moderate', 'Easy']:
                return Response({"error": "strength must be Weak, Moderate or Easy"}, status=400)

            exam_date = parse(exam_date_str).date()
            today = datetime.now().date()

            days_left = (exam_date - today).days
            if days_left <= 0:
                return Response({"error": "Exam date future mein honi chahiye"}, status=400)

            # ✅ Subjects processing
            subject_names = ", ".join([s['name'].strip() for s in subjects_data])
            main_subject = subjects_data[0]['name'].strip()

            # ✅ Prompt
            prompt = f"""
You are an expert NCERT Class {class_level} CBSE study planner for {subject_names}.

Exam date: {exam_date_str}
Daily study hours: {daily_hours}
Subject strength: {strength} (Weak: 3x time, Moderate: 2x time, Easy: 1x time)

Create a complete realistic timetable.

Rules:
- Cover all major chapters
- Break into 1-hour tasks
- Include revision in last 20%
- Add breaks after 3-4 slots
- Dates format: YYYY-MM-DD
- Time format: HH:MM
- Start from {today.isoformat()}

Return ONLY JSON array:
[
{{
"title": "Chapter Name",
"description": "Task details",
"date": "2026-02-15",
"start_time": "09:00",
"end_time": "10:00",
"subject": "{main_subject}"
}}
]
"""

            # ✅ Gemini Setu
            model = genai.GenerativeModel('models/gemini-2.5-flash-lite')

            response = model.generate_content(
                prompt,
                generation_config={
                    "temperature": 0.7,
                    "response_mime_type": "application/json"
                }
            )

            ai_response = response.text.strip()
            print("DEBUG Gemini Raw:", ai_response[:500])

            # ✅ JSON SAFE PARSING
            try:
                match = re.search(r'\[.*\]', ai_response, re.DOTALL)
                if match:
                    ai_response = match.group(0)

                tasks_list = json.loads(ai_response)

                if not isinstance(tasks_list, list):
                    raise ValueError("Not a list")

            except Exception as e:
                print("❌ JSON ERROR:", e)
                return Response({
                    "error": "Invalid AI JSON response",
                    "raw": ai_response[:300]
                }, status=500)

            # ✅ SAVE TO DB
            saved_count = 0
            tasks_data = []

            for task_data in tasks_list:
                try:
                    task = Task.objects.create(
                        user=request.user,   # 🔥 THIS LINE FIXES EVERYTHING
                        title=task_data.get('title', 'Untitled'),
                        description=task_data.get('description', ''),
                        date=task_data.get('date', today),
                        start_time=task_data.get('start_time', "09:00"),
                        end_time=task_data.get('end_time', "10:00"),
                        subject=main_subject,
                        completed=False,
                    )
                    tasks_data.append(TaskSerializer(task).data)
                    saved_count += 1

                except Exception as e:
                    print("Save error:", e)

            print(f"✅ Saved {saved_count} tasks")

            return Response({
                "message": "Timetable generated successfully 🚀",
                "total_tasks": saved_count,
                "tasks": tasks_data
            }, status=201)

        except Exception as e:
            traceback.print_exc()
            return Response({"error": str(e)}, status=500)
class TaskListAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            print("DEBUG: Fetching tasks from DB...")
            tasks = Task.objects.filter(user=request.user)
            count = tasks.count()
            print(f"DEBUG: DB returned {count} tasks for user {request.user.username}")
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


class TaskDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            task = Task.objects.get(pk=pk, user=request.user)
            serializer = TaskSerializer(task)
            return Response(serializer.data)
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)

    def put(self, request, pk):
        try:
            task = Task.objects.get(pk=pk, user=request.user)
            serializer = TaskSerializer(task, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=400)
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)

    def delete(self, request, pk):
        try:
            task = Task.objects.get(pk=pk, user=request.user)
            task.delete()
            return Response({"message": "Task deleted successfully"}, status=204)
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)


class CreateTaskAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            data = request.data.copy()
            data['user'] = request.user.id

            # Manually create task
            task = Task.objects.create(
                user=request.user,
                title=data.get('title', 'Untitled'),
                description=data.get('description', ''),
                date=data.get('date', ''),
                start_time=data.get('start_time', ''),
                end_time=data.get('end_time', ''),
                subject=data.get('subject', ''),
                completed=data.get('completed', False)
            )

            serializer = TaskSerializer(task)
            return Response(serializer.data, status=201)
        except Exception as e:
            return Response({"error": str(e)}, status=400)

class UserProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LogoutAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response({
            'message': 'Logout successful'
        }, status=status.HTTP_200_OK)

# class GenerateTimetableAPIView(APIView):
#     permission_classes = [IsAuthenticated]

#     def post(self, request):
#         try:
#             exam_date_str = request.data.get('exam_date')
#             daily_hours = float(request.data.get('daily_hours', 4.0))
#             subjects_data = request.data.get('subjects', [])
#             strength = request.data.get('strength', 'Moderate')
#             class_level = request.data.get('class_level', '12').strip()

#             print(f"DEBUG: Received - exam_date={exam_date_str}, hours={daily_hours}, class={class_level}, subjects={subjects_data}, strength={strength}")

#             if not exam_date_str or not subjects_data:
#                 return Response({"error": "exam_date aur subjects zaroori hain"}, status=400)

#             if strength not in ['Weak', 'Moderate', 'Easy']:
#                 return Response({"error": "strength must be Weak, Moderate or Easy"}, status=400)

#             exam_date = parse(exam_date_str).date()
#             today = datetime.now().date()
#             days_left = (exam_date - today).days
#             if days_left <= 0:
#                 return Response({"error": "Exam date future mein honi chahiye"}, status=400)

#             # Subject names ko string mein convert kar
#             subject_names = ", ".join([s['name'].strip() for s in subjects_data]) if subjects_data else "Unknown"
#             main_subject = subjects_data[0]['name'].strip() if subjects_data else "Unknown"

#             # Gemini prompt – refined, strength ke hisaab se time adjust
#             prompt = f"""
#     You are an expert NCERT Class {class_level} CBSE study planner for {subject_names}.
#     Exam date: {exam_date_str}
#     Daily study hours: {daily_hours}
#     Subject strength: {strength} (Weak: 3x time, Moderate: 2x time, Easy: 1x time)

#     Create complete realistic timetable for the entire subject(s).
#     - Cover all major chapters in NCERT Class 12 {subject_names}
#     - Break each chapter into 1-hour daily tasks: read theory, solve examples, exercises, revision
#     - Adjust time/slots based on strength (more for weak topics)
#     - Include short breaks every 3-4 slots
#     - Last 20% time: full revision + practice questions + mock tests
#     - Dates MUST be in "YYYY-MM-DD" format, start from {today.isoformat()} to exam date
#     - "start_time" and "end_time" in "HH:MM" format (e.g., "09:00", "10:00")
#     - Return ONLY valid JSON array (no extra text, no markdown):
#     [
#     {{
#         "title": "Ch1: Relations and Functions - Types of Relations",
#         "description": "Read theory + solve Ex 1.1 Q1-5",
#         "date": "2026-02-15",
#         "start_time": "09:00",
#         "end_time": "10:00",
#         "subject": "{main_subject}",
#         "chapter": 1
#     }}
#     - Every task MUST have "subject": "{main_subject}"
#     - Do not change or omit the subject name
#     ]
#     """

#             # Gemini call
#             model = genai.GenerativeModel('gemini-3-flash-preview')
#             response = model.generate_content(
#                 prompt,
#                 generation_config=genai.GenerationConfig(
#                     response_mime_type="application/json"
#                 )
#             )

#             ai_response = response.text.strip()
#             print(f"DEBUG: Gemini response (first 300 chars): {ai_response[:300]}...")

#             # Parse JSON
#             try:
#                 parsed = json.loads(ai_response)
#                 tasks_list = parsed if isinstance(parsed, list) else parsed.get("tasks", [])
#                 if not isinstance(tasks_list, list):
#                     raise ValueError("Response is not a JSON array/list")
#             except Exception as e:
#                 print(f"JSON parse error: {e}\nRaw response: {ai_response}")
#                 return Response({"error": "Gemini response invalid JSON"}, status=500)

#             # Save tasks to DB with user association
#             saved_count = 0
#             tasks_data = []
#             for task_data in tasks_list:
#                 try:
#                     # Default values agar missing
#                     date_value = task_data.get('date') or today.isoformat()
#                     start_time_value = task_data.get('start_time') or "09:00"
#                     end_time_value = task_data.get('end_time') or "10:00"

#                     task = Task.objects.create(
#                         user=request.user,
#                         title=task_data.get('title', 'Untitled Task'),
#                         description=task_data.get('description', ''),
#                         date=date_value,
#                         start_time=start_time_value,
#                         end_time=end_time_value,
#                         subject=main_subject,
#                         completed=False,
#                     )
#                     saved_count += 1
#                     print(f"✅ Gemini Task saved: {task.title} (Date: {date_value})")
#                     tasks_data.append(TaskSerializer(task).data)
#                 except Exception as e:
#                     print(f"Save error: {e}")

#             print(f"DEBUG: Total saved: {saved_count}/{len(tasks_list)}")

#             return Response({
#                 "message": f"Timetable generated for {subject_names}! {saved_count} tasks saved",
#                 "total_tasks": saved_count,
#                 "tasks": tasks_data
#             }, status=201)

#         except Exception as e:
#             import traceback
#             traceback.print_exc()
#             print(f"❌ Overall error: {str(e)}")
#             return Response({"error": str(e)}, status=500)

class TaskListAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            print("DEBUG: Fetching tasks from DB...")
            tasks = Task.objects.filter(user=request.user)
            count = tasks.count()
            print(f"DEBUG: DB returned {count} tasks for user {request.user.username}")
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

class TaskDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            task = Task.objects.get(pk=pk, user=request.user)
            serializer = TaskSerializer(task)
            return Response(serializer.data)
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)

    def put(self, request, pk):
        try:
            task = Task.objects.get(pk=pk, user=request.user)
            serializer = TaskSerializer(task, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=400)
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)

    def delete(self, request, pk):
        try:
            task = Task.objects.get(pk=pk, user=request.user)
            task.delete()
            return Response({"message": "Task deleted successfully"}, status=204)
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)

class CreateTaskAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            data = request.data.copy()
            data['user'] = request.user.id

            # Manually create task
            task = Task.objects.create(
                user=request.user,
                title=data.get('title', 'Untitled'),
                description=data.get('description', ''),
                date=data.get('date', ''),
                start_time=data.get('start_time', ''),
                end_time=data.get('end_time', ''),
                subject=data.get('subject', ''),
                completed=data.get('completed', False)
            )

            serializer = TaskSerializer(task)
            return Response(serializer.data, status=201)
        except Exception as e:
            return Response({"error": str(e)}, status=400)