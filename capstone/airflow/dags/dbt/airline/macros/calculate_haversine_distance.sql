{% macro calculate_haversine_distance(lat1, lon1, lat2, lon2) %}
    {#
        Macro: calculate_haversine_distance
        Description: Calcule la distance en kilomètres entre deux points GPS
                     en utilisant la formule de Haversine pour ClickHouse
        
        Paramètres:
            - lat1: Latitude du point 1 (degrés)
            - lon1: Longitude du point 1 (degrés)
            - lat2: Latitude du point 2 (degrés)
            - lon2: Longitude du point 2 (degrés)
        
        Retour: Distance en kilomètres
        
        Exemple:
            {{ calculate_haversine_distance('dep_lat', 'dep_lon', 'arr_lat', 'arr_lon') }} AS distance_km
    #}
    
    2 * 6371 * asin(sqrt(
        pow(sin(({{ lat2 }} - {{ lat1 }}) * pi() / 360), 2) +
        cos({{ lat1 }} * pi() / 180) * cos({{ lat2 }} * pi() / 180) *
        pow(sin(({{ lon2 }} - {{ lon1 }}) * pi() / 360), 2)
    ))
    
{% endmacro %}
