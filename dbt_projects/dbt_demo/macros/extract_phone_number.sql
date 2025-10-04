{% macro extract_phone_number(contact_data_col) %}
    {#
        Extrait le numéro de téléphone du champ JSON contact_data
        
        Args:
            contact_data_col: Colonne contenant les données de contact au format JSON
        
        Returns:
            Numéro de téléphone ou 'N/A' si non disponible
        
        Exemple:
            {{ extract_phone_number('contact_data') }}
    #}
    
    COALESCE({{ contact_data_col }}::jsonb->>'phone', 'N/A')
{% endmacro %}
