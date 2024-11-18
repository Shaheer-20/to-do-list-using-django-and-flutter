# todo_backend/tasks/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TaskViewSet

router = DefaultRouter()
router.register(r'tasks', TaskViewSet)  # Register the TaskViewSet with the router

urlpatterns = [
    path('api/', include(router.urls)),  # Include the API routes in the URLs
]
