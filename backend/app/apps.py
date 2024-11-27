from django.apps import AppConfig

class AppConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "app"  

    def ready(self):
        print("starting job")

        from .scheduler.updater import schedule_jobs
        schedule_jobs()
