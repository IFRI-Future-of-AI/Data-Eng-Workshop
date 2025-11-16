{% macro extract_json_contact(json_column, field='email') %}
    {#
        Macro: extract_json_contact
        Description: Extrait un champ spécifique d'un objet JSONB contact_data
        
        Paramètres:
            - json_column: Nom de la colonne JSONB
            - field: Champ à extraire ('email' ou 'phone')
        
        Retour: Valeur extraite du JSONB
        
        Exemple:
            {{ extract_json_contact('contact_data', 'email') }} AS passenger_email
    #}
    
    {{ json_column }}::jsonb->>'{{ field }}'
    
{% endmacro %}
