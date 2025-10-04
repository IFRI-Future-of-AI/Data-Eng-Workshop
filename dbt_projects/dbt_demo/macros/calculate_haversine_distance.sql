{% macro calculate_haversine_distance(lat1, lon1, lat2, lon2) %}
    {#
        Macro: calculate_haversine_distance
        Description: Calcule la distance en kilomètres entre deux points GPS
                     en utilisant la formule de Haversine
        
        Paramètres:
            - lat1: Latitude du point 1 (degrés)
            - lon1: Longitude du point 1 (degrés)
            - lat2: Latitude du point 2 (degrés)
            - lon2: Longitude du point 2 (degrés)
        
        Retour: Distance en kilomètres
        
        Exemple:
            {{ calculate_haversine_distance('dep_lat', 'dep_lon', 'arr_lat', 'arr_lon') }} AS distance_km
    #}
    
    111.045 * DEGREES(
        ACOS(
            COS(RADIANS({{ lat1 }}))
            * COS(RADIANS({{ lat2 }}))
            * COS(RADIANS({{ lon1 }}) - RADIANS({{ lon2 }}))
            + SIN(RADIANS({{ lat1 }}))
            * SIN(RADIANS({{ lat2 }}))
        )
    )
    
{% endmacro %}
