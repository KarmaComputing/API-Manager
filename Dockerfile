FROM registry.access.redhat.com/ubi9/python-39
USER root
RUN dnf update -y
RUN dnf  install python3-psycopg2 -y
ADD . /app
RUN  cp /app/local_settings_container.py /app/apimanager/apimanager/local_settings.py
RUN pip install -r /app/requirements.txt
RUN mkdir /logs
RUN touch /logs/gunicorn.access.log
RUN touch /logs/gunicorn.error.log
RUN chgrp -R 0 /logs && chmod -R g+rwX /logs
RUN chown -R 501 /app
RUN chgrp -R 0 /app && chmod -R g+rwX /app
USER 501
WORKDIR /app
RUN ./apimanager/manage.py collectstatic --noinput
RUN ./apimanager/manage.py migrate
WORKDIR /app/apimanager
EXPOSE 8000
CMD ["gunicorn", "--bind", ":8000", "--config", "../gunicorn.conf.py", "--workers", "3", "apimanager.wsgi"]