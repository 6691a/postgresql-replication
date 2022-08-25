from django
class DBRouter():
    def __init__(self):
        self.models_list = ['write_only', 'read_only', 'default']

    def db_for_read(self, model, **hints):
        return 'read_only'

    def db_for_write(self, model, **hints):
        ...

    def allow_relation(self, obj1, obj2, **hints):
        ...

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        ...