{% macro calculate_flight_duration(departure_timestamp, arrival_timestamp, unit='hours') %}
    {#
        Macro: calculate_flight_duration
        Description: Calcule la durée entre deux timestamps
        
        Paramètres:
            - departure_timestamp: Timestamp de départ
            - arrival_timestamp: Timestamp d'arrivée
            - unit: Unité de temps ('hours', 'minutes', 'seconds')
        
        Retour: Durée en unité spécifiée
        
        Exemple:
            {{ calculate_flight_duration('actual_departure', 'actual_arrival', 'hours') }}
    #}
    
    {% if unit == 'hours' %}
        EXTRACT(EPOCH FROM ({{ arrival_timestamp }} - {{ departure_timestamp }})) / 3600
    {% elif unit == 'minutes' %}
        EXTRACT(EPOCH FROM ({{ arrival_timestamp }} - {{ departure_timestamp }})) / 60
    {% elif unit == 'seconds' %}
        EXTRACT(EPOCH FROM ({{ arrival_timestamp }} - {{ departure_timestamp }}))
    {% else %}
        EXTRACT(EPOCH FROM ({{ arrival_timestamp }} - {{ departure_timestamp }})) / 3600
    {% endif %}
    
{% endmacro %}
