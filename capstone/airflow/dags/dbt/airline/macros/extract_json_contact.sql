{% macro extract_json_contact(json_column, field='email') %}
    {#
        Macro: extract_json_contact
        Description: Extrait un champ spécifique d'un objet JSON contact_data pour ClickHouse
        
        Paramètres:
            - json_column: Nom de la colonne JSON/String
            - field: Champ à extraire ('email' ou 'phone')
        
        Retour: Valeur extraite du JSON
        
        Exemple:
            {{ extract_json_contact('contact_data', 'email') }} AS passenger_email
    #}
    
    JSONExtractString({{ json_column }}, '{{ field }}')
    
{% endmacro %}
