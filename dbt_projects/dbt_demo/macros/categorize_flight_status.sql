{% macro categorize_flight_status(status_col) %}
    {#
        Catégorise le statut d'un vol en français
        
        Args:
            status_col: Colonne contenant le statut du vol
        
        Returns:
            Statut catégorisé en français
        
        Exemple:
            {{ categorize_flight_status('status') }}
    #}
    
    CASE {{ status_col }}
        WHEN 'Scheduled' THEN 'Programmé'
        WHEN 'On Time' THEN 'À l''heure'
        WHEN 'Delayed' THEN 'Retardé'
        WHEN 'Departed' THEN 'Décollé'
        WHEN 'Arrived' THEN 'Arrivé'
        WHEN 'Cancelled' THEN 'Annulé'
        ELSE 'Inconnu'
    END
{% endmacro %}
