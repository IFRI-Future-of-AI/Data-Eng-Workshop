FROM astrocrpublic.azurecr.io/runtime:3.1-5

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install uv && \
    uv pip install --no-cache-dir -r dbt_requirements.txt && deactivate