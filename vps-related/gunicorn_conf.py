from multiprocessing import cpu_count

Socket Path
bind = 'unix:/root/flask_project/gunicorn.sock'

Worker Options
workers = cpu_count() + 1
worker_class = 'uvicorn.workers.UvicornWorker'

Logging Options
loglevel = 'debug'
accesslog = '/root/flask_project/access_log'
errorlog =  '/root/flask_project/error_log'
