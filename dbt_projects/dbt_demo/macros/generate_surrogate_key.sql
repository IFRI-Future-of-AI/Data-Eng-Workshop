{% macro generate_surrogate_key(field_list) %}
    {#
        Génère une clé de substitution (surrogate key) basée sur une liste de champs
        Utilise MD5 pour créer un hash des valeurs concaténées
        
        Args:
            field_list: Liste de noms de colonnes à utiliser pour la clé
        
        Returns:
            Clé de substitution sous forme de hash MD5
        
        Exemple:
            {{ generate_surrogate_key(['ticket_no', 'flight_id']) }}
    #}
    
    MD5(
        {% for field in field_list %}
            CAST({{ field }} AS VARCHAR)
            {% if not loop.last %} || '-' || {% endif %}
        {% endfor %}
    )
{% endmacro %}
