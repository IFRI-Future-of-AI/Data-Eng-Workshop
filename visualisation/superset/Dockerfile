FROM apache/superset:master

USER root

# Installation des dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installation des dépendances Python
COPY requirements.txt /app/requirements.txt
#RUN pip install uv 
RUN pip install -r requirements.txt 

# Configuration de Superset
ENV ADMIN_USERNAME=admin \
    ADMIN_EMAIL=admin@superset.com \
    ADMIN_PASSWORD=admin \
    PYTHONPATH=/app/pythonpath \
    SUPERSET_CONFIG_PATH=/app/superset_config.py \
    SUPERSET_LOAD_EXAMPLES=yes

# Copie des fichiers de configuration
COPY superset_config.py /app/superset_config.py
COPY superset-init.sh /app/superset-init.sh

RUN chmod +x /app/superset-init.sh

USER superset

ENTRYPOINT ["/app/superset-init.sh"]