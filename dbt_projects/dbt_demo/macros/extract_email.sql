{% macro extract_email(contact_data_col) %}
    {#
        Extrait l'email du champ JSON contact_data
        
        Args:
            contact_data_col: Colonne contenant les données de contact au format JSON
        
        Returns:
            Email ou 'N/A' si non disponible
        
        Exemple:
            {{ extract_email('contact_data') }}
    #}
    
    COALESCE({{ contact_data_col }}::jsonb->>'email', 'N/A')
{% endmacro %}
