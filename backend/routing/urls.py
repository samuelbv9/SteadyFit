"""
URL configuration for routing project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from app import views
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('goal/', views.goal, name='goal'),
    path('user_details/', views.user_details, name='user_details'),
    path('past_games/', views.past_games, name='past_games'),
    path('active_games/', views.active_games, name='active_games'),
    path('game_details/', views.game_details, name='game_details'),
    path('create_game/', views.create_game, name='create_game'),
    path('join_game/', views.join_game, name='join_game'),
    path('goal_status/', views.goal_status, name='goal_status'),
    path('bet_details/', views.bet_details, name='bet_details'),
    path('last_upload/', views.last_upload, name="last_upload"),
    path('add_workout/', views.add_workout, name="add_workout"),
    path('create_user/', views.create_user, name="create_user"),
    path('get_activity_type/', views.get_activity_type, name="get_activity_type"),
    path('initialize_elo/', views.initialize_elo, name="initialize_elo"),
    # path('update_date/', views.update_date, name="update_date"),

]
