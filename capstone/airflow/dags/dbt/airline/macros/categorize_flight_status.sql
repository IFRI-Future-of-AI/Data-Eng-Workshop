{% macro categorize_flight_status(status_column) %}
    {#
        Macro: categorize_flight_status
        Description: Catégorise le statut d'un vol en groupes logiques
        
        Paramètres:
            - status_column: Nom de la colonne contenant le statut
        
        Retour: Catégorie de statut (En cours, Terminé, Programmé, Annulé)
        
        Exemple:
            {{ categorize_flight_status('status') }} AS status_category
    #}
    
    CASE
        WHEN {{ status_column }} IN ('Departed') THEN 'En cours'
        WHEN {{ status_column }} IN ('Arrived') THEN 'Terminé'
        WHEN {{ status_column }} IN ('Scheduled', 'On Time', 'Delayed') THEN 'Programmé'
        WHEN {{ status_column }} IN ('Cancelled') THEN 'Annulé'
        ELSE 'Inconnu'
    END
    
{% endmacro %}
