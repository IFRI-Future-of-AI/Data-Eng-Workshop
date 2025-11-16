{% macro calculate_flight_duration(departure_timestamp, arrival_timestamp, unit='hours') %}
    {#
        Macro: calculate_flight_duration
        Description: Calcule la durée entre deux timestamps pour ClickHouse
        
        Paramètres:
            - departure_timestamp: Timestamp de départ
            - arrival_timestamp: Timestamp d'arrivée
            - unit: Unité de temps ('hours', 'minutes', 'seconds')
        
        Retour: Durée en unité spécifiée
        
        Exemple:
            {{ calculate_flight_duration('actual_departure', 'actual_arrival', 'hours') }}
    #}
    
    {% if unit == 'hours' %}
        dateDiff('second', {{ departure_timestamp }}, {{ arrival_timestamp }}) / 3600.0
    {% elif unit == 'minutes' %}
        dateDiff('second', {{ departure_timestamp }}, {{ arrival_timestamp }}) / 60.0
    {% elif unit == 'seconds' %}
        dateDiff('second', {{ departure_timestamp }}, {{ arrival_timestamp }})
    {% else %}
        dateDiff('second', {{ departure_timestamp }}, {{ arrival_timestamp }}) / 3600.0
    {% endif %}
    
{% endmacro %}
