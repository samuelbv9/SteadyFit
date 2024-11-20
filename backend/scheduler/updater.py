import os
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from datetime import datetime
from django.db import connection

# Import your weekly_update function
from .app.views import weekly_update  # Adjust import path as needed

# def schedule_jobs():
#     scheduler = BackgroundScheduler()

#     scheduler.add_job(
#         weekly_update,
#         trigger=CronTrigger(hour=23, minute=59),  
#         id="weekly_update",  
#         replace_existing=True,  
#     )
#     scheduler.start()

#     print("Scheduler started. Jobs scheduled.")

def schedule_jobs():
    scheduler = BackgoundScheduler()
    scheduler.add_job(weekly_update, "interval", minutes = 2, id = "update", replace_existing=True)
    scheduler.start()
    print(scheduler.get_jobs())
