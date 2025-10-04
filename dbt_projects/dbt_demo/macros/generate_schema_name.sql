{% macro generate_schema_name(custom_schema_name, node) -%}
    {#
        Macro: generate_schema_name
        Description: Génère le nom du schéma pour les modèles dbt
                     Simplifie la structure en évitant la concaténation target_schema + custom_schema
        
        Paramètres:
            - custom_schema_name: Nom du schéma personnalisé défini dans config()
            - node: Objet node dbt contenant les métadonnées du modèle
        
        Retour: Nom du schéma à utiliser
        
        Exemple d'utilisation dans dbt_project.yml:
            models:
              dbt_demo:
                +schema: analytics
    #}
    
    {%- set default_schema = target.schema -%}
    
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
