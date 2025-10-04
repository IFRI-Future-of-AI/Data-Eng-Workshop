{% macro calculate_delay(scheduled_col, actual_col, unit='minutes') %}
    {#
        Calcule le retard (ou avance) d'un vol
        Valeur positive = retard, valeur négative = avance
        
        Args:
            scheduled_col: Colonne contenant l'heure prévue
            actual_col: Colonne contenant l'heure réelle
            unit: Unité de temps ('minutes', 'hours', 'seconds')
        
        Returns:
            Retard en minutes (positif) ou avance (négatif)
        
        Exemple:
            {{ calculate_delay('scheduled_departure', 'actual_departure') }}
    #}
    
    {% if unit == 'minutes' %}
        EXTRACT(EPOCH FROM ({{ actual_col }} - {{ scheduled_col }})) / 60
    {% elif unit == 'hours' %}
        EXTRACT(EPOCH FROM ({{ actual_col }} - {{ scheduled_col }})) / 3600
    {% elif unit == 'seconds' %}
        EXTRACT(EPOCH FROM ({{ actual_col }} - {{ scheduled_col }}))
    {% else %}
        EXTRACT(EPOCH FROM ({{ actual_col }} - {{ scheduled_col }})) / 60
    {% endif %}
{% endmacro %}
