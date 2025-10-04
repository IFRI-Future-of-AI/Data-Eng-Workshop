{% macro get_flight_duration(departure_col, arrival_col, unit='minutes') %}
    {#
        Calcule la durée d'un vol en fonction des timestamps de départ et d'arrivée
        
        Args:
            departure_col: Colonne contenant le timestamp de départ
            arrival_col: Colonne contenant le timestamp d'arrivée
            unit: Unité de temps souhaitée ('minutes', 'hours', 'seconds')
        
        Returns:
            Durée du vol dans l'unité spécifiée
        
        Exemple:
            {{ get_flight_duration('actual_departure', 'actual_arrival', 'hours') }}
    #}
    
    {% if unit == 'minutes' %}
        EXTRACT(EPOCH FROM ({{ arrival_col }} - {{ departure_col }})) / 60
    {% elif unit == 'hours' %}
        EXTRACT(EPOCH FROM ({{ arrival_col }} - {{ departure_col }})) / 3600
    {% elif unit == 'seconds' %}
        EXTRACT(EPOCH FROM ({{ arrival_col }} - {{ departure_col }}))
    {% else %}
        EXTRACT(EPOCH FROM ({{ arrival_col }} - {{ departure_col }})) / 60
    {% endif %}
{% endmacro %}
